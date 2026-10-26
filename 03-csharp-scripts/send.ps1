<#
.SYNOPSIS
    Sends a request file to one of this sample's workflows and prints the response.
.EXAMPLE
    ./send.ps1 invoice-with-csharp requests/order.xml
    ./send.ps1 inline-script requests/order.xml
    ./send.ps1 timeout-protection requests/order.xml
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('invoice-with-csharp', 'inline-script', 'timeout-protection')]
    [string]$Workflow,

    [Parameter(Mandatory, Position = 1)]
    [string]$File,

    # Extra query string for the trigger, for example 'currency=USD'.
    [string]$Query = '',

    [string]$BaseUrl = 'http://localhost:7183'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot
$response = Invoke-XsltWorkflow $Workflow $File -BaseUrl $BaseUrl -Query $Query
Write-XsltResponse $Workflow (Split-Path $File -Leaf) $response
