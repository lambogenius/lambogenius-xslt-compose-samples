<#
.SYNOPSIS
    Builds and runs the "Azure Functions from maps" sample on http://localhost:7184.
    Also starts Azurite and the GetCustomerName Function (port 7180) unless they already run.
    Ctrl+C stops it. Then, in another window: ./demo.ps1, or ./send.ps1 <workflow> <file>.
#>
[CmdletBinding()]
param(
    [int]$Port = 7184,
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Debug'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Start-XsltSample -App $PSScriptRoot -Port $Port -UsesFunction -Configuration $Configuration -Examples @(
    './send.ps1 order-to-sales-order requests/order.xml',
    './send.ps1 enrich-orders requests/batch.xml',
    './send.ps1 enrich-orders requests/batch-unknown-customer.xml',
    './send.ps1 function-not-allowed requests/order.xml'
)
