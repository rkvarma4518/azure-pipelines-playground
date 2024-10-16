// Variables
param location string = resourceGroup().location
param appServicePlanName string = 'myAppServicePlan'
param webAppName string = 'myWebApp'
param acrName string = 'depdocker' // Your ACR name
param imageName string = 'hello-world' // Your ACR image name
param imageTag string = 'latest' // The tag of your image

// App Service Plan (Linux)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    tier: 'PremiumV2'
    size: 'P1v2'
  }
  kind: 'Linux'
  reserved: true
}

// Web App (Linux container) with Managed Identity enabled
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  serverFarmId: appServicePlan.id
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned' // Enable Managed Identity
  }
  properties: {
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://depdocker.azurecr.io' // ACR URL
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: listCredentials(resourceId('Microsoft.ContainerRegistry/registries', acrName), '2022-03-01').username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: listCredentials(resourceId('Microsoft.ContainerRegistry/registries', acrName), '2022-03-01').passwords[0].value
        }
      ]
      linuxFxVersion: 'DOCKER|depdocker.azurecr.io/${imageName}:${imageTag}' // Image from ACR
    }
  }
}

// Give the App Service access to ACR (optional: if needed for private ACR)
resource acr 'Microsoft.ContainerRegistry/registries@2022-03-01' existing = {
  name: acrName
}

// Assign ACR Pull role to the App Service Managed Identity
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: acr
  roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role
  principalId: webApp.identity.principalId
  // Generate a new GUID for the role assignment
  name: guid(webApp.id, acr.id, 'AcrPullRoleAssignment')
}
