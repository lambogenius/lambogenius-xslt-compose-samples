<#
.SYNOPSIS
    Runs every workflow of the Azure Functions sample against the running app and checks the results.
.DESCRIPTION
    Start the sample first with ./run.ps1 (in another window); it also starts the GetCustomerName Function on port
    7180. Exits with 1 when a check fails.
#>
[CmdletBinding()]
param([string]$BaseUrl = 'http://localhost:7184')

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot

Step '1. order-to-sales-order: an imported module, a C# helper and an Azure Function call in one map.'
$r = Invoke-XsltWorkflow 'order-to-sales-order' 'requests/order.xml' -BaseUrl $BaseUrl
$order = ([xml]$r.Text).SalesOrder
Check 'HTTP 200, XML' ($r.Status -eq 200 -and $r.ContentType -like 'application/xml*') "($($r.Status) $($r.Text))"
Check 'customer name from the Function (Acme Supplies), one call' ($order.Customer.Name -eq 'Acme Supplies' -and "$($r.Headers['X-Function-Calls'])" -eq '1') "($($order.Customer.Name), calls $($r.Headers['X-Function-Calls']))"
Check 'SKUs normalized, amounts formatted by C#' (@($order.Lines.Line)[0].Sku -eq 'ABC-01' -and @($order.Lines.Line)[0].Amount -eq '19.98')
Check 'a later action read the name (X-Customer-Name header)' ("$($r.Headers['X-Customer-Name'])" -eq 'Acme Supplies')
Show $r.Text

Step '2. enrich-orders: four orders, three distinct customers.'
$r = Invoke-XsltWorkflow 'enrich-orders' 'requests/batch.xml' -BaseUrl $BaseUrl
$orders = @(([xml]$r.Text).Orders.Order)
Check 'HTTP 200 with four enriched orders' ($r.Status -eq 200 -and $orders.Count -eq 4) "($($r.Status) $($r.Text))"
Check 'names from the Function, Unicode intact' ((($orders | ForEach-Object CustomerName) -join ' | ') -eq 'Acme Supplies | Globex Retail | Acme Supplies | Initech Ltd. – Études') "($(($orders | ForEach-Object CustomerName) -join ' | '))"
Check 'C100 appears twice but is looked up once: 3 calls, 1 cache hit' ("$($r.Headers['X-Function-Calls'])" -eq '3' -and "$($r.Headers['X-Function-Cache-Hits'])" -eq '1') "(calls $($r.Headers['X-Function-Calls']), hits $($r.Headers['X-Function-Cache-Hits']))"

Step '3. enrich-orders with an unknown customer: the Function answers 404, the action fails, the workflow catches it.'
$r = Invoke-XsltWorkflow 'enrich-orders' 'requests/batch-unknown-customer.xml' -BaseUrl $BaseUrl
Check 'HTTP 502 with FunctionHttpFailed naming the alias' ($r.Status -eq 502 -and $r.Body.message -match 'FunctionHttpFailed' -and $r.Body.message -match 'GetCustomerName') "($($r.Status) $($r.Text))"
Check 'the error does not contain the looked-up value' ($r.Body.message -notmatch 'C999')
Show $r.Body.message

Step '4. function-not-allowed: the action does not allow GetCustomerName.'
$r = Invoke-XsltWorkflow 'function-not-allowed' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'HTTP 403 with FunctionNotAllowed' ($r.Status -eq 403 -and $r.Body.message -match 'FunctionNotAllowed') "($($r.Status) $($r.Text))"
Show $r.Body.message

Complete-Demo
