# Security Configuration Guide

## Overview

This guide outlines the steps to remove sensitive configuration files from Git and manage them securely, allowing you to safely make your repository public without exposing API keys, credentials, and other sensitive data.

## Files Containing Sensitive Information

### Critical Files (Must be secured)

1. **Firebase Configuration Files**

   - `android/app/google-services.json` (main)
   - `android/app/google-services.dev.json` (development)
   - `android/app/google-services.prod.json` (production)
   - `lib/firebase_options.dart`
   - `ios/Runner/GoogleService-Info.plist`
   - `macos/Runner/GoogleService-Info.plist`

2. **Web Configuration**

   - `web/index.html` (contains Google Sign-In Client ID on line 30-32)

3. **Keystore Files** (if they exist)

   - `android/app/upload-keystore.jks`
   - `android/key.properties`

4. **Environment Variables**
   - Any `.env` files
   - Local configuration files

### Firebase Configuration Contents

These files contain:

- API keys
- Project IDs
- OAuth client IDs
- Storage bucket names
- App IDs
- Database URLs

## Proposed Solution

### Phase 1: Gitignore Configuration

**Step 1.1: Update `.gitignore`**
Add the following entries to your `.gitignore` file:

```gitignore
# Firebase Configuration Files
android/app/google-services.json
android/app/google-services.dev.json
android/app/google-services.prod.json
lib/firebase_options.dart
ios/Runner/GoogleService-Info.plist
macos/Runner/GoogleService-Info.plist

# Android Keystore
*.jks
*.keystore
android/key.properties

# Environment files
.env
.env.*
!.env.example

# Local configuration
**/local.properties
```

**Step 1.2: Remove files from Git history**

```powershell
# Remove files from Git tracking but keep them locally
git rm --cached android/app/google-services.json
git rm --cached android/app/google-services.dev.json
git rm --cached android/app/google-services.prod.json
git rm --cached lib/firebase_options.dart
git rm --cached ios/Runner/GoogleService-Info.plist
git rm --cached macos/Runner/GoogleService-Info.plist

# Commit the changes
git commit -m "Remove sensitive configuration files from Git tracking"
```

**Note:** Files already in Git history will remain there. To completely remove them from history (recommended before making repo public), you'll need to use `git filter-branch` or BFG Repo-Cleaner.

### Phase 2: Template Files

**Step 2.1: Create Template Files**
Create example/template versions of sensitive files:

1. **`android/app/google-services.json.example`**

```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_STORAGE_BUCKET"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_MOBILE_SDK_APP_ID",
        "android_client_info": {
          "package_name": "budgetpillars.lojinnovation.com"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_WEB_CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ]
    }
  ]
}
```

2. **`lib/firebase_options.dart.example`**

```dart
// Template file - Copy to firebase_options.dart and fill in your values
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'budgetpillars.lojinnovation.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'budgetpillars.lojinnovation.com',
  );
}
```

3. **`web/index.html.template`**
   Create a template with placeholder for Google Sign-In Client ID

**Step 2.2: Create Setup Script**
Create `setup_config.ps1` (PowerShell script) or `setup_config.sh` (Bash script):

```powershell
# setup_config.ps1
Write-Host "Budget Pillars - Configuration Setup" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Check if configuration files exist
$missingFiles = @()

if (-not (Test-Path "android/app/google-services.json")) {
    $missingFiles += "android/app/google-services.json"
}
if (-not (Test-Path "android/app/google-services.dev.json")) {
    $missingFiles += "android/app/google-services.dev.json"
}
if (-not (Test-Path "android/app/google-services.prod.json")) {
    $missingFiles += "android/app/google-services.prod.json"
}
if (-not (Test-Path "lib/firebase_options.dart")) {
    $missingFiles += "lib/firebase_options.dart"
}

if ($missingFiles.Count -gt 0) {
    Write-Host "Missing configuration files:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Please follow these steps:" -ForegroundColor Yellow
    Write-Host "1. Go to Firebase Console: https://console.firebase.google.com/" -ForegroundColor Cyan
    Write-Host "2. Select your project (budgetpillarsdev or pocketflow-tw4kf)" -ForegroundColor Cyan
    Write-Host "3. Download google-services.json files for Android" -ForegroundColor Cyan
    Write-Host "4. Run 'flutterfire configure' to generate firebase_options.dart" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "All configuration files present!" -ForegroundColor Green
    Write-Host "You can now run the app." -ForegroundColor Green
}
```

### Phase 3: Web Configuration Security

**Step 3.1: Move Google Client ID to Environment**
Currently, the Google Sign-In Client ID is hardcoded in `web/index.html`. Options:

**Option A: Keep it in HTML (Less secure but simpler)**

- Google Client IDs are considered "public" by Google
- They work with authorized domains only
- No real security risk if exposed

**Option B: Environment variable injection (More secure)**

- Use build-time environment variables
- Replace client ID during build process
- More complex workflow

**Recommendation:** Option A is acceptable for Google Client IDs since they're paired with authorized domains.

### Phase 4: Documentation

**Step 4.1: Update README.md**
Add a "Setup" section:

````markdown
## Setup

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Firebase account with two projects (development and production)
- Google Cloud Console access

