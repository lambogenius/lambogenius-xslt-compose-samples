<#
.SYNOPSIS
    Runs every workflow of the Workflow variables sample against the running app and checks the results.
.DESCRIPTION
    Start the sample first with ./run.ps1 (in another window). Exits with 1 when a check fails.
#>
[CmdletBinding()]
param([string]$BaseUrl = 'http://localhost:7182')

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot

Step '1. variables-as-parameters: string, float, boolean and integer variables become XSLT parameters.'
$r = Invoke-XsltWorkflow 'variables-as-parameters' 'requests/order.xml' -BaseUrl $BaseUrl
$invoice = ([xml]$r.Body.invoice).Invoice
Check 'defaults: CAD, standard shipping, all 3 lines, 13% tax, total 67.21' ($r.Status -eq 200 -and $invoice.currency -eq 'CAD' -and $invoice.Shipping.method -eq 'Standard' -and $invoice.Lines.count -eq '3' -and $invoice.Tax.'#text' -eq '7.73' -and $invoice.Total -eq '67.21') "($($r.Status) $($r.Text))"
Check 'a variable set from the result with xpath() (invoiceTotal 67.21)' ($r.Body.invoiceTotal -eq 67.21)
$r = Invoke-XsltWorkflow 'variables-as-parameters' 'requests/order.xml' -BaseUrl $BaseUrl -Query 'currency=USD&maxLines=2' -Headers @{ 'x-expedite' = 'true' }
$invoice = ([xml]$r.Body.invoice).Invoice
Check 'currency=USD, maxLines=2, x-expedite: true change the invoice' ($invoice.currency -eq 'USD' -and $invoice.Lines.count -eq '2' -and $invoice.Shipping.method -eq 'Express' -and $invoice.Total -eq '67.21' -and $r.Body.expedite -eq $true -and $r.Body.maxLines -eq 2) "($($r.Text))"
Show $r.Body.invoice

Step '2. batch-loop: For each over the orders, collecting results in array, integer and float variables.'
$r = Invoke-XsltWorkflow 'batch-loop' 'requests/batch.xml' -BaseUrl $BaseUrl
Check 'HTTP 200, 3 orders processed' ($r.Status -eq 200 -and $r.Body.processed -eq 3) "($($r.Status) $($r.Text))"
Check 'one summary per order, in order' (($r.Body.summaries -join ' | ') -eq 'ORD-1001;C100;59.48 | ORD-1002;C200;24.50 | ORD-1003;C300;100.00') "($($r.Body.summaries -join ' | '))"
Check 'grand total 183.98' ($r.Body.grandTotal -eq '183.98') "($($r.Body.grandTotal))"

Step '3. dynamic-map: a variable picks the map.'
$r = Invoke-XsltWorkflow 'dynamic-map' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'default format=xml runs invoices/order-to-invoice.xslt' ($r.Status -eq 200 -and "$($r.Headers['X-Map-Name'])" -eq 'invoices/order-to-invoice.xslt' -and $r.Text -match '<Invoice') "($($r.Status) $($r.Headers['X-Map-Name']))"
$r = Invoke-XsltWorkflow 'dynamic-map' 'requests/order.xml' -BaseUrl $BaseUrl -Query 'format=text'
Check 'format=text runs invoices/invoice-summary.xslt' ($r.ContentType -like 'text/plain*' -and $r.Text -eq 'Invoice for ORD-1001: 3 lines, 6 units, subtotal 59.48') "($($r.Text))"

Step '4. approval-routing: the map returns a route; a Switch on that variable picks the response.'
$r = Invoke-XsltWorkflow 'approval-routing' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'total 59.48 under the default threshold 100: auto, HTTP 200' ($r.Status -eq 200 -and $r.Body.route -eq 'auto') "($($r.Status) $($r.Text))"
$r = Invoke-XsltWorkflow 'approval-routing' 'requests/order.xml' -BaseUrl $BaseUrl -Query 'threshold=50'
Check 'threshold=50: review, HTTP 202' ($r.Status -eq 202 -and $r.Body.route -eq 'review') "($($r.Status) $($r.Text))"
$r = Invoke-XsltWorkflow 'approval-routing' 'requests/empty-order.xml' -BaseUrl $BaseUrl
Check 'no lines: reject, HTTP 422' ($r.Status -eq 422 -and $r.Body.route -eq 'reject') "($($r.Status) $($r.Text))"

Complete-Demo
