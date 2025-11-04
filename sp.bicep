@description('Array of service principle details.')
param sp_details string
var sp_details = json(sp_details)
