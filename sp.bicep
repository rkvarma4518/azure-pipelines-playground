@description('Array of service principle details.')
param sp_details string
var sp = json(sp_details)
