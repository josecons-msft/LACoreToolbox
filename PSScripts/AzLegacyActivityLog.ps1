# This script lists the data sources of type 'AzureActivityLog', which is the legacy method of collecting Azure Activity Logs. After listing the data sources, it provides the option to delete then.
# The script leverages two existing PS cmdlets to achieve its goal in an easy and faster way. The two cmdlets are: Get-AzOperationalInsightsDataSource and Remove-AzOperationalInsightsDataSource
#
# Usage: .\AzLegacyActivityLog.ps1 -workspace myworkspace -resourceGroup myresource group
#
# Author = 'José Miguel Constantino'
# LicenseUri = 'https://github.com/josecons-msft/LACoreToolbox/blob/main/LICENSE'
# ProjectUri = 'https://github.com/josecons-msft/LACoreToolbox'
#
# Version history:
# 2023/03/2023 - v1.0 - Initial release with Basic error handling


[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$workspace,
    [Parameter(Mandatory=$true)]
    [string]$resourceGroup
)

# Check if the parameters are empty
if (-not $workspace) {
    throw "The 'workspace' parameter cannot be empty."
}

if (-not $resourceGroup) {
    throw "The 'resourceGroup' parameter cannot be empty."
}

 try
	{   
		clear
		$wksp = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroup -Name $workspace -ErrorAction Stop
	}
 catch
	{
		Write-Host -ForegroundColor Yellow "Cannot get the workspace details. Please check the error details for more information"
		Write-Host -ForegroundColor White "===============================================================================================" 
		Write-Host -ForegroundColor DarkYellow "$PSItem.Exception"
		Write-Host -ForegroundColor White "===============================================================================================" 
		break
	}

Write-Host "" ; "" ; "" 
Write-Host -ForegroundColor Green "Workspace URI: " $wksp.ResourceId
Write-Host "=================================================================================================================" 

# Get the AzureActivityLog data sources for the specified subscription
$dataSources = Get-AzOperationalInsightsDataSource -WorkspaceName $workspace -ResourceGroupName $resourceGroup -Kind AzureActivityLog

# Check if there are any data sources
if ($dataSources.Count -eq 0) {
    Write-Host "No AzureActivityLog legacy data sources found"
	Write-Host "=================================================================================================================" 
    exit
}

# List the number of data sources found
Write-Host -ForegroundColor Green "Number of AzureActivityLog legacy data sources found: $($dataSources.Count)"
Write-Host  "=================================================================================================================" 

# Loop through the data sources and display the name and the source subscriptionID
foreach ($dataSource in $dataSources) {
    Write-Host -ForegroundColor Green "Data source name: " -NoNewline
	Write-Host -ForegroundColor White "$($dataSource.Name) | " -NoNewline
	Write-Host -ForegroundColor Green "Source subscription ID: " -NoNewline
	Write-Host -ForegroundColor White "$($dataSource.Properties.SubscriptionId)"
}
Write-Host "=================================================================================================================" 
Write-Host "" ; "" ; "" 


# Loop again thru the data sources so we can select which ones to remove
foreach ($dataSource in $dataSources) {
	$response = Read-Host "Do you want to remove data source $($dataSource.Name)? (Y/N)"
	if ($response -eq "Y" -or $response -eq "y") {
		Remove-AzOperationalInsightsDataSource -WorkspaceName $workspace -ResourceGroupName $resourceGroup -Name $dataSource.Name
		Write-Host "Data source $($dataSource.Name) has been removed"
}
}
Write-Host "================================================================================================================="
Write-Host "" ; "" ; "" 