### Configuration

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd budget_pillars
   ```
````

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Copy template files to actual configuration files
   - Download your Firebase configuration files from Firebase Console
   - Place them in the appropriate directories:
     - `android/app/google-services.json` (and dev/prod variants)
     - `lib/firebase_options.dart`
     - iOS/macOS GoogleService-Info.plist files

4. **Run the setup script** (optional)

   ```powershell
   .\setup_config.ps1
   ```

5. **Configure Google Sign-In**
   - See [WEB_GOOGLE_SIGNIN_SETUP.md](WEB_GOOGLE_SIGNIN_SETUP.md) for web configuration
   - Add SHA-1 fingerprints to Firebase Console for Android

### Running the App

- Development: `flutter run`
- Web: `flutter run -d chrome`
- Android: `flutter run -d <device-id>`

````

**Step 4.2: Create SETUP_INSTRUCTIONS.md**
Detailed step-by-step guide for new developers.

## Impact on Workflow

### Development Workflow

**Initial Setup (One-time per developer/machine):**
1. Clone repository
2. Run `flutter pub get`
3. Download Firebase config files from Firebase Console
4. Place files in correct locations
5. Run app

**Daily Development:**
- No changes - works exactly as before
- Configuration files are local only
- Git won't track changes to config files

**Switching Environments:**
- Same as current workflow
- Edit `lib/config/environment.dart` to switch between dev/prod
- Config files remain local

### CI/CD Impact

**GitHub Actions / CI Pipeline:**
You'll need to store config files as secrets:

```yaml
# .github/workflows/build.yml
- name: Create Firebase config
  run: |
    echo '${{ secrets.GOOGLE_SERVICES_JSON }}' > android/app/google-services.json
    echo '${{ secrets.FIREBASE_OPTIONS_DART }}' > lib/firebase_options.dart
````

**Setup GitHub Secrets:**

1. Go to repository Settings → Secrets and variables → Actions
2. Add secrets:
   - `GOOGLE_SERVICES_JSON` (content of google-services.json)
   - `GOOGLE_SERVICES_DEV_JSON`
   - `GOOGLE_SERVICES_PROD_JSON`
   - `FIREBASE_OPTIONS_DART`

### Deployment to Production

**Firebase Hosting (Web):**

- No changes needed
- Build includes environment-specific configs
- Deploy as usual: `firebase deploy --only hosting`

**Android Production:**

1. Ensure `google-services.prod.json` is in place locally
2. Build release: `flutter build appbundle --release`
3. Upload to Play Store

**Security Note:** Keystore files should NEVER be in Git. Store them:

- Locally in a secure location
- In CI/CD as encrypted secrets
- In a secure password manager

## Alternative: Environment-Based Configuration

### Advanced Option: FlutterFire CLI + Environment Variables

Instead of multiple google-services files, you could:

1. Use FlutterFire CLI to manage configurations
2. Store project-specific configs in separate Firebase projects
3. Use build flavors for environment switching

```bash
# Configure for development
flutterfire configure --project=budgetpillarsdev --out=lib/firebase_options_dev.dart

# Configure for production
flutterfire configure --project=pocketflow-tw4kf --out=lib/firebase_options_prod.dart
```

This approach requires more setup but provides better separation.

## Clean Git History (Before Going Public)

If you want to completely remove sensitive data from Git history:

### Using BFG Repo-Cleaner (Recommended)

```powershell
# Install BFG (using Chocolatey)
choco install bfg-repo-cleaner

# Backup your repository first!
cp -r budget_pillars budget_pillars_backup

# Remove files from history
bfg --delete-files google-services.json
bfg --delete-files firebase_options.dart
bfg --delete-files GoogleService-Info.plist

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (WARNING: This rewrites history)
git push --force
```

### Using git-filter-repo (Alternative)

```bash
# Install git-filter-repo
pip install git-filter-repo

# Remove sensitive files
git filter-repo --path android/app/google-services.json --invert-paths
git filter-repo --path lib/firebase_options.dart --invert-paths

# Force push
git push --force
```

**⚠️ WARNING:** These operations rewrite Git history. Coordinate with all team members and backup first!

## Checklist Before Going Public

- [ ] Add sensitive files to `.gitignore`
- [ ] Remove sensitive files from Git tracking
- [ ] Create template files for all sensitive configurations
- [ ] Update README.md with setup instructions
- [ ] Create setup script
- [ ] Test cloning and setup on a new machine
- [ ] (Optional) Clean Git history with BFG or git-filter-repo
- [ ] Review all documentation files for exposed credentials
- [ ] Check for hardcoded API keys in code
- [ ] Review web/index.html for sensitive data
- [ ] Ensure keystore files are not in repository
- [ ] Set up CI/CD secrets if using automation
- [ ] Create SECURITY.md with responsible disclosure policy

## Team Collaboration

### For New Team Members

1. Clone repository
2. Request Firebase config files from team lead (via secure channel)
3. Run setup script
4. Follow setup instructions in README.md

### Sharing Configs Securely

**Never share via:**

- Email
- Slack/Teams messages
- GitHub issues/PRs

**Recommended methods:**

- 1Password/LastPass shared vaults
- Encrypted files via secure file sharing
- In-person transfer
- Secure company infrastructure

## Summary

**Benefits:**

- ✅ Safe to make repository public
- ✅ No exposed API keys or credentials
- ✅ Clear setup process for new developers
- ✅ Maintains same development workflow
- ✅ CI/CD can still access configs via secrets

**Tradeoffs:**

- ⚠️ One-time setup required per developer
- ⚠️ Config files must be shared securely
- ⚠️ CI/CD requires secret configuration
- ⚠️ Slightly more complex onboarding

**Next Steps:**

1. Review this document
2. Decide if you want to proceed
3. Execute Phase 1 (Gitignore)
4. Execute Phase 2 (Templates)
5. Execute Phase 3 (Web config)
6. Execute Phase 4 (Documentation)
7. (Optional) Clean Git history
8. Test with fresh clone
9. Make repository public

## Questions to Consider

1. Do you plan to have other contributors?
2. Do you need CI/CD automation?
3. Do you want to completely clean Git history?
4. Will you use build flavors for environments?
5. Do you need separate Firebase projects for dev/staging/prod?

Let me know if you'd like to proceed with implementation or need any clarification!
