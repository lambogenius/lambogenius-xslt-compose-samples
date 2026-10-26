<#
.SYNOPSIS
    Builds and runs the "Workflow variables" sample on http://localhost:7182.
    Also starts Azurite unless it already runs.
    Ctrl+C stops it. Then, in another window: ./demo.ps1, or ./send.ps1 <workflow> <file>.
#>
[CmdletBinding()]
param(
    [int]$Port = 7182,
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Debug'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Start-XsltSample -App $PSScriptRoot -Port $Port -Configuration $Configuration -Examples @(
    './send.ps1 variables-as-parameters requests/order.xml -Query "currency=USD&maxLines=2"',
    './send.ps1 batch-loop requests/batch.xml',
    './send.ps1 dynamic-map requests/order.xml -Query format=text',
    './send.ps1 approval-routing requests/order.xml -Query threshold=50'
)
