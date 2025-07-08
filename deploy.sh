#!/bin/bash

# Azure App Service Deployment Script
# FTP is disabled, so we'll use alternative methods
# Replace these variables with your actual values
APP_NAME="your-app-name"
RESOURCE_GROUP="your-resource-group"

echo "=== Azure App Service Deployment Options ==="
echo "Note: FTP authentication is disabled for security."
echo "Here are the available deployment methods:"
echo ""

echo "Method 1: ZIP Deploy via Azure Portal (RECOMMENDED)"
echo "1. Create a ZIP file with your website files"
echo "2. Go to Azure Portal > Your App Service > Deployment Center"
echo "3. Choose 'ZIP Deploy' tab"
echo "4. Upload the ZIP file"
echo ""

echo "Method 2: GitHub Integration"
echo "1. Push your code to a GitHub repository"
echo "2. Go to Azure Portal > Your App Service > Deployment Center"
echo "3. Choose 'GitHub' as source"
echo "4. Authorize and select your repository"
echo ""

echo "Method 3: Azure CLI (if installed)"
echo "1. Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
echo "2. az login"
echo "3. az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $APP_NAME --src website.zip"
echo ""

echo "Method 4: VS Code Azure Extension"
echo "1. Install 'Azure App Service' extension in VS Code"
echo "2. Sign in to Azure"
echo "3. Right-click your app service > Deploy to Web App"
echo ""

echo "Creating ZIP file for deployment..."
if command -v zip &> /dev/null; then
    zip -r website.zip index.html web.config
    echo "✅ website.zip created successfully"
else
    tar -czf website.tar.gz index.html web.config
    echo "✅ website.tar.gz created (convert to ZIP for Azure Portal)"
fi

echo ""
echo "🚀 Your files are ready for deployment!"
echo "📁 Upload the archive file using Azure Portal's ZIP Deploy feature."
