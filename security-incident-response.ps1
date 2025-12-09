# Security Incident Response - API Key Rotation Helper
# This script helps you through the process of responding to exposed API keys

param(
    [switch]$CheckStatus,
    [switch]$UpdateConfigs,
    [switch]$Redeploy
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host "  API Key Security Incident Response   "
Write-Host "========================================"
Write-Host ""

# Helper function to show section headers
function Show-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "----------------------------------------"
    Write-Host "  $Title"
    Write-Host "----------------------------------------"
    Write-Host ""
}

# Helper function to show checklist items
function Show-ChecklistItem {
    param(
        [string]$Item,
        [bool]$IsComplete = $false
    )
    $status = if ($IsComplete) { "[OK]" } else { "[ ]" }
    Write-Host "$status $Item"
}

# Check if we have the required files
function Test-RequiredFiles {
    Show-Section "Checking Configuration Status"
    
    $hasRealProd = Test-Path "lib\config\firebase_options_prod.dart"
    $hasTemplate = Test-Path "lib\config\firebase_options_prod.dart.template"
    $hasGoogleServices = Test-Path "android\app\google-services.json"
    
    Show-ChecklistItem "Production Firebase config exists" $hasRealProd
    Show-ChecklistItem "Template file exists" $hasTemplate
    Show-ChecklistItem "Android google-services.json exists" $hasGoogleServices
    
    Write-Host ""
    
    if ($hasRealProd) {
        Write-Host "WARNING: Real firebase_options_prod.dart exists locally." -ForegroundColor Yellow
        Write-Host "Make sure it contains NEW (regenerated) API keys, not the exposed ones." -ForegroundColor Yellow
    }
    else {
        Write-Host "INFO: No firebase_options_prod.dart found. You'll need to create it after regenerating keys." -ForegroundColor Cyan
    }
}

# Show the incident response checklist
function Show-IncidentChecklist {
    Show-Section "Incident Response Checklist"
    
    Write-Host "CRITICAL - Do these IMMEDIATELY:"
    Write-Host ""
    Show-ChecklistItem "1. Go to Google Cloud Console (console.cloud.google.com)"
    Show-ChecklistItem "2. Select project: pocketflow-tw4kf"
    Show-ChecklistItem "3. Go to APIs & Services > Credentials"
    Show-ChecklistItem "4. Find and regenerate Web API key (AIzaSyB2vISec3_1i_D2KBrqFKGakfUBAersoFA)"
    Show-ChecklistItem "5. Find and regenerate Android API key (AIzaSyDgU4fkN8RExycQhsR5MbZIDNgcHdWDQ1Y)"
    Write-Host ""
    Write-Host "After regenerating keys:"
    Write-Host ""
    Show-ChecklistItem "6. Add HTTP referrer restrictions to Web API key"
    Show-ChecklistItem "   - https://pocketflow-tw4kf.web.app/*"
    Show-ChecklistItem "   - https://pocketflow-tw4kf.firebaseapp.com/*"
    Show-ChecklistItem "   - http://localhost:* (for development)"
    Write-Host ""
    Show-ChecklistItem "7. Add Android app restrictions to Android API key"
    Show-ChecklistItem "   - Package: budgetpillars.lojinnovation.com"
    Show-ChecklistItem "   - SHA-1: B5:CF:06:B9:11:97:BA:39:0A:78:32:2E:12:05:40:A0:66:D7:43:10"
    Write-Host ""
    Show-ChecklistItem "8. Restrict both keys to only required APIs:"
    Show-ChecklistItem "   - Identity Toolkit API"
    Show-ChecklistItem "   - Cloud Firestore API"
    Show-ChecklistItem "   - Firebase Authentication API"
    Write-Host ""
    
    Write-Host "Your SHA-1 fingerprint (debug keystore):" -ForegroundColor Cyan
    Write-Host "  B5:CF:06:B9:11:97:BA:39:0A:78:32:2E:12:05:40:A0:66:D7:43:10" -ForegroundColor White
    Write-Host ""
    Write-Host "NOTE: This is your debug keystore. For production releases, you'll need" -ForegroundColor Yellow
    Write-Host "to create a release keystore and add its SHA-1 fingerprint as well." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "MONITORING - Check for abuse:"
    Write-Host ""
    Show-ChecklistItem "9. Check Billing > Reports for unusual usage"
    Show-ChecklistItem "10. Check Firebase Authentication for unauthorized users"
    Show-ChecklistItem "11. Check Firestore for unusual data access"
    Show-ChecklistItem "12. Review Cloud Logging for suspicious activity"
    Write-Host ""
}

