# Detailed Change Log - Flex Consumption Plan Migration

This document provides a comprehensive list of all changes made to migrate from App Service Plan (S3) to Flex Consumption Plan, including file names, line numbers, before/after comparisons, and reasons for each change.

---

## File: `infra/modules/compute/functionApp.bicep`

### Change 1: Added deployment storage blob endpoint variable
**Line:** ~50-52  
**Before:**
```bicep
var openaiApiVersion = '2024-05-01-preview'
var openaiApiBase = aoaiEndpoint
var openaiModel = 'gpt-4o'
```

**After:**
```bicep
// Construct blob endpoint URL for deployment storage (required for Flex Consumption validation)
// Note: For zipDeploy, deployment.storage is not actually used, but Azure requires it to be valid if present
var deploymentStorageBlobEndpoint = 'https://${funcStorageName}.blob.${environment().suffixes.storage}/deployment'

var openaiApiVersion = '2024-05-01-preview'
var openaiApiBase = aoaiEndpoint
var openaiModel = 'gpt-4o'
```

**Reason:** Flex Consumption plans require a valid `deployment.storage` configuration even when using zipDeploy. This variable constructs the blob container URL needed for the deployment storage configuration.

---

### Change 2: Made FUNCTIONS_WORKER_RUNTIME conditional
**Line:** ~147-153  
**Before:**
```bicep
        {
          name: 'ApplicationInsights__InstrumentationKey'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
```

**After:**
```bicep
        {
          name: 'ApplicationInsights__InstrumentationKey'
          value: applicationInsights.properties.InstrumentationKey
        }
        // FUNCTIONS_WORKER_RUNTIME is not allowed for Flex Consumption plans
        // Runtime is configured via functionAppConfig.runtime instead
      ], isFlexConsumption ? [] : [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
      ], [
```

**Reason:** The `FUNCTIONS_WORKER_RUNTIME` app setting is not supported for Flex Consumption plans. For Flex Consumption, the runtime must be configured via `functionAppConfig.runtime` instead. This change makes it conditional so it's only set for non-Flex Consumption plans.

---

### Change 3: Made ENABLE_ORYX_BUILD and SCM_DO_BUILD_DURING_DEPLOYMENT conditional
**Line:** ~154-163  
**Before:**
```bicep
      ], [
        {
          name: 'ENABLE_ORYX_BUILD'
          value: 'true'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'APP_CONFIGURATION_URI'
```

**After:**
```bicep
      ], isFlexConsumption ? [] : [
        {
          name: 'ENABLE_ORYX_BUILD'
          value: 'true'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ], [
        {
          name: 'APP_CONFIGURATION_URI'
```

**Reason:** The `ENABLE_ORYX_BUILD` and `SCM_DO_BUILD_DURING_DEPLOYMENT` app settings are not supported for Flex Consumption SKU. These settings are only applicable to other hosting plans. This change makes them conditional so they're only set for non-Flex Consumption plans.

---

### Change 4: Made linuxFxVersion conditional
**Line:** ~189-194  
**Before:**
```bicep
      ] : [])
      ftpsState: 'FtpsOnly'
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
    }
```

**After:**
```bicep
      ] : [])
      ftpsState: 'FtpsOnly'
      // linuxFxVersion is not allowed for Flex Consumption plans
      // It must be set via functionAppConfig.runtime instead
      linuxFxVersion: isFlexConsumption ? null : linuxFxVersion
      minTlsVersion: '1.2'
    }
```

**Reason:** The `linuxFxVersion` site configuration property is not allowed for Flex Consumption plans. For Flex Consumption, the runtime must be configured via `functionAppConfig.runtime` instead. This change makes it conditional so it's only set for non-Flex Consumption plans.

---

### Change 5: Added functionAppConfig with deployment.storage
**Line:** ~198-220  
**Before:**
```bicep
    httpsOnly: true
  }
}
```

**After:**
```bicep
    // Flex Consumption plan requires functionAppConfig
    // Note: deployment.storage is optional for zipDeploy, but Azure requires it to be valid if present
    // We provide a minimal valid configuration to satisfy validation
    functionAppConfig: isFlexConsumption ? {
      runtime: {
        name: runtimeName
        version: runtime == 'python' ? '3.11' : (runtime == 'node' ? '20' : '~4')
      }
      scaleAndConcurrency: {
        maximumInstanceCount: maximumInstanceCount
        instanceMemoryMB: instanceMemoryMB
      }
      // deployment.storage is required for validation even with zipDeploy
      deployment: {
        storage: {
          type: 'blobContainer'
          value: deploymentStorageBlobEndpoint
          authentication: {
            type: 'UserAssignedIdentity'
            userAssignedIdentityResourceId: identityId
          }
        }
      }
    } : null
    httpsOnly: true
  }
}
```

