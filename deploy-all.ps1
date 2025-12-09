#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Budget Pillars to all platforms (Android + Web)

.DESCRIPTION
    Master deployment script that builds and deploys both Android APK to GitHub Releases
    and Web App to Firebase Hosting.

.PARAMETER Version
    Version number in format X.Y.Z (e.g., 1.0.1)

.PARAMETER ReleaseNotes
    Release notes for the GitHub release

.PARAMETER AndroidOnly
    Deploy only Android (skip web)

.PARAMETER WebOnly
    Deploy only Web (skip Android)

.EXAMPLE
    .\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes and new landing page"
    .\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes" -AndroidOnly
    .\deploy-all.ps1 -WebOnly
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$ReleaseNotes,
    
    [switch]$AndroidOnly,
    [switch]$WebOnly
)

# Validate parameters
if (!$WebOnly -and (!$Version -or !$ReleaseNotes)) {
    Write-Host "ERROR: Version and ReleaseNotes are required for Android deployment" -ForegroundColor Red
    Write-Host "Usage: .\deploy-all.ps1 -Version '1.0.2' -ReleaseNotes 'Release notes'" -ForegroundColor Yellow
    Write-Host "   or: .\deploy-all.ps1 -WebOnly" -ForegroundColor Yellow
    exit 1
}

if ($AndroidOnly -and $WebOnly) {
    Write-Host "ERROR: Cannot specify both -AndroidOnly and -WebOnly" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Budget Pillars - Full Deployment     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (!$WebOnly) {
    Write-Host "Android: GitHub Releases (v$Version)" -ForegroundColor White
}
if (!$AndroidOnly) {
    Write-Host "Web:     Firebase Hosting" -ForegroundColor White
}
Write-Host ""
Write-Host "Press Ctrl+C to cancel, or any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

$deploymentSuccess = $true
$androidDeployed = $false
$webDeployed = $false

# Deploy Android
if (!$WebOnly) {
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "  Deploying Android APK...            " -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        & ".\deploy-android.ps1" -Version $Version -ReleaseNotes $ReleaseNotes
        
        if ($LASTEXITCODE -eq 0) {
            $androidDeployed = $true
            Write-Host "[OK] Android deployment succeeded!" -ForegroundColor Green
        }
        else {
            throw "Android deployment failed"
        }
    }
    catch {
        Write-Host "[ERROR] Android deployment failed: $_" -ForegroundColor Red
        $deploymentSuccess = $false
        
        if ($AndroidOnly) {
            exit 1
        }
    }
}

# Deploy Web
if (!$AndroidOnly) {
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "  Deploying Web App...                " -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        & ".\deploy-web.ps1"
        
        if ($LASTEXITCODE -eq 0) {
            $webDeployed = $true
            Write-Host "[OK] Web deployment succeeded!" -ForegroundColor Green
        }
        else {
            throw "Web deployment failed"
        }
    }
    catch {
        Write-Host "[ERROR] Web deployment failed: $_" -ForegroundColor Red
        $deploymentSuccess = $false
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Summary                  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($androidDeployed) {
    Write-Host "Android APK:  " -NoNewline -ForegroundColor White
    Write-Host "[OK] Deployed to GitHub Releases" -ForegroundColor Green
    Write-Host "   Version:      v$Version" -ForegroundColor Gray
    Write-Host "   Download:     https://github.com/Rightiouslight/budget_pillars/releases/tag/v$Version" -ForegroundColor Cyan
}

if ($webDeployed) {
    Write-Host "Web App:      " -NoNewline -ForegroundColor White
    Write-Host "[OK] Deployed to Firebase Hosting" -ForegroundColor Green
    Write-Host "   URL:          https://pocketflow-tw4kf.web.app" -ForegroundColor Cyan
}

Write-Host ""

if ($deploymentSuccess) {
    Write-Host "SUCCESS: All deployments completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Test the web app: https://pocketflow-tw4kf.web.app" -ForegroundColor White
    if ($androidDeployed) {
        Write-Host "  2. Test the Android APK on a physical device" -ForegroundColor White
        Write-Host "  3. Verify version check detects update in existing app" -ForegroundColor White
    }
    Write-Host ""
    exit 0
}
else {
    Write-Host "WARNING: Some deployments failed. Check the logs above." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
