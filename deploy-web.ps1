#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Budget Pillars Web App to Firebase Hosting

.DESCRIPTION
    Builds optimized web app and deploys to Firebase Hosting (production).

.PARAMETER SkipBuild
    Skip the build step (use existing web build)

.EXAMPLE
    .\deploy-web.ps1
    .\deploy-web.ps1 -SkipBuild
#>

param(
    [switch]$SkipBuild
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Web App Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build Web App
if (!$SkipBuild) {
    Write-Host "Step 1: Building production web app..." -ForegroundColor Yellow
    Write-Host "  This may take a minute..." -ForegroundColor Gray
    Write-Host ""
    
    flutter build web -t lib/main_prod.dart --release
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Web build failed" -ForegroundColor Red
        exit 1
    }
    
    # Verify build output exists
    if (!(Test-Path "build\web\index.html")) {
        Write-Host "ERROR: Web build output not found" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "  Web app built successfully!" -ForegroundColor Green
    Write-Host ""
}
else {
    Write-Host "Step 1: Skipping build (using existing build)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 2: Deploy to Firebase Hosting
Write-Host "Step 2: Deploying to Firebase Hosting..." -ForegroundColor Yellow

# Check if firebase CLI is installed
try {
    firebase --version 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "firebase not found"
    }
}
catch {
    Write-Host "  ERROR: Firebase CLI is not installed" -ForegroundColor Red
    Write-Host "  Install with: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}

# Deploy to Firebase Hosting
firebase deploy --only hosting

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Firebase deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Web Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Production URL:" -ForegroundColor White
Write-Host "https://pocketflow-tw4kf.web.app" -ForegroundColor Cyan
Write-Host ""
Write-Host "Firebase Console:" -ForegroundColor White
Write-Host "https://console.firebase.google.com/project/pocketflow-tw4kf/hosting" -ForegroundColor Cyan
Write-Host ""
