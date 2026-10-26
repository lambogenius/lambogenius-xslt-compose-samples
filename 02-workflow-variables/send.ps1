<#
.SYNOPSIS
    Sends a request file to one of this sample's workflows and prints the response.
.EXAMPLE
    ./send.ps1 variables-as-parameters requests/order.xml -Query "currency=USD&maxLines=2"
    ./send.ps1 batch-loop requests/batch.xml
    ./send.ps1 dynamic-map requests/order.xml -Query format=text
    ./send.ps1 approval-routing requests/order.xml -Query threshold=50
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('variables-as-parameters', 'batch-loop', 'dynamic-map', 'approval-routing')]
    [string]$Workflow,

    [Parameter(Mandatory, Position = 1)]
    [string]$File,

    # Extra query string for the trigger, for example 'currency=USD'.
    [string]$Query = '',

    [string]$BaseUrl = 'http://localhost:7182'
)

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot
$response = Invoke-XsltWorkflow $Workflow $File -BaseUrl $BaseUrl -Query $Query
Write-XsltResponse $Workflow (Split-Path $File -Leaf) $response
