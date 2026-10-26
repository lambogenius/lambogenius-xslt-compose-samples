<#
.SYNOPSIS
    Runs every sample's demo, one sample at a time: starts the sample with its run.ps1, runs its demo.ps1, stops it.
.DESCRIPTION
    Logs go to <sample>/logs/run-all.log. Exits with 1 when any demo fails. Everything a sample starts (Azurite, the
    Function, the Logic Apps runtime) is stopped before the next sample starts.
.EXAMPLE
    ./test-all.ps1
    ./test-all.ps1 -Sample 02-workflow-variables
#>
[CmdletBinding()]
param(
    [string[]]$Sample = @('01-basics', '02-workflow-variables', '03-csharp-scripts', '04-azure-functions')
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'shared/scripts/XsltSample.psm1') -Force
$ports = @{ '01-basics' = 7181; '02-workflow-variables' = 7182; '03-csharp-scripts' = 7183; '04-azure-functions' = 7184 }
$results = [System.Collections.Generic.List[object]]::new()
$pwsh = (Get-Process -Id $PID).Path

foreach ($name in $Sample) {
    $dir = Join-Path $PSScriptRoot $name
    $port = $ports[$name]
    New-Item -ItemType Directory -Force (Join-Path $dir 'logs') | Out-Null
    $log = Join-Path $dir 'logs/run-all.log'
    Write-Host ''
    Write-Host "=== $name (port $port)" -ForegroundColor Cyan
    $run = Start-Process $pwsh -ArgumentList '-NoProfile', '-File', (Join-Path $dir 'run.ps1') -WorkingDirectory $dir -PassThru -WindowStyle Hidden `
        -RedirectStandardOutput $log -RedirectStandardError (Join-Path $dir 'logs/run-all.err.log')
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $callback = "http://localhost:$port/runtime/webhooks/workflow/api/management/workflows?api-version=2020-05-01-preview"
        while ($true) {
            if ($run.HasExited) { throw "run.ps1 exited early; see $log" }
            try { $null = Invoke-RestMethod $callback -TimeoutSec 5; break } catch { }
            if ($watch.Elapsed.TotalSeconds -gt 300) { throw "the app did not start within 300 s; see $log" }
            Start-Sleep -Seconds 2
        }
        Write-Host "started in $([math]::Round($watch.Elapsed.TotalSeconds)) s"
        & $pwsh -NoProfile -File (Join-Path $dir 'demo.ps1')
        $results.Add([pscustomobject]@{ Sample = $name; Result = if ($LASTEXITCODE -eq 0) { 'PASS' } else { 'FAIL' } })
    }
    catch {
        Write-Host "FAIL  $name - $($_.Exception.Message)" -ForegroundColor Red
        $results.Add([pscustomobject]@{ Sample = $name; Result = 'FAIL' })
    }
    finally {
        if (-not $run.HasExited) { taskkill /PID $run.Id /T /F | Out-Null }
        $deadline = (Get-Date).AddSeconds(30)
        while ((Test-Listening $port) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 500 }
    }
}

$results | Format-Table -AutoSize
if ($results | Where-Object Result -ne 'PASS') { exit 1 }
