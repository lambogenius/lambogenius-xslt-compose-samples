<#
.SYNOPSIS
    Builds and runs the "Basics" sample on http://localhost:7181.
    Also starts Azurite unless it already runs.
    Ctrl+C stops it. Then, in another window: ./demo.ps1, or ./send.ps1 <workflow> <file>.
#>
[CmdletBinding()]
param(
    [int]$Port = 7181,
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Debug'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Start-XsltSample -App $PSScriptRoot -Port $Port -Configuration $Configuration -Examples @(
    './send.ps1 order-to-sales-order requests/order.xml',
    './send.ps1 order-to-sales-order requests/order.xml -Query currency=USD',
    './send.ps1 order-report-html requests/order.xml',
    './send.ps1 error-handling requests/malformed-order.xml'
)
