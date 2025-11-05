# Quick Start: CI/CD Setup

This guide will help you quickly set up Azure DevOps CI/CD pipelines for the AI Document Processor project.

## Prerequisites Checklist

- [ ] Azure DevOps organization and project created
- [ ] Azure subscription with appropriate permissions
- [ ] Azure CLI installed (for local testing)
- [ ] Python 3.11+ installed (for local testing)

## 5-Minute Setup

### Step 1: Create Azure Service Connection (2 minutes)

1. In Azure DevOps, go to **Project Settings** → **Service connections**
2. Click **New service connection**
3. Select **Azure Resource Manager**
4. Choose **Workload Identity federation (automatic)** (recommended)
5. Select your subscription and resource group
6. Name it: `Azure-Subscription-Connection` (or your preferred name)
7. Save the connection

### Step 2: Update Pipeline Variables (1 minute)

1. Open `azure-pipelines.yml` in your repository
2. Find and replace:
   - `YOUR_AZURE_SERVICE_CONNECTION` → Your service connection name (from Step 1)
   - `functionAppName` → Your function app name (if different)
   - `resourceGroupName` → Your resource group name (if different)
   - `environmentName` → `dev`, `staging`, or `prod`

### Step 3: Create Pipeline in Azure DevOps (1 minute)

1. Go to **Pipelines** → **New pipeline**
2. Select your repository type (Azure Repos Git, GitHub, etc.)
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select `/azure-pipelines.yml` from the branch
6. Review and save

### Step 4: Create Environments (1 minute)

1. Go to **Pipelines** → **Environments**
2. Click **Create environment**
3. Name it: `dev`
4. Optionally add approval gates for `staging` and `prod`

## Testing Your Pipeline

### Test Build

1. Make a small change to a file in `pipeline/` directory
2. Commit and push to your repository
3. The pipeline should automatically trigger
4. Monitor the pipeline run in Azure DevOps

### Test Deployment

1. Merge changes to `main` branch
2. The deployment stages will automatically run
3. Verify deployment in Azure portal

## Next Steps

- [ ] Review `docs/CICD_SETUP.md` for detailed configuration
- [ ] Set up branch policies (optional)
- [ ] Configure variable groups for secrets
- [ ] Add approval gates for production deployments

## Troubleshooting

### Pipeline won't start
- Check that the YAML file path is correct
- Verify branch triggers are configured correctly

### Service connection error
- Verify the service connection name matches exactly
- Check that the service connection has proper permissions

### Build fails
- Check Python version compatibility
- Verify `requirements.txt` is valid
- Review build logs for specific errors

### Deployment fails
- Verify function app exists in Azure
- Check function app name matches
- Ensure proper permissions are set

## Additional Resources

- Full documentation: `docs/CICD_SETUP.md`
- Pipeline details: `.azure-pipelines/README.md`
- Azure Pipelines docs: https://docs.microsoft.com/azure/devops/pipelines/

## Support

For issues:
1. Check pipeline logs in Azure DevOps
2. Review troubleshooting section in `docs/CICD_SETUP.md`
3. Check Azure portal for function app status

