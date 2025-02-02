@description('The principal id of the Service Principal to assign permissions to the Gallery.')
param principalId string

@description('Resource ID of an existing Azure Compute Gallery to use for the Dev Box Definitions.')
param galleryName string

@allowed([ 'Reader', 'Contributor', 'Owner' ])
param role string = 'Reader'

var assignmentId = guid('gallery${role}${resourceGroup().id}${galleryName}${principalId}')

var roleIdBase = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions'

// docs: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#reader
var readerRoleId = '${roleIdBase}/acdd72a7-3385-48ef-bd42-f606fba81ae7'
// docs: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor
var contributorRoleId = '${roleIdBase}/b24988ac-6180-42a0-ab88-20f7382dd24c'
// docs: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner
var ownerRoleId = '${roleIdBase}/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

var roleId = role == 'Owner' ? ownerRoleId : role == 'Contributor' ? contributorRoleId : readerRoleId

resource computeGallery 'Microsoft.Compute/galleries@2022-01-03' existing = {
  name: galleryName
}

resource galleryAssignmentId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: assignmentId
  properties: {
    roleDefinitionId: roleId
    principalId: principalId
  }
  scope: computeGallery
}
