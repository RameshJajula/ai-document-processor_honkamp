# Azure DevOps Pipelines

This directory contains Azure DevOps pipeline configurations for the AI Document Processor project.

## Pipeline Files

### Main Pipeline (`azure-pipelines.yml`)
Located in the root directory, this is the primary CI/CD pipeline that handles:
- Building and testing the Azure Functions application
- Validating Bicep infrastructure templates
- Deploying infrastructure (Bicep)
- Deploying the Function App

### Infrastructure Pipeline (`.azure-pipelines/infrastructure-pipeline.yml`)
Dedicated pipeline for infrastructure deployment:
- Validates all Bicep templates
- Deploys infrastructure independently
- Useful for infrastructure-only changes

### Function App Pipeline (`.azure-pipelines/function-app-pipeline.yml`)
Dedicated pipeline for Azure Functions deployment:
- Builds and tests the function app
- Packages the application
- Deploys to Azure Function App
- Useful for application-only changes

## Usage

### Setting Up Pipelines in Azure DevOps

1. **Create Service Connection**
   - Go to Project Settings → Service connections
   - Create an Azure Resource Manager connection
   - Note the connection name

2. **Update Pipeline Variables**
   - Edit pipeline YAML files
   - Replace `YOUR_AZURE_SERVICE_CONNECTION` with your service connection name
   - Update other variables as needed (resource group, function app name, etc.)

3. **Create Pipeline**
   - Go to Pipelines → New pipeline
   - Select your repository
   - Choose "Existing Azure Pipelines YAML file"
   - Select the appropriate pipeline file

4. **Configure Environments**
   - Create environments: `dev`, `staging`, `prod`
   - Configure approval gates if needed

## Pipeline Triggers

All pipelines trigger on:
- Changes to relevant paths (pipeline/, infra/, etc.)
- Pull requests to `main` or `develop` branches
- Pushes to `main` or `develop` branches

Deployment stages only run on:
- Successful builds
- Merges to `main` branch

## Customization

### Adding New Stages

Example: Adding a staging deployment stage

```yaml
- stage: DeployStaging
  displayName: 'Deploy to Staging'
  dependsOn: DeployFunctions
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
    - deployment: DeployStaging
      # ... deployment steps
```

### Environment Variables

Add variables in Azure DevOps:
1. Go to Pipelines → Library
2. Create a variable group
3. Reference in pipeline:
   ```yaml
   variables:
     - group: 'myVariableGroup'
   ```

## Troubleshooting

See `docs/CICD_SETUP.md` for detailed troubleshooting guide.

Common issues:
- Service connection not found → Verify connection name matches exactly
- Bicep validation fails → Check Bicep syntax and Azure CLI installation
- Function app deployment fails → Verify function app exists and permissions are correct

