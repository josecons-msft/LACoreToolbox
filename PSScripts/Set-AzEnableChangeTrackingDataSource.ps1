# This script enables or disables the different data sources associated with 'Change tracking' solution in Azure Automation. This is particular useful if you've enabled Defender for Cloud's File Integrity Monitoring,
# but also want to use any of the other features.
# The script leverages the API as documented here: https://learn.microsoft.com/en-us/rest/api/loganalytics/data-sources/list-by-workspace?tabs=HTTP
#
# Usage: .\Enable-AzEnableChangeTrackingDataSource.ps1 -WorkspaceName myworkspace -ResourceGroupName myresource_group -SubscriptionId mysubscription_id -DataTypeId datatypename -Enabled True/False
#
# Author = 'José Miguel Constantino'
# LicenseUri = 'https://github.com/josecons-msft/LACoreToolbox/blob/main/LICENSE'
# ProjectUri = 'https://github.com/josecons-msft/LACoreToolbox'
#
# Version history:
# 2023/10/04 - v1.0 - Initial release with (very) basic error handling
# 2023/10/04 - v1.1 - Renamed script and changed scope of script to do both operations of enabling and disabling


param (
    [string]$SubscriptionId,
    [string]$ResourceGroupName,
    [string]$WorkspaceName,
     [Parameter(Mandatory)]
     [ValidateSet("Daemons","Files","Inventory","Registry","Software","WindowsServices")]
     $DataTypeId,
     [Parameter(Mandatory)]
     [ValidateSet("True","False")]
     $Enabled              
     )
     

# Check if the parameters are empty
if (-not $WorkspaceName) {
    throw "The 'WorkspaceName' parameter cannot be empty."
}

if (-not $ResourceGroupName) {
    throw "The 'ResourceGroupName' parameter cannot be empty."
}


if (-not $SubscriptionId) {
    throw "The 'SubscriptionId' parameter cannot be empty."
}

if (-not $DataTypeId) {
    throw "The 'DataTypeId' parameter cannot be empty."
}

if (-not $Enabled) {
    throw "The 'Enabled' parameter cannot be empty."
}


# Function to get Azure access token
function Get-AccessTokenFromContext
        {
        try {
            $accesstoken = (New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient([Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile)).AcquireAccessToken((Get-AzContext).Subscription.TenantId).AccessToken
            $buildheaders = @{
                'Authorization' = "Bearer $accesstoken"
                'Content-Type' = "application/json"
                        }
            return $buildheaders
            }
        catch
            {
                Write-Output "No context found! Please run 'Login-AzAccount' to login to Azure"
                break
            }
        }

$headers = Get-AccessTokenFromContext
$datasourceURI = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/dataSources/ChangeTrackingDataTypeConfiguration_$DataTypeId"+"?api-version=2020-08-01"
#$datasourceURI #uncomment for verbose
$bodyEnable = "
{
	kind: 'ChangeTrackingDataTypeConfiguration',
	properties: {
        'DataTypeId': '$DataTypeId',
        'Enabled': '$Enabled'
      }
}" 
#$bodyEnable #uncomment for verbose

Invoke-RestMethod -Method PUT $datasourceURI -Headers $headers -body $bodyEnable