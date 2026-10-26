<#
.SYNOPSIS
    Sends a request file to one of this sample's workflows and prints the response.
.EXAMPLE
    ./send.ps1 order-to-sales-order requests/order.xml
    ./send.ps1 order-to-sales-order requests/order.xml -Query currency=USD
    ./send.ps1 order-report-html requests/order.xml
    ./send.ps1 error-handling requests/malformed-order.xml
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('order-to-sales-order', 'inline-map', 'order-report-html', 'order-lines-csv', 'order-to-json', 'error-handling')]
    [string]$Workflow,

    [Parameter(Mandatory, Position = 1)]
    [string]$File,

    # Extra query string for the trigger, for example 'currency=USD'.
    [string]$Query = '',

    [string]$BaseUrl = 'http://localhost:7181'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot
$response = Invoke-XsltWorkflow $Workflow $File -BaseUrl $BaseUrl -Query $Query
Write-XsltResponse $Workflow (Split-Path $File -Leaf) $response
