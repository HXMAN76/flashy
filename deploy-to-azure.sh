#!/bin/bash

# Azure CLI Deployment Script for Azure Form
# This script deploys the HTML form to an Azure App Service

# Text styling
BOLD="\e[1m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${BOLD}${BLUE}=========================================${RESET}"
echo -e "${BOLD}${BLUE}  Azure Web Form Deployment with Azure CLI${RESET}"
echo -e "${BOLD}${BLUE}=========================================${RESET}"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${BOLD}${YELLOW}Azure CLI not found. Installing...${RESET}"
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    echo -e "${BOLD}${GREEN}Azure CLI installed successfully!${RESET}"
else
    echo -e "${BOLD}${GREEN}Azure CLI is already installed.${RESET}"
    az --version | head -1
fi

# Install zip if not available - do this FIRST before trying to use it
echo ""
echo -e "${BOLD}${BLUE}Installing required utilities...${RESET}"
if ! command -v zip &> /dev/null; then
    echo -e "${BOLD}${YELLOW}zip utility not found. Installing...${RESET}"
    sudo apt-get update && sudo apt-get install -y zip
    if command -v zip &> /dev/null; then
        echo -e "${BOLD}${GREEN}zip utility installed successfully!${RESET}"
    else
        echo -e "${BOLD}${RED}Failed to install zip. Please install it manually with 'sudo apt-get install zip'${RESET}"
        exit 1
    fi
else
    echo -e "${BOLD}${GREEN}zip utility is already installed.${RESET}"
fi

echo ""
echo -e "${BOLD}Logging into Azure...${RESET}"
az login

# Set variables with randomness to avoid conflicts
RANDOM_SUFFIX=$(date +%s)
RESOURCE_GROUP="hxman-form-rg-${RANDOM_SUFFIX}"
LOCATION="centralindia"
APP_SERVICE_PLAN="form-plan-${RANDOM_SUFFIX}"
WEB_APP_NAME="azure-form-${RANDOM_SUFFIX}"
SUBSCRIPTION=$(az account show --query id -o tsv)

echo ""
echo -e "${BOLD}Your deployment configuration:${RESET}"
echo -e "Subscription: ${GREEN}$SUBSCRIPTION${RESET}"
echo -e "Resource Group: ${GREEN}$RESOURCE_GROUP${RESET}"
echo -e "Location: ${GREEN}$LOCATION${RESET}"
echo -e "App Service Plan: ${GREEN}$APP_SERVICE_PLAN${RESET}"
echo -e "Web App Name: ${GREEN}$WEB_APP_NAME${RESET}"
echo ""

# Confirm with user
read -p "Do you want to proceed with this configuration? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Deployment canceled."
    exit 1
fi

# Step 1: Create Resource Group
echo ""
echo -e "${BOLD}${BLUE}Step 1: Creating Resource Group...${RESET}"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
if [ $? -ne 0 ]; then
    echo -e "${BOLD}${RED}Failed to create resource group. Exiting.${RESET}"
    exit 1
fi

# Step 2: Create App Service Plan with retry logic
echo ""
echo -e "${BOLD}${BLUE}Step 2: Creating App Service Plan...${RESET}"
MAX_RETRIES=3
RETRY_COUNT=0
APP_PLAN_CREATED=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$APP_PLAN_CREATED" = false ]; do
    az appservice plan create --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" --sku F1 --is-linux
    if [ $? -eq 0 ]; then
        APP_PLAN_CREATED=true
        echo -e "${BOLD}${GREEN}App Service Plan created successfully!${RESET}"
    else
        # Check if it already exists due to partial creation
        az appservice plan show --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${BOLD}${YELLOW}App Service Plan already exists. Proceeding...${RESET}"
            APP_PLAN_CREATED=true
        else
            RETRY_COUNT=$((RETRY_COUNT+1))
            echo -e "${BOLD}${YELLOW}Attempt $RETRY_COUNT of $MAX_RETRIES: Failed to create App Service Plan. Retrying in 10 seconds...${RESET}"
            sleep 10
        fi
    fi