# Show how to update configurations
function Show-UpdateGuide {
    Show-Section "Updating Configuration Files"
    
    Write-Host "After regenerating API keys in Google Cloud Console:" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "1. Get new configuration from Firebase Console:"
    Write-Host "   - Go to: https://console.firebase.google.com/"
    Write-Host "   - Select project: pocketflow-tw4kf"
    Write-Host "   - Go to Project Settings > General"
    Write-Host "   - Scroll to 'Your apps'"
    Write-Host ""
    
    Write-Host "2. For WEB app:"
    Write-Host "   - Copy the new Firebase config"
    Write-Host "   - Update: lib\config\firebase_options_prod.dart"
    Write-Host "   - Replace the apiKey value with your NEW web API key"
    Write-Host ""
    
    Write-Host "3. For ANDROID app:"
    Write-Host "   - Download new google-services.json"
    Write-Host "   - Replace: android\app\google-services.json"
    Write-Host "   - Update: lib\config\firebase_options_prod.dart (android section)"
    Write-Host ""
    
    Write-Host "IMPORTANT: These files are in .gitignore and will NOT be committed!" -ForegroundColor Yellow
    Write-Host ""
}

# Show redeployment steps
function Show-RedeployGuide {
    Show-Section "Redeployment Steps"
    
    Write-Host "After updating all configuration files:" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "1. Test locally first:"
    Write-Host "   flutter run -t lib\main_prod.dart" -ForegroundColor White
    Write-Host ""
    
    Write-Host "2. Deploy web app:"
    Write-Host "   .\deploy-web.ps1" -ForegroundColor White
    Write-Host ""
    
    Write-Host "3. Deploy Android app (with hotfix version):"
    Write-Host "   .\deploy-android.ps1 -Version '1.0.1-hotfix.1' -ReleaseNotes 'Security update: Regenerated API keys'" -ForegroundColor White
    Write-Host ""
    
    Write-Host "4. Test the deployed apps:"
    Write-Host "   - Web: https://pocketflow-tw4kf.web.app"
    Write-Host "   - Android: Download latest APK from GitHub Releases"
    Write-Host ""
    
    Write-Host "5. Verify old API keys are deactivated:"
    Write-Host "   - Try using the app with old keys (should fail)"
    Write-Host "   - Check Google Cloud Console that old keys are gone"
    Write-Host ""
}

# Main script logic
if ($CheckStatus) {
    Test-RequiredFiles
}
elseif ($UpdateConfigs) {
    Show-UpdateGuide
}
elseif ($Redeploy) {
    Show-RedeployGuide
}
else {
    # Show full incident response guide
    Show-IncidentChecklist
    
    Write-Host ""
    Write-Host "========================================"
    Write-Host ""
    Write-Host "For more details, see:" -ForegroundColor Cyan
    Write-Host "  - SECURITY_INCIDENT_RESOLUTION.md (complete incident guide)"
    Write-Host "  - API_KEY_SECURITY.md (prevention and best practices)"
    Write-Host ""
    Write-Host "Quick commands:" -ForegroundColor Cyan
    Write-Host "  .\security-incident-response.ps1 -CheckStatus   # Check current config status"
    Write-Host "  .\security-incident-response.ps1 -UpdateConfigs # Show how to update configs"
    Write-Host "  .\security-incident-response.ps1 -Redeploy      # Show redeployment steps"
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Regenerate API keys in Google Cloud Console (DO THIS NOW)"
    Write-Host "2. Add restrictions to the new keys"
    Write-Host "3. Update local configuration files"
    Write-Host "4. Redeploy applications"
    Write-Host "5. Verify everything works with new keys"
    Write-Host ""
}
