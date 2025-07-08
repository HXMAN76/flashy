# Azure App Service Deployment Guide

## 🚫 FTP is Disabled
Since FTP authentication has been disabled for your web app (for security reasons), here are the alternative deployment methods:

## ✅ Method 1: ZIP Deploy via Azure Portal (EASIEST)

### Step 1: Create the deployment package
Run the deployment script:
```bash
./deploy.sh
```

### Step 2: Deploy via Azure Portal
1. **Open Azure Portal** (https://portal.azure.com)
2. **Navigate to your App Service**
3. **Go to Deployment Center** (in the left sidebar)
4. **Select "ZIP Deploy" tab**
5. **Browse and select** your `website.zip` file
6. **Click "Deploy"**

### Step 3: Verify deployment
- Your website should be available at: `https://your-app-name.azurewebsites.net`
- Check the deployment logs in the Deployment Center for any issues

## ✅ Method 2: GitHub Integration (BEST FOR CONTINUOUS DEPLOYMENT)

### Step 1: Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/your-repo.git
git push -u origin main
```

### Step 2: Connect GitHub in Azure
1. **Azure Portal** > **Your App Service** > **Deployment Center**
2. **Choose "GitHub"** as source
3. **Authorize Azure** to access your GitHub
4. **Select your repository and branch**
5. **Save** - Azure will automatically deploy on every push!

## ✅ Method 3: Azure CLI (FOR DEVELOPERS)

### Install Azure CLI
```bash
# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Or download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
```

### Deploy using CLI
```bash
# Login to Azure
az login

# Deploy your website
az webapp deployment source config-zip \
  --resource-group "your-resource-group" \
  --name "your-app-name" \
  --src website.zip
```

## ✅ Method 4: VS Code Extension (FOR VS CODE USERS)

### Step 1: Install Extension
- Install "Azure App Service" extension in VS Code

### Step 2: Deploy
1. **Sign in to Azure** in VS Code
2. **Open Azure panel** (Azure icon in sidebar)
3. **Find your App Service**
4. **Right-click** > **Deploy to Web App...**
5. **Select your project folder**

## 🔧 Troubleshooting

### Common Issues:
1. **App won't start**: Check that `index.html` is in the root directory
2. **404 errors**: Ensure `web.config` is deployed with `index.html`
3. **Deployment fails**: Check deployment logs in Azure Portal

### File Structure Should Be:
```
/site/wwwroot/
├── index.html
└── web.config
```

## 🚀 Your Website Features:
- ✨ Animated rainbow text
- 🎨 Gradient backgrounds
- 🎭 Interactive particle effects
- 📱 Responsive design
- 🌟 Floating shapes animation
- 🔮 Modal popups
- 🎯 Mouse trail effects

Visit your deployed site at: `https://your-app-name.azurewebsites.net`
