@description('Name of the hosting plan.')
param name string
@description('Location for the hosting plan.')
param location string = resourceGroup().location
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

@description('Tags.')
param tags object

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: name
  location: location
  kind: kind
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: true
    zoneRedundant: (skuTier == 'FlexConsumption') ? zoneRedundant : null
  }
  tags: tags
}

output id string = hostingPlan.id
output name string = hostingPlan.name
output location string = hostingPlan.location
output skuName string = hostingPlan.sku.name