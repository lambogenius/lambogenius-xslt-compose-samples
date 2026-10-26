<#
.SYNOPSIS
    Runs every workflow of the Basics sample against the running app and checks the results.
.DESCRIPTION
    Start the sample first with ./run.ps1 (in another window). Exits with 1 when a check fails.
#>
[CmdletBinding()]
param([string]$BaseUrl = 'http://localhost:7181')

Import-Module (Join-Path $PSScriptRoot '../shared/scripts/XsltSample.psm1') -Force
Set-Location $PSScriptRoot

Step '1. order-to-sales-order: a deployed map that imports a shared module, with a parameter from the query string.'
$r = Invoke-XsltWorkflow 'order-to-sales-order' 'requests/order.xml' -BaseUrl $BaseUrl
$order = [xml]$r.Text
Check 'HTTP 200, XML' ($r.Status -eq 200 -and $r.ContentType -like 'application/xml*') "($($r.Status) $($r.ContentType))"
Check 'order number normalized by the imported module (ORD-1001)' ($order.SalesOrder.OrderNumber -eq 'ORD-1001')
Check 'three lines, total 59.48 for 6 units' (@($order.SalesOrder.Lines.Line).Count -eq 3 -and $order.SalesOrder.Total.'#text' -eq '59.48' -and $order.SalesOrder.Total.units -eq '6')
Check 'default currency CAD' ($order.SalesOrder.Currency -eq 'CAD')
Check 'a later action read the total with xpath() (X-Order-Total header)' ("$($r.Headers['X-Order-Total'])" -eq '59.48') "($($r.Headers['X-Order-Total']))"
Show $r.Text
$r = Invoke-XsltWorkflow 'order-to-sales-order' 'requests/order.xml' -BaseUrl $BaseUrl -Query 'currency=USD'
Check '?currency=USD becomes the map parameter' (([xml]$r.Text).SalesOrder.Currency -eq 'USD')

Step '2. inline-map: the stylesheet is in the workflow definition.'
$r = Invoke-XsltWorkflow 'inline-map' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'HTTP 200, text/plain: ord-1001|C100|3|6' ($r.Status -eq 200 -and $r.ContentType -like 'text/plain*' -and $r.Text -eq 'ord-1001|C100|3|6') "($($r.Status) '$($r.Text)')"

Step '3. order-report-html: xsl:output method="html".'
$r = Invoke-XsltWorkflow 'order-report-html' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'HTTP 200, text/html' ($r.Status -eq 200 -and $r.ContentType -like 'text/html*') "($($r.Status) $($r.ContentType))"
Check 'a table with a header row and three order lines' (([regex]::Matches($r.Text, '<tr>')).Count -eq 4)
Check 'the title parameter is used' ($r.Text -match '<h1>Order report: ord-1001</h1>')

Step '4. order-lines-csv: text output, quotes escaped.'
$r = Invoke-XsltWorkflow 'order-lines-csv' 'requests/order.xml' -BaseUrl $BaseUrl
$rows = $r.Text.TrimEnd("`n") -split "`n"
Check 'HTTP 200, text/csv' ($r.Status -eq 200 -and $r.ContentType -like 'text/csv*') "($($r.Status) $($r.ContentType))"
Check 'a header and three rows' ($rows.Count -eq 4 -and $rows[0] -eq 'order,line,sku,description,quantity,unit_price')
Check 'quotes in a description are doubled' ($rows[3] -eq 'ord-1001,3,abc-02,"Widget ""Pro"" & case",3,5.00') "($($rows[3]))"
Check 'PowerShell reads it back as CSV' ((@($r.Text | ConvertFrom-Csv)[2].description) -eq 'Widget "Pro" & case')
Show $r.Text

Step '5. order-to-json: the map writes JSON text, the workflow returns it as an object.'
$r = Invoke-XsltWorkflow 'order-to-json' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'HTTP 200, application/json' ($r.Status -eq 200 -and $r.ContentType -like 'application/json*') "($($r.Status) $($r.ContentType))"
Check 'numbers are numbers and strings are escaped' ($r.Body.lines.Count -eq 3 -and $r.Body.lines[1].unitPrice -eq 24.5 -and $r.Body.lines[2].description -eq 'Widget "Pro" & case' -and $r.Body.units -eq 6)

Step '6. error-handling: the action runs in a Scope; failures are caught.'
$r = Invoke-XsltWorkflow 'error-handling' 'requests/order.xml' -BaseUrl $BaseUrl
Check 'a good order: HTTP 200' ($r.Status -eq 200)
$r = Invoke-XsltWorkflow 'error-handling' 'requests/malformed-order.xml' -BaseUrl $BaseUrl
Check 'malformed XML: HTTP 400 with InvalidXml and the line number' ($r.Status -eq 400 -and $r.Body.message -match 'InvalidXml' -and $r.Body.message -match 'line') "($($r.Status) $($r.Text))"
Show $r.Body.message

Complete-Demo
