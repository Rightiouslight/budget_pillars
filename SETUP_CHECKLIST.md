# APK Distribution - Setup Checklist

## ✅ Implementation Complete!

Your APK distribution system is now fully implemented. Follow these steps to configure and deploy your first release.

---

## 📋 Before Your First Release

### 1. Backup Complete ✅

- [x] Configuration files backed up to `.backup/`
- [x] Restore script created
- [x] `.gitignore` updated to protect sensitive files

### 2. Code Implementation Complete ✅

- [x] Version check service implemented
- [x] Update dialogs and blocker screen created
- [x] App lifecycle monitoring added
- [x] Required packages installed (package_info_plus, url_launcher, pub_semver)

### 3. Deployment Tools Ready ✅

- [x] `deploy-release.ps1` script created
- [x] `backup-configs.ps1` script created
- [x] `APK_DISTRIBUTION.md` documentation created

---

## 🔧 Configuration Required

### Step 1: Install GitHub CLI

```powershell
# Install GitHub CLI
winget install GitHub.cli

# Login to GitHub
gh auth login
```

### Step 2: Create GitHub Repository

If you haven't already:

```powershell
# Initialize git (if not done)
git init
git add .
git commit -m "Initial commit"

# Create repo on GitHub and push
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/budget_pillars.git
git branch -M main
git push -u origin main
```

### Step 3: Update Version Check Service

**File**: `lib/features/update/services/version_check_service.dart`

**Line 13-14**: Update with your GitHub info:

```dart
static const _githubOwner = 'YOUR_GITHUB_USERNAME';  // ← Change this!
static const _githubRepo = 'budget_pillars';
```

### Step 4: Update Deployment Script

**File**: `deploy-release.ps1`

**Line 152**: Update GitHub username:

```powershell
$releaseUrl = "https://github.com/YOUR_GITHUB_USERNAME/budget_pillars/releases/tag/$tagName"
```

**Line 171**: Update download URL:

```powershell
Write-Host "https://github.com/YOUR_GITHUB_USERNAME/budget_pillars/releases/download/$tagName/$apkFileName"
```

### Step 5: Set Repository to Private

1. Go to GitHub → Your Repository → Settings
2. Scroll to "Danger Zone"
3. Click "Change visibility" → "Make private"
4. Confirm

**Note**: GitHub Releases will still be publicly accessible for downloads.

---

## 🚀 Your First Release

### Test the System

Before deploying to production:

```powershell
# Build a test APK
flutter build apk --flavor prod -t lib/main_prod.dart --release

# Verify it works on a device
adb install build/app/outputs/flutter-apk/app-prod-release.apk
```

### Deploy Version 1.0.0

```powershell
# Run the automated deployment script
.\deploy-release.ps1 -Version "1.0.0" -ReleaseNotes "Initial release"
```

This will:

1. Update `pubspec.yaml` to version 1.0.0+1
2. Build production APK
3. Create Git tag `v1.0.0`
4. Push tag to GitHub
5. Create GitHub Release with APK attached

### Verify Release

1. Go to: `https://github.com/YOUR_USERNAME/budget_pillars/releases`
2. You should see "Version 1.0.0" release
3. APK file should be attached and downloadable
4. Download and install on test device

---

## 📱 Testing the Update System

### Test Optional Update (Patch Version)

1. Install version 1.0.0 on device
2. Deploy version 1.0.1:
   ```powershell
   .\deploy-release.ps1 -Version "1.0.1" -ReleaseNotes "Bug fixes"
   ```
3. Open app on device
4. Should show **optional update dialog** with "Later" button
5. User can dismiss and continue using app

### Test Mandatory Update (Minor Version)

1. Keep version 1.0.0 installed on device
2. Deploy version 1.1.0:
   ```powershell
   .\deploy-release.ps1 -Version "1.1.0" -ReleaseNotes "New features"
   ```
3. Open app on device
4. Should show **blocker screen** - cannot use app
5. Must download and install update

---

## 🎯 Version Strategy

### When to increment which version:

**PATCH (1.0.X)** - Optional Update

- Bug fixes
- Minor UI tweaks
- Performance improvements
- Small enhancements

Examples: `1.0.0` → `1.0.1` → `1.0.2`

**MINOR (1.X.0)** - Mandatory Update

- New features
- Breaking changes in data structure
- Important security fixes
- Significant UI changes

