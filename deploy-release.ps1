# Deploy Release Script
# Automates building APK, creating Git tag, and creating GitHub release

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$ReleaseNotes = "Bug fixes and performance improvements",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipBuild,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipTag,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipRelease
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Budget Pillars Release Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Validate version format
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Host "ERROR: Invalid version format. Use MAJOR.MINOR.PATCH (e.g., 1.0.1)" -ForegroundColor Red
    exit 1
}

$tagName = "v$Version"
$apkFileName = "budget-pillars-v$Version.apk"

# Step 1: Update pubspec.yaml version
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
    Write-Host ""
    
    flutter clean
    flutter pub get
    flutter build apk --flavor prod -t lib/main_prod.dart --release
    
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
else {
    Write-Host "Step 2: Skipping APK build" -ForegroundColor Gray
    Write-Host ""
}

# Step 3: Create Git tag
if (!$SkipTag) {
    Write-Host "Step 3: Creating Git tag..." -ForegroundColor Yellow
    
    # Check if tag already exists
    $tagExists = git tag -l $tagName
    if ($tagExists) {
        Write-Host "  WARNING: Tag $tagName already exists" -ForegroundColor Yellow
        $response = Read-Host "  Delete and recreate? (y/n)"
        if ($response -eq 'y') {
            git tag -d $tagName
            git push origin --delete $tagName 2>$null
        }
        else {
            Write-Host "  Skipping tag creation" -ForegroundColor Gray
            $SkipTag = $true
        }
    }
    
    if (!$SkipTag) {
        # Commit version bump
        git add pubspec.yaml
        git commit -m "chore: bump version to $Version" -ErrorAction SilentlyContinue
        
        # Create annotated tag
        git tag -a $tagName -m "Version $Version"
        
        Write-Host "  Tag $tagName created" -ForegroundColor Green
    }
    Write-Host ""
}
else {
    Write-Host "Step 3: Skipping Git tag creation" -ForegroundColor Gray
    Write-Host ""
}

# Step 4: Create GitHub Release
if (!$SkipRelease) {
    Write-Host "Step 4: Creating GitHub Release..." -ForegroundColor Yellow
    
    # Check if gh CLI is installed
    try {
        $ghVersion = gh --version 2>&1
        if ($LASTEXITCODE -ne 0) { throw }
    }
    catch {
        Write-Host "  ERROR: GitHub CLI (gh) not installed" -ForegroundColor Red
        Write-Host "  Install from: https://cli.github.com/" -ForegroundColor Yellow
        exit 1
    }
    
    # Push tag to remote
    if (!$SkipTag) {
        Write-Host "  Pushing tag to GitHub..." -ForegroundColor Gray
        git push origin $tagName
    }
    
    # Create release with APK
    Write-Host "  Creating release with APK..." -ForegroundColor Gray
    $builtApk = "build\app\outputs\flutter-apk\app-prod-release.apk"
    
    gh release create $tagName `
        --title "Version $Version" `
        --notes $ReleaseNotes `
        "$builtApk#$apkFileName"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  GitHub Release created successfully!" -ForegroundColor Green
        $releaseUrl = "https://github.com/Rightiouslight/budget_pillars/releases/tag/$tagName"
        Write-Host "  Release URL: $releaseUrl" -ForegroundColor Cyan
    }
    else {
        Write-Host "  ERROR: Failed to create GitHub release" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}
else {
    Write-Host "Step 4: Skipping GitHub Release creation" -ForegroundColor Gray
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Release Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host "Tag:     $tagName" -ForegroundColor Cyan
Write-Host "APK:     $apkFileName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Users will be notified of the update when they open the app"
Write-Host "2. They can download the APK from GitHub Releases"
Write-Host "3. Monitor download statistics in GitHub Releases"
Write-Host ""
Write-Host "Download URL:" -ForegroundColor Yellow
Write-Host "https://github.com/Rightiouslight/budget_pillars/releases/download/$tagName/$apkFileName"
Write-Host ""