**Reason:** Flex Consumption plans require the `functionAppConfig` property to configure runtime, scaling, and deployment settings. This replaces the traditional app settings and site configuration properties that are not supported for Flex Consumption. The `deployment.storage` configuration is required even though we're using zipDeploy, as Azure validates it during resource creation.

---

## File: `infra/modules/compute/hosting-plan.bicep`

### Change 1: Updated hosting plan parameters for Flex Consumption
**Line:** ~5-32  
**Before:**
```bicep
@description('Kind of hosting plan.')
param kind string = 'linux'
@description('SKU tier.')
param skuTier string = 'Standard'
@description('SKU name.')
param skuName string = 'S3'
```

**After:**
```bicep
@description('Kind of hosting plan. For Flex Consumption, use "functionapp".')
param kind string = 'functionapp'
@description('SKU tier. For Flex Consumption, use "FlexConsumption".')
@allowed([
  'FlexConsumption'
  'Dynamic'
  'ElasticPremium'
  'Standard'
])
param skuTier string = 'FlexConsumption'
@description('SKU name. For Flex Consumption, use "FC1".')
@allowed([
  'FC1'
  'Y1'
  'EP1'
  'EP2'
  'EP3'
  'S1'
  'S2'
  'S3'
  'P0v3'
  'P1v3'
  'P2v3'
  'P3v3'
])
param skuName string = 'FC1'
@description('Zone redundancy. Only applicable for Flex Consumption.')
param zoneRedundant bool = false
```

**Reason:** Updated the hosting plan module to support Flex Consumption plan configuration. Changed default values from Standard/S3 to FlexConsumption/FC1, and added support for zone redundancy which is applicable to Flex Consumption plans.

---

### Change 2: Updated hosting plan resource properties
**Line:** ~45-48  
**Before:**
```bicep
  properties: {
    reserved: true
  }
```

**After:**
```bicep
  properties: {
    reserved: true
    zoneRedundant: (skuTier == 'FlexConsumption') ? zoneRedundant : null
  }
```

**Reason:** Added zone redundancy support for Flex Consumption plans. This property is only applicable to Flex Consumption plans, so it's conditionally set based on the SKU tier.

---

## File: `infra/main.bicep`

### Change 1: Added hosting plan configuration parameters
**Line:** ~62-101  
**Before:**
```bicep
param aoaiLocation string

@description('Network isolation? If yes it will create the private endpoints.')
```

**After:**
```bicep
param aoaiLocation string

@description('Hosting plan SKU tier. Options: FlexConsumption (serverless), Dynamic (Consumption), ElasticPremium (Premium), Standard (Dedicated).')
@allowed([
  'FlexConsumption'
  'Dynamic'
  'ElasticPremium'
  'Standard'
])
param hostingPlanSkuTier string = 'FlexConsumption'

@description('Hosting plan SKU name. For FlexConsumption use FC1, for Dynamic use Y1, for ElasticPremium use EP1/EP2/EP3, for Standard use S1/S2/S3.')
@allowed([
  'FC1'
  'Y1'
  'EP1'
  'EP2'
  'EP3'
  'S1'
  'S2'
  'S3'
  'P0v3'
  'P1v3'
  'P2v3'
  'P3v3'
])
param hostingPlanSkuName string = 'FC1'

@description('Hosting plan kind. For Flex Consumption use "functionapp", for other plans typically use "functionapp" or "linux".')
param hostingPlanKind string = 'functionapp'

@description('Zone redundancy for hosting plan. Only applicable for Flex Consumption plan.')
param hostingPlanZoneRedundant bool = false

@description('Maximum instance count for Flex Consumption plan. Default: 100. Only applicable when using FlexConsumption tier.')
@minValue(1)
@maxValue(200)
param maximumInstanceCount int = 100

@description('Instance memory in MB for Flex Consumption plan. Allowed: 2048, 4096. Default: 2048. Only applicable when using FlexConsumption tier.')
@allowed([2048, 4096])
param instanceMemoryMB int = 2048

@description('Network isolation? If yes it will create the private endpoints.')
```

