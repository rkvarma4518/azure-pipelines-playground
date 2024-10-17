// Parameters
param webAppName string = 'myWebApp' // Name for your Azure Web App
param imageName string = 'depdocker.azurecr.io/hello-world:latest' // Your ACR image
param acrRegistryName string = 'depdocker' // Your ACR registry name
param location string = resourceGroup().location
param appServicePlanName string = '${webAppName}-plan'

// App Service Plan SKU
param appServiceSku3 object = {
  name: 'EP3'
}


// ACR Resource reference
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrRegistryName
  scope: resourceGroup('deploy')
}

// App Service Plan for the Web App
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: appServiceSku3
  kind: 'elastic,linux'
  properties: {
    reserved: true
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 10
    isSpot: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

// Azure Web App resource
resource appContainer 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${imageName}' // Specify the Docker image
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '8000' // Specify the port your app listens on
        }
      ]
    }
  }
}