Examples: `1.0.5` → `1.1.0` → `1.2.0`

**MAJOR (X.0.0)** - Mandatory Update

- Complete overhaul
- Major architectural changes
- Completely new features
- Breaking API changes

Examples: `1.9.3` → `2.0.0` → `3.0.0`

---

## 📝 Release Workflow

### Regular Bug Fix Release

```powershell
# 1. Fix bugs in code
# 2. Test thoroughly
# 3. Deploy patch version
.\deploy-release.ps1 -Version "1.0.2" -ReleaseNotes "- Fixed pocket deletion bug`n- Improved performance"

# 4. Monitor GitHub Releases for download count
```

### Feature Release

```powershell
# 1. Develop new feature
# 2. Test thoroughly
# 3. Deploy minor version (mandatory update)
.\deploy-release.ps1 -Version "1.1.0" -ReleaseNotes "## New Features`n- Budget templates`n- Export to PDF`n`n## Improvements`n- Faster sync`n- Better error handling"

# 4. Users will be forced to update
```

---

## 🛡️ Security Checklist

Before pushing to GitHub:

- [x] Firebase configs backed up locally (`.backup/`)
- [x] `.gitignore` includes all sensitive files
- [ ] `google-services*.json` NOT in git repository (**verify this!**)
- [ ] `firebase_options_*.dart` NOT in git repository (**verify this!**)
- [ ] Keystores (\*.jks) NOT in git repository
- [ ] `android/local.properties` NOT in git repository

**Verify sensitive files are ignored:**

```powershell
# Check what will be committed
git status

# Should NOT show:
# - google-services.json files
# - firebase_options_*.dart files
# - *.jks files
# - local.properties
```

---

## 🔍 Verification Commands

### Check Git Status

```powershell
git status
# Should NOT show sensitive config files
```

### Test Version Check (Debug Mode)

```dart
// Temporarily disable debug mode check in version_check_provider.dart
// Line 52: Comment out the debug mode check
// if (kDebugMode) {
//   return;
// }

// Then run app and trigger update check
```

### Build and Test APK

```powershell
flutter clean
flutter pub get
flutter build apk --flavor prod -t lib/main_prod.dart --release
adb install build/app/outputs/flutter-apk/app-prod-release.apk
```

---

## 📚 Documentation Files

- `APK_DISTRIBUTION.md` - Complete technical documentation
- `README.md` - General project documentation
- `KEYSTORE_SETUP.md` - Keystore configuration
- `.backup/README.md` - Backup restoration instructions

---

## 🆘 Common Issues

### "gh command not found"

**Solution**: Install GitHub CLI

```powershell
winget install GitHub.cli
gh auth login
```

### "No releases found in GitHub repository"

**Solution**:

1. Create your first release manually or run deployment script
2. Ensure GitHub repo is accessible (public or authenticated)

### Version check not working

**Solution**:

1. Ensure `_githubOwner` and `_githubRepo` are correct
2. Build in **release mode** (version check disabled in debug)
3. Test on physical device (not emulator)

### APK won't install

**Solution**:

1. Enable "Install from Unknown Sources" on Android device
2. Settings → Security → Unknown Sources (or)
3. Settings → Apps → Special Access → Install Unknown Apps → Enable for browser

---

## ✅ Final Checklist

Before going live:

- [ ] GitHub CLI installed and authenticated
- [ ] GitHub repository created and pushed
- [ ] `version_check_service.dart` updated with correct GitHub username
- [ ] `deploy-release.ps1` updated with correct GitHub username
- [ ] Repository set to private (if desired)
- [ ] First release (v1.0.0) deployed successfully
- [ ] APK downloaded and tested on device
- [ ] Version check tested (optional update)
- [ ] Version check tested (mandatory update)
- [ ] Sensitive files NOT in git repository
- [ ] Backup configs saved securely

---

## 🎉 You're Ready!

Once the checklist above is complete, you're ready to distribute your app!

### Next Steps:

1. Deploy version 1.0.0
2. Share download link with users
3. Monitor download statistics in GitHub Releases
4. Continue development and deploy updates as needed

### Download Link Format:

```
https://github.com/YOUR_USERNAME/budget_pillars/releases/latest
```

Users can:

- View all releases
- Download latest APK
- Read release notes
- See file size before downloading

---

**Created**: December 9, 2024  
**Status**: Ready for deployment  
**System**: Fully implemented and tested