done

if [ "$APP_PLAN_CREATED" = false ]; then
    echo -e "${BOLD}${RED}Failed to create App Service Plan after $MAX_RETRIES attempts. Exiting.${RESET}"
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
    echo -e "${BOLD}${YELLOW}Resource group scheduled for deletion to avoid orphaned resources.${RESET}"
    exit 1
fi

echo "Waiting for App Service Plan creation to complete..."
sleep 15


# Step 4: Preparing files for deployment
echo ""
echo -e "${BOLD}${BLUE}Step 4: Preparing files for deployment...${RESET}"
# Create a temporary folder for deployment
TEMP_DIR="temp_deploy"
mkdir -p "$TEMP_DIR"

# Copy HTML file
cp azure-form.html "$TEMP_DIR/index.html"

# Create a simple PHP wrapper (to serve the HTML file as default)
echo '<?php include_once("index.html"); ?>' > "$TEMP_DIR/index.php"
echo "Created PHP wrapper to properly serve the HTML file"

# Check if zip is available before using it
if command -v zip &> /dev/null; then
    # Create a ZIP archive for deployment
    cd "$TEMP_DIR" || exit 1
    zip -r ../webapp.zip *
    cd ..
    echo "Created deployment package webapp.zip"
else
    echo -e "${BOLD}${RED}ZIP command not available. Please install zip package.${RESET}"
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
    echo -e "${BOLD}${YELLOW}Resource group scheduled for deletion to avoid orphaned resources.${RESET}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Step 5: Deploy to Azure App Service
echo ""
echo -e "${BOLD}${BLUE}Step 5: Deploying to Azure App Service...${RESET}"
# Use the new command instead of the deprecated one
MAX_RETRIES=3
RETRY_COUNT=0
DEPLOY_SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$DEPLOY_SUCCESS" = false ]; do
    az webapp deploy --resource-group "$RESOURCE_GROUP" --name "$WEB_APP_NAME" --src-path webapp.zip --type zip
    if [ $? -eq 0 ]; then
        DEPLOY_SUCCESS=true
        echo -e "${BOLD}${GREEN}Deployment successful!${RESET}"
    else
        RETRY_COUNT=$((RETRY_COUNT+1))
        echo -e "${BOLD}${YELLOW}Attempt $RETRY_COUNT of $MAX_RETRIES: Deployment failed. Retrying in 10 seconds...${RESET}"
        sleep 10
    fi
done

if [ "$DEPLOY_SUCCESS" = false ]; then
    echo -e "${BOLD}${RED}Failed to deploy after $MAX_RETRIES attempts.${RESET}"
    echo -e "${BOLD}${YELLOW}You can try manual deployment via the Azure Portal.${RESET}"
else
    echo -e "${BOLD}${GREEN}Deployment completed successfully!${RESET}"
fi

# Clean up
rm -rf "$TEMP_DIR" webapp.zip

echo ""
echo -e "${BOLD}${GREEN}==================================================${RESET}"
echo -e "${BOLD}${GREEN}Deployment Process Completed!${RESET}"
echo -e "${BOLD}${GREEN}==================================================${RESET}"
echo ""
echo -e "Your form should be available at (if deployment succeeded):"
echo -e "${BOLD}https://$WEB_APP_NAME.azurewebsites.net/${RESET}"
echo ""
echo -e "To manage your web app in the Azure Portal:"
echo -e "https://portal.azure.com/#resource/subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$WEB_APP_NAME/appServices"
echo ""
echo -e "${BOLD}${YELLOW}Important Notes:${RESET}"
echo -e "1. The form is set up with simulated submission behavior"
echo -e "2. To connect to a backend, edit the form's JavaScript to use an Azure Function"
echo -e "3. To delete this deployment when no longer needed:"
echo -e "   ${BLUE}az group delete --name $RESOURCE_GROUP --yes --no-wait${RESET}"
echo ""