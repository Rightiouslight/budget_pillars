#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Budget Pillars Android APK to GitHub Releases

.DESCRIPTION
    Builds optimized Android APK and creates a GitHub Release with the APK attached.
    Uses code shrinking, resource shrinking, and obfuscation for smaller app size.

.PARAMETER Version
    Version number in format X.Y.Z (e.g., 1.0.1)

.PARAMETER ReleaseNotes
    Release notes for the GitHub release

.PARAMETER SkipBuild
    Skip the build step (use existing APK)

.EXAMPLE
    .\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes and improvements"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $true)]
    [string]$ReleaseNotes,
    
    [switch]$SkipBuild
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Android APK Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Update version in pubspec.yaml
if (!$SkipBuild) {
    Write-Host "Step 1: Updating pubspec.yaml version..." -ForegroundColor Yellow
    
    $pubspecPath = "pubspec.yaml"
    $pubspecContent = Get-Content $pubspecPath -Raw
    
    # Extract current build number
    if ($pubspecContent -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
        $currentVersion = $matches[1]
        $currentBuild = [int]$matches[2]
        $newBuild = $currentBuild + 1
        
        Write-Host "  Current: $currentVersion+$currentBuild" -ForegroundColor Gray
        Write-Host "  New:     $Version+$newBuild" -ForegroundColor Green
        
        $pubspecContent = $pubspecContent -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $Version+$newBuild"
        Set-Content $pubspecPath $pubspecContent -NoNewline
    }
    else {
        Write-Host "  ERROR: Could not parse version from pubspec.yaml" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
}

# Step 2: Build APK
if (!$SkipBuild) {
    Write-Host "Step 2: Building production APK..." -ForegroundColor Yellow
    Write-Host "  This may take a few minutes..." -ForegroundColor Gray
    Write-Host "  (Using code shrinking and obfuscation for smaller size)" -ForegroundColor Gray
    Write-Host ""
    
    flutter clean
    flutter pub get
    flutter build apk --flavor prod -t lib/main_prod.dart --release --obfuscate --split-debug-info=build/debug-info
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: APK build failed" -ForegroundColor Red
        exit 1
    }
    
    # Verify APK exists
    $builtApk = "build\app\outputs\flutter-apk\app-prod-release.apk"
    if (!(Test-Path $builtApk)) {
        Write-Host "ERROR: APK not found at $builtApk" -ForegroundColor Red
        exit 1
    }
    
    # Get APK size
    $apkSize = (Get-Item $builtApk).Length / 1MB
    Write-Host "  APK built successfully: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Green
    Write-Host ""
}

# Step 3: Create Git tag
Write-Host "Step 3: Creating Git tag..." -ForegroundColor Yellow

# Commit version change
git add pubspec.yaml
git commit -m "Bump version to $Version" 2>&1 | Out-Null

# Create tag
git tag -a "v$Version" -m "Release v$Version`n`n$ReleaseNotes"
if ($LASTEXITCODE -ne 0) {
    Write-Host "  WARNING: Tag creation failed (may already exist)" -ForegroundColor Yellow
}
else {
    Write-Host "  Tag v$Version created" -ForegroundColor Green
}
Write-Host ""

# Step 4: Create GitHub Release
Write-Host "Step 4: Creating GitHub Release..." -ForegroundColor Yellow

# Check if gh CLI is installed
try {
    $ghVersion = gh --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "gh not found"
    }
}
catch {
    Write-Host "  ERROR: GitHub CLI (gh) is not installed" -ForegroundColor Red
    Write-Host "  Install from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

# Push tag to GitHub
Write-Host "  Pushing tag to GitHub..." -ForegroundColor Gray
git push origin "v$Version"

# Rename APK for release
$apkPath = "build\app\outputs\flutter-apk\app-prod-release.apk"
$releasedApkPath = "budget-pillars-v$Version.apk"
Copy-Item $apkPath $releasedApkPath

# Create release with APK
Write-Host "  Creating release with APK..." -ForegroundColor Gray
gh release create "v$Version" `
    $releasedApkPath `
    --title "Budget Pillars v$Version" `
    --notes "$ReleaseNotes" `
    --latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: GitHub Release creation failed" -ForegroundColor Red
    Remove-Item $releasedApkPath -ErrorAction SilentlyContinue
    exit 1
}

# Clean up temporary APK
Remove-Item $releasedApkPath

Write-Host "  GitHub Release created successfully!" -ForegroundColor Green
Write-Host "  Release URL: https://github.com/Rightiouslight/budget_pillars/releases/tag/v$Version" -ForegroundColor Cyan

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Android Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Version: $Version" -ForegroundColor White
Write-Host "APK:     budget-pillars-v$Version.apk" -ForegroundColor White
Write-Host ""
Write-Host "Download URL:" -ForegroundColor White
Write-Host "https://github.com/Rightiouslight/budget_pillars/releases/download/v$Version/budget-pillars-v$Version.apk" -ForegroundColor Cyan
Write-Host ""
