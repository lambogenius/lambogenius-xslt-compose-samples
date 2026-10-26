<#
.SYNOPSIS
    Builds and runs the "C# scripts" sample on http://localhost:7183.
    Also starts Azurite unless it already runs.
    Ctrl+C stops it. Then, in another window: ./demo.ps1, or ./send.ps1 <workflow> <file>.
#>
[CmdletBinding()]
param(
    [int]$Port = 7183,
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Debug'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Start-XsltSample -App $PSScriptRoot -Port $Port -Configuration $Configuration -Examples @(
    './send.ps1 invoice-with-csharp requests/order.xml',
    './send.ps1 inline-script requests/order.xml',
    './send.ps1 timeout-protection requests/order.xml'
)
