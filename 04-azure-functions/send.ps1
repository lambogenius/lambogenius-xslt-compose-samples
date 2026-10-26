<#
.SYNOPSIS
    Sends a request file to one of this sample's workflows and prints the response.
.EXAMPLE
    ./send.ps1 order-to-sales-order requests/order.xml
    ./send.ps1 enrich-orders requests/batch.xml
    ./send.ps1 enrich-orders requests/batch-unknown-customer.xml
    ./send.ps1 function-not-allowed requests/order.xml
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('order-to-sales-order', 'enrich-orders', 'function-not-allowed')]
    [string]$Workflow,

    [Parameter(Mandatory, Position = 1)]
    [string]$File,

    # Extra query string for the trigger, for example 'currency=USD'.
    [string]$Query = '',

    [string]$BaseUrl = 'http://localhost:7184'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot
$response = Invoke-XsltWorkflow $Workflow $File -BaseUrl $BaseUrl -Query $Query
Write-XsltResponse $Workflow (Split-Path $File -Leaf) $response
