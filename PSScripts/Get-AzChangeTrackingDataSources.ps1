# This script lists the data sources of type 'ChangeTrackingDataTypeConfiguration', which is used by both the 'Change tracking' solution in Azure Automation and in Defender for Cloud's File Integrity Monitoring.
# The script leverages the API as documented here: https://learn.microsoft.com/en-us/rest/api/loganalytics/data-sources/list-by-workspace?tabs=HTTP
#
# Usage: .\AzCheckChangeTrackingDataSource.ps1 -WorkspaceName myworkspace -ResourceGroupName myresource_group -SubscriptionId mysubscription_id
#
# Author = 'José Miguel Constantino'
# LicenseUri = 'https://github.com/josecons-msft/LACoreToolbox/blob/main/LICENSE'
# ProjectUri = 'https://github.com/josecons-msft/LACoreToolbox'
#
# Version history:
# 2023/10/02 - v1.0 - Initial release with (very) basic error handling
# 2023/10/04 - v1.1 - Minor changes to the output

param (
    [string]$SubscriptionId,
    [string]$ResourceGroupName,
    [string]$WorkspaceName
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
$datasourceURI = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/dataSources?`$filter" + "=filter=kind eq 'ChangeTrackingDataTypeConfiguration'&api-version=2020-08-01"
#$datasourceURI #uncomment for verbose
$DSs = (Invoke-RestMethod -Method GET $datasourceURI -Headers $headers).value

Write-Host "" ; ""  

# Check if there are any data sources
if ($DSs.Count -eq 0) {
    Write-Host -ForegroundColor Yellow "No ChangeTrackingDataTypeConfiguration data sources found in the specified workspace."
	Write-Host "=================================================================================================================" 
    exit
}

#$DSs | Select-Object name, @{Name="IsEnabled";Expression={$_.properties.Enabled}}

# List the number of data sources found and it they are enabled or not
Write-Host "=================================================================================================================" 
foreach ($DS in $DSs) {
    Write-Host -ForegroundColor Green "Data type id: " -NoNewline
	Write-Host -ForegroundColor White "$($DS.name) | " -NoNewline
	Write-Host -ForegroundColor Green "Enabled: " -NoNewline
    if ($DS.properties.Enabled -eq $true) {
        Write-Host -ForegroundColor White "$($DS.properties.Enabled)"
    } else {
        Write-Host -ForegroundColor Red "$($DS.properties.Enabled)"
    }
}
Write-Host "=================================================================================================================" 
Write-Host "" ; "" ; "" 