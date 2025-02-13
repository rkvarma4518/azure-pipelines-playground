// Parameters
// param containerGroupName string = 'myContainerGroup'
// param containerName string = 'my-container'
param containerGroupName string
param containerName string
param imageName string = 'depdocker.azurecr.io/hello-world:latest' // Your ACR image
param cpuCores int = 1
param memoryGb int = 2 // Use int for memory size
param location string = resourceGroup().location
param acrRegistryName string = 'devdoc' // Your ACR registry name

output containerGroupName string = containerGroupName
output containerName string = containerName

