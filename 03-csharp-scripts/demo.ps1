<#
.SYNOPSIS
    Runs every workflow of the C# scripts sample against the running app and checks the results.
.DESCRIPTION
    Start the sample first with ./run.ps1 (in another window). Exits with 1 when a check fails.
#>
[CmdletBinding()]
param([string]$BaseUrl = 'http://localhost:7183')

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot

Step '1. invoice-with-csharp: msxsl:script C# helpers in a deployed map.'
$r = Invoke-XsltWorkflow 'invoice-with-csharp' 'requests/order.xml' -BaseUrl $BaseUrl
$invoice = ([xml]$r.Text).Invoice
Check 'HTTP 200, XML' ($r.Status -eq 200 -and $r.ContentType -like 'application/xml*') "($($r.Status) $($r.Text))"
Check 'reference with a Luhn check digit (ORD-1001-7)' ($invoice.Reference -eq 'ORD-1001-7')
Check 'date formatted (20 Oct 2026) and postal code cleaned up (M5X 1A9)' ($invoice.Date -eq '20 Oct 2026' -and $invoice.ShipTo.PostalCode -eq 'M5X 1A9')
Check 'descriptions in title case, money formatted' (@($invoice.Lines.Line)[1].Description -eq 'Gadget, Large' -and $invoice.Total -eq '59.48 CAD')
Check 'bool helper: every SKU valid' (@($invoice.Lines.Line | Where-Object valid -ne 'true').Count -eq 0)
Show $r.Text
$first = "$($r.Headers['X-Compile-Cache-Hit'])"
$r = Invoke-XsltWorkflow 'invoice-with-csharp' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'the compiled map is cached: a later run is a cache hit' ("$($r.Headers['X-Compile-Cache-Hit'])" -eq 'True') "(first: $first, second: $($r.Headers['X-Compile-Cache-Hit']))"

Step '2. inline-script: an inline map with a C# helper.'
$r = Invoke-XsltWorkflow 'inline-script' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'one cleaned-up address line' ($r.Status -eq 200 -and $r.Text -eq 'ACME SUPPLIES, 100 King St W, Toronto ON M5X 1A9') "($($r.Status) '$($r.Text)')"

Step '3. timeout-protection: a C# loop that never ends is stopped at the action deadline (5 s).'
$r = Invoke-XsltWorkflow 'timeout-protection' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'HTTP 504 with TransformationTimeout' ($r.Status -eq 504 -and $r.Body.message -match 'TransformationTimeout') "($($r.Status) $($r.Text))"
Check "answered in about 5 s (took $([math]::Round($r.Seconds, 1)) s)" ($r.Seconds -ge 4 -and $r.Seconds -lt 30)
Show $r.Body.message
$r = Invoke-XsltWorkflow 'invoice-with-csharp' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'the next transformation works: the stuck worker was replaced' ($r.Status -eq 200)

Complete-Demo
