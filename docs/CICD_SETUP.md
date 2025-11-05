# CI/CD Setup Guide for AI Document Processor

This guide explains how to set up and configure Azure DevOps CI/CD pipelines for the AI Document Processor project.

## Overview

The project includes three main pipeline configurations:

1. **Main Pipeline** (`azure-pipelines.yml`) - Full CI/CD pipeline for building, testing, and deploying both infrastructure and function app
2. **Infrastructure Pipeline** (`.azure-pipelines/infrastructure-pipeline.yml`) - Dedicated pipeline for infrastructure deployment
3. **Function App Pipeline** (`.azure-pipelines/function-app-pipeline.yml`) - Dedicated pipeline for function app deployment

## Prerequisites

1. Azure DevOps organization and project
2. Azure subscription with appropriate permissions
3. Azure CLI installed and configured
4. Python 3.11+ installed (for local testing)

## Setup Steps

### 1. Create Azure Service Connection

1. Navigate to your Azure DevOps project
2. Go to **Project Settings** → **Service connections**
3. Click **New service connection**
4. Select **Azure Resource Manager**
5. Choose **Workload Identity federation (automatic)** or **Service principal (automatic)**
6. Select your subscription and resource group
7. Give it a name (e.g., `Azure-Subscription-Connection`)
8. Save the connection

### 2. Update Pipeline Variables

Edit the pipeline files and update the following variables:

- `azureSubscription`: Replace `YOUR_AZURE_SERVICE_CONNECTION` with your service connection name
- `functionAppName`: Update if your function app has a different naming convention
- `resourceGroupName`: Update to match your resource group name
- `environmentName`: Set to `dev`, `staging`, or `prod` as needed

### 3. Create Pipeline in Azure DevOps

#### Option A: Using the Main Pipeline

1. Go to **Pipelines** → **New pipeline**
2. Select **Azure Repos Git** (or your repository type)
3. Select your repository
4. Choose **Existing Azure Pipelines YAML file**
5. Select `/azure-pipelines.yml` from the branch
6. Review and save

#### Option B: Using Separate Pipelines

1. Create a new pipeline for infrastructure:
   - Select `.azure-pipelines/infrastructure-pipeline.yml`
   - Name it "Infrastructure Deployment"

2. Create a new pipeline for function app:
   - Select `.azure-pipelines/function-app-pipeline.yml`
   - Name it "Function App Deployment"

### 4. Configure Environments

1. Go to **Pipelines** → **Environments**
2. Create environments: `dev`, `staging`, `prod`
3. Configure approval gates if needed
4. Add resource tags and protection rules as required

### 5. Set Up Branch Policies (Optional)

1. Go to **Repos** → **Branches**
2. Select your main branch
3. Configure branch policies:
   - Require build validation
   - Require pull request reviews
   - Set up merge policies

## Pipeline Workflow

### Main Pipeline (`azure-pipelines.yml`)

The main pipeline consists of four stages:

1. **Build**: Builds and tests the Azure Functions application
2. **ValidateInfrastructure**: Validates Bicep templates
3. **DeployInfrastructure**: Deploys infrastructure (only on main branch)
4. **DeployFunctions**: Deploys the function app (only on main branch)

### Trigger Conditions

- **Build**: Triggers on changes to `pipeline/`, `infra/`, or pipeline files
- **Deploy**: Only deploys when merging to `main` branch
- **PR**: Runs build and validation on pull requests

## Customization

### Adding Environment Variables

Add secrets or variables in Azure DevOps:

1. Go to **Pipelines** → **Library**
2. Create a variable group
3. Add variables or link to Azure Key Vault
4. Reference in pipeline: `variables: - group: 'myVariableGroup'`

### Adding Additional Stages

To add a staging environment:

```yaml
- stage: DeployStaging
  displayName: 'Deploy to Staging'
  dependsOn: DeployFunctions
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  # ... rest of deployment steps
```

### Customizing Build Steps

Modify the build job to include:
- Code coverage reports
- Security scanning
- Performance testing
- Custom validation steps

## Troubleshooting

### Common Issues

1. **Service Connection Not Found**
   - Verify the service connection name matches exactly
   - Check permissions on the service connection

2. **Bicep Validation Fails**
   - Ensure Azure CLI is installed on the agent
   - Check Bicep syntax in templates

3. **Function App Deployment Fails**
   - Verify function app exists in Azure
   - Check that the function app name matches
   - Ensure proper permissions are set

4. **Python Dependencies Fail**
   - Check `requirements.txt` for syntax errors
   - Verify Python version compatibility

### Debugging

Enable detailed logging:
- Add `system.debug: true` to pipeline variables
- Check pipeline logs for detailed error messages
- Review Azure portal logs for function app issues

## Security Best Practices

1. **Use Managed Identities**: Prefer managed identities over connection strings
2. **Secure Variables**: Store secrets in Azure Key Vault or Variable Groups
3. **Least Privilege**: Grant minimal required permissions to service connections
4. **Audit Logs**: Enable audit logs for pipeline runs
5. **Branch Protection**: Enforce branch policies and approvals

## Additional Resources

- [Azure Pipelines Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Functions Deployment](https://docs.microsoft.com/azure/azure-functions/functions-deployment-technologies)

## Support

For issues or questions:
1. Check the troubleshooting guide in `docs/troubleShootingGuide.md`
2. Review Azure DevOps pipeline logs
3. Contact the DevOps team