**Reason:** Made the hosting plan type configurable via parameters instead of hardcoded values. This allows users to deploy with different plan types (Flex Consumption, Consumption, Premium, or Dedicated) by providing different parameter values during deployment. Defaults are set to Flex Consumption to match the migration goal.

---

### Change 2: Added isFlexConsumptionPlan variable
**Line:** ~883-884  
**Before:**
```bicep
module hostingPlan './modules/compute/hosting-plan.bicep' = {
```

**After:**
```bicep
// Determine if plan is Flex Consumption based on SKU tier
var isFlexConsumptionPlan = hostingPlanSkuTier == 'FlexConsumption'

module hostingPlan './modules/compute/hosting-plan.bicep' = {
```

**Reason:** Added a variable to determine if the plan is Flex Consumption based on the SKU tier. This is used throughout the template to conditionally configure resources based on the plan type.

---

### Change 3: Updated hosting plan module call to use parameters
**Line:** ~886-897  
**Before:**
```bicep
module hostingPlan './modules/compute/hosting-plan.bicep' = {
  scope : resourceGroup
  name: 'hostingPlan'
  params: {
    name: hostingPlanName
    location: location
    kind: 'functionapp'
    skuTier: 'FlexConsumption'
    skuName: 'FC1'
    zoneRedundant: false
    tags: tags
  }
}
```

**After:**
```bicep
module hostingPlan './modules/compute/hosting-plan.bicep' = {
  scope : resourceGroup
  name: 'hostingPlan'
  params: {
    name: hostingPlanName
    location: location
    kind: hostingPlanKind
    skuTier: hostingPlanSkuTier
    skuName: hostingPlanSkuName
    zoneRedundant: hostingPlanZoneRedundant
    tags: tags
  }
}
```

**Reason:** Updated the hosting plan module call to use configurable parameters instead of hardcoded values. This allows the plan type to be configured via deployment parameters.

---

### Change 4: Added deployment container to function storage account
**Line:** ~862-867  
**Before:**
```bicep
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    networkAcls : {
```

**After:**
```bicep
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    // Create deployment container for Flex Consumption plan (required for deployment.storage)
    containers: (hostingPlanSkuTier == 'FlexConsumption') ? [
      {
        name: 'deployment'
      }
    ] : []
    networkAcls : {
```

**Reason:** Flex Consumption plans require a deployment container in the storage account when using `deployment.storage` configuration. This creates the "deployment" container automatically when using Flex Consumption plan.

---

### Change 5: Updated function app module call to use Flex Consumption parameters
**Line:** ~948-957  
**Before:**
```bicep
    networkIsolation: _networkIsolation
    virtualNetworkSubnetId : _networkIsolation?vnet.outputs.appServicesSubId:''
    // Flex Consumption plan configuration
    isFlexConsumption: true
    maximumInstanceCount: 100
    instanceMemoryMB: 2048
```

**After:**
```bicep
    networkIsolation: _networkIsolation
    virtualNetworkSubnetId : _networkIsolation?vnet.outputs.appServicesSubId:''
    // Hosting plan configuration - dynamically set based on plan type
    isFlexConsumption: isFlexConsumptionPlan
    maximumInstanceCount: maximumInstanceCount
    instanceMemoryMB: instanceMemoryMB
```

**Reason:** Updated the function app module call to use configurable parameters instead of hardcoded values. The `isFlexConsumption` flag is now dynamically determined based on the plan type, and the instance count and memory parameters are configurable.

---

## File: `.azure/honkamp/config.json`

### Change: Fixed truncated userPrincipalId GUID
**Line:** 7  
**Before:**
```json
      "userPrincipalId": "c3aa3e6f-8df8-4f1f-955a-35",
```

**After:**
```json
      "userPrincipalId": "c3aa3e6f-8df8-4f1f-955a-35374161c6ce",
```

**Reason:** The `userPrincipalId` was truncated (missing the last 12 characters of the GUID). This caused Cosmos DB role assignment failures because Azure requires a valid 36-character GUID format. Fixed by adding the complete GUID.

---

## File: `.azure/honkamp-new/config.json`

### Change: Fixed truncated userPrincipalId GUID
**Line:** 7  
**Before:**
```json
      "userPrincipalId": "c3aa3e6f-8df8-4f1f-955a-35",
```

**After:**
```json
      "userPrincipalId": "c3aa3e6f-8df8-4f1f-955a-35374161c6ce",
```

