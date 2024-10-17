param imageName string = 'depdocker.azurecr.io/hello-world:latest' // Your ACR image
param acrRegistryName string = 'depdocker' // Your ACR registry name
param location string = resourceGroup().location // Location of the resource group

// Reference to existing ACR in the 'deploy' resource group
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrRegistryName
  scope: resourceGroup('deploy') // Specify the correct resource group name
}

// Create a Container App Environment
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' = {
  name: 'myContainerAppEnvironment' // Change to your desired environment name
  location: location
  properties: {
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]

  }
}

// Deploy the Container App
resource apiContainer 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'hello-world-container' // Change to your Container App name
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80 // Change as per your app's port
        allowInsecure: false // Change as per your requirement
      }
    }
    template: {
      containers: [
        {
          name: 'hello-world' // Change this as per your container naming convention
          image: imageName // Use the provided image name
          resources: {
            cpu: 0.5 // Specify CPU requirements
            memory: '1Gi' // Specify Memory requirements
          }
        }
      ]
    }
  }
}
