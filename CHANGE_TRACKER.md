# Change Tracker

This document tracks all significant changes, updates, and deployments for the AI Document Processor project.

## Change Log Format

Each entry should include:
- **Date**: Date of change
- **Author**: Person making the change
- **Type**: Type of change (Infrastructure, Application, Configuration, Documentation, etc.)
- **Description**: Brief description of what changed
- **Files Changed**: List of files modified
- **Impact**: What this change affects (deployment, functionality, etc.)
- **Status**: Status of the change (Planned, In Progress, Completed, Rolled Back)
- **Notes**: Any additional notes or concerns

---

## 2025-01-XX - Flex Consumption Plan Migration

### Change Details
- **Date**: 2025-01-XX
- **Author**: [Your Name]
- **Type**: Infrastructure
- **Description**: Migrate Azure Functions from App Service Plan (S3) to Flex Consumption Plan
- **Status**: In Progress
- **Concern**: Honkamp requested Flex Consumption plan. Deployment issues reported by Tharun. Function app, host plan, and storage account all required changes.

### Files Changed
- `infra/modules/compute/hosting-plan.bicep` - Updated for Flex Consumption plan (SKU: FC1, Tier: FlexConsumption)
- `infra/modules/compute/functionApp.bicep` - Updated to work with Flex Consumption (removed alwaysOn, added functionAppConfig)
- `infra/main.bicep` - Updated hosting plan configuration and function app parameters
- `CHANGE_TRACKER.md` - This file

### Changes Required

#### 1. Hosting Plan Changes
- **Before**: App Service Plan with SKU 'S3' (Standard tier)
- **After**: Flex Consumption Plan with SKU 'FC1' and tier 'FlexConsumption'
- **Changes Made**:
  - Updated `hosting-plan.bicep` to support Flex Consumption SKU (FC1)
  - Added parameters: `skuTier` (default: 'FlexConsumption'), `skuName` (default: 'FC1'), `zoneRedundant`
  - Changed `kind` from 'linux' to 'functionapp'
  - Updated `main.bicep` to pass Flex Consumption parameters
- **Impact**: Function app will use serverless Flex Consumption model with automatic scaling

#### 2. Function App Changes
- **Before**: Function app with `alwaysOn: true` and standard App Service Plan configuration
- **After**: Function app configured for Flex Consumption with `functionAppConfig` property
- **Changes Made**:
  - Removed `alwaysOn: true` (not supported in Flex Consumption)
  - Added `functionAppConfig` property with:
    - `runtime`: name and version (python/3.11)
    - `scaleAndConcurrency`: maximumInstanceCount (100) and instanceMemoryMB (2048)
  - Added parameters: `isFlexConsumption` (default: true), `maximumInstanceCount`, `instanceMemoryMB`
  - Updated `main.bicep` to pass Flex Consumption parameters
- **Impact**: Function app will scale automatically based on demand with configurable instance limits

#### 3. Storage Account Changes
- **Before**: Standard storage account configuration
- **After**: Storage account configured with Standard_LRS (required for Flex Consumption)
- **Verification**: Storage accounts already use Standard_LRS SKU, which is compatible with Flex Consumption
- **Impact**: No changes needed - storage accounts are already correctly configured

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

### Known Issues
- Deployment issues reported by Tharun
- Need to verify all dependencies are compatible with Flex Consumption
- May need to update CI/CD pipelines if deployment method changes

### Testing Checklist
- [ ] Validate Bicep templates compile correctly
- [ ] Test deployment in dev environment
- [ ] Verify function app starts correctly
- [ ] Test function execution
- [ ] Verify storage account connectivity
- [ ] Test scaling behavior
- [ ] Verify monitoring and logging

---

## Template Entry (Copy for future changes)

### Change Details
- **Date**: YYYY-MM-DD
- **Author**: [Name]
- **Type**: [Type]
- **Description**: [Description]
- **Status**: [Status]

### Files Changed
- [List files]

### Changes Made
- [List changes]

### Impact
- [Describe impact]

### Notes
- [Any additional notes]

---