**Reason:** Same issue as above - the `userPrincipalId` was truncated in the `honkamp-new` environment configuration. This caused multiple role assignment failures during deployment. Fixed by adding the complete GUID.

---

## File: `CHANGE_TRACKER.md`

### Change: Updated change tracker with plan type configuration section
**Line:** ~65-90  
**Before:**
```markdown
### Deployment Notes
- Flex Consumption plan requires specific storage account SKU (Standard_LRS)
- Function app kind must be 'functionapp,linux' (already correct)
- No need for traditional App Service Plan resource
- May require function app recreation if existing plan is incompatible
```

**After:**
```markdown
### Deployment Notes
- Flex Consumption plan requires specific storage account SKU (Standard_LRS)
- Function app kind must be 'functionapp,linux' (already correct)
- No need for traditional App Service Plan resource
- May require function app recreation if existing plan is incompatible

#### 4. Plan Type Configuration (NEW)
- **Before**: Plan type was hardcoded to Flex Consumption (FC1) in main.bicep
- **After**: Plan type is now fully configurable via parameters
- **Changes Made**:
  - Added parameters to `main.bicep`:
    - `hostingPlanSkuTier` (default: 'FlexConsumption') - Options: FlexConsumption, Dynamic, ElasticPremium, Standard
    - `hostingPlanSkuName` (default: 'FC1') - Options: FC1, Y1, EP1/EP2/EP3, S1/S2/S3, P0v3/P1v3/P2v3/P3v3
    - `hostingPlanKind` (default: 'functionapp')
    - `hostingPlanZoneRedundant` (default: false)
    - `maximumInstanceCount` (default: 100) - For Flex Consumption only
    - `instanceMemoryMB` (default: 2048) - For Flex Consumption only
  - Updated hosting plan module call to use parameters instead of hardcoded values
  - Updated function app module call to dynamically set `isFlexConsumption` based on plan type
  - Added variable `isFlexConsumptionPlan` to determine plan type automatically
- **Impact**: You can now deploy with different plan types (Consumption, Premium, Dedicated) by providing different parameter values during deployment
- **Usage**: 
  - For Flex Consumption: Use default values or set `hostingPlanSkuTier: 'FlexConsumption'`, `hostingPlanSkuName: 'FC1'`
  - For Consumption: Set `hostingPlanSkuTier: 'Dynamic'`, `hostingPlanSkuName: 'Y1'`
  - For Premium: Set `hostingPlanSkuTier: 'ElasticPremium'`, `hostingPlanSkuName: 'EP1'` (or EP2/EP3)
  - For Dedicated: Set `hostingPlanSkuTier: 'Standard'`, `hostingPlanSkuName: 'S1'` (or S2/S3)
```

**Reason:** Documented the new plan type configuration feature that allows users to deploy with different hosting plan types via parameters instead of hardcoded values.

---

## Summary of Changes

### Files Modified: 6
1. `infra/modules/compute/functionApp.bicep` - 5 changes
2. `infra/modules/compute/hosting-plan.bicep` - 2 changes
3. `infra/main.bicep` - 5 changes
4. `.azure/honkamp/config.json` - 1 change
5. `.azure/honkamp-new/config.json` - 1 change
6. `CHANGE_TRACKER.md` - 1 change

### Total Changes: 15
- **Flex Consumption Compatibility**: 8 changes
- **Configuration Improvements**: 5 changes
- **Bug Fixes**: 2 changes (truncated GUIDs)

### Key Improvements
1. ✅ Made hosting plan type fully configurable via parameters
2. ✅ Removed unsupported app settings for Flex Consumption (`FUNCTIONS_WORKER_RUNTIME`, `ENABLE_ORYX_BUILD`, `SCM_DO_BUILD_DURING_DEPLOYMENT`)
3. ✅ Removed unsupported site configuration for Flex Consumption (`linuxFxVersion`)
4. ✅ Added `functionAppConfig` with runtime, scaling, and deployment configuration for Flex Consumption
5. ✅ Created deployment container in storage account for Flex Consumption
6. ✅ Fixed truncated GUID issues in environment configuration files

---

## Deployment Notes

- All changes are backward compatible - existing deployments will continue to work with default Flex Consumption settings
- Plan type can be changed by providing different parameter values during deployment
- The deployment container is automatically created when using Flex Consumption plan
- All Flex Consumption-specific configurations are conditionally applied based on the plan type

---

*Generated: 2025-01-XX*
*Migration: App Service Plan (S3) → Flex Consumption Plan (FC1)*

