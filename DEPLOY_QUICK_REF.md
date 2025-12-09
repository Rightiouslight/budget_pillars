# Deployment Quick Reference

## 🚀 Quick Commands

### Deploy Everything (Android + Web)

```powershell
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes and improvements"
```

### Deploy Android Only

```powershell
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Hotfix"
```

### Deploy Web Only

```powershell
.\deploy-web.ps1
```

## 📋 What Each Script Does

### `deploy-all.ps1` - Master Script

✅ Updates version in pubspec.yaml  
✅ Builds Android APK (optimized)  
✅ Creates GitHub Release with APK  
✅ Builds Web App  
✅ Deploys to Firebase Hosting

**Use for:** Regular releases with both platforms

### `deploy-android.ps1` - Android Only

✅ Updates version in pubspec.yaml  
✅ Builds Android APK with code shrinking & obfuscation  
✅ Creates Git tag  
✅ Creates GitHub Release with APK attached

**Use for:** Android-only updates, hotfixes

### `deploy-web.ps1` - Web Only

✅ Builds Web App (production)  
✅ Deploys to Firebase Hosting

**Use for:** Web-only updates (landing page, web features)

## 🎯 Common Scenarios

### Scenario 1: Regular Release (Both Platforms)

```powershell
# Full deployment
.\deploy-all.ps1 -Version "1.1.0" -ReleaseNotes "
- New feature: Budget templates
- Improved charts
- Bug fixes
"
```

### Scenario 2: Android Hotfix

```powershell
# Android only
.\deploy-android.ps1 -Version "1.0.3" -ReleaseNotes "Fixed crash on Android"
```

### Scenario 3: Update Landing Page

```powershell
# Web only
.\deploy-web.ps1
```

### Scenario 4: Staged Deployment

```powershell
# Deploy Android first, test, then web
.\deploy-all.ps1 -Version "1.2.0" -ReleaseNotes "Update" -AndroidOnly

# After testing...
.\deploy-all.ps1 -WebOnly
```

## ⚠️ Before You Deploy

- [ ] All changes committed to Git
- [ ] Tests passing (`flutter test`)
- [ ] No errors (`flutter analyze`)
- [ ] Tested on device/browser
- [ ] Version number decided
- [ ] Release notes written

## 📦 What Gets Deployed

### Android (GitHub Releases)

- **File:** `budget-pillars-vX.Y.Z.apk`
- **Size:** ~52.6 MB (universal APK)
- **URL:** `https://github.com/Rightiouslight/budget_pillars/releases`

### Web (Firebase Hosting)

- **Files:** All files from `build/web/`
- **URL:** `https://pocketflow-tw4kf.web.app`

## 🔧 Prerequisites

**Installed:**

- ✅ Flutter SDK
- ✅ GitHub CLI (`gh`)
- ✅ Firebase CLI (`firebase`)
- ✅ Git

**Authenticated:**

```powershell
gh auth login       # GitHub
firebase login      # Firebase
```

## 📊 Version Numbering

| Update Type          | Example       | App Behavior     |
| -------------------- | ------------- | ---------------- |
| **Patch** (bug fix)  | 1.0.1 → 1.0.2 | Optional update  |
| **Minor** (feature)  | 1.0.2 → 1.1.0 | Mandatory update |
| **Major** (breaking) | 1.1.0 → 2.0.0 | Mandatory update |

## 🎨 Script Options

### Full Control

```powershell
# Deploy both
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Notes"

# Android only
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Notes" -AndroidOnly

# Web only
.\deploy-all.ps1 -WebOnly
```

### Skip Build (Use Existing)

```powershell
# Android with existing APK
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Notes" -SkipBuild

# Web with existing build
.\deploy-web.ps1 -SkipBuild
```

## 🎉 After Deployment

### Verify Android

1. Visit: https://github.com/Rightiouslight/budget_pillars/releases
2. Download APK and install on device
3. Open existing app → Check for update notification

### Verify Web

1. Visit: https://pocketflow-tw4kf.web.app (incognito)
2. Test landing page
3. Sign in and test features

## 🆘 Troubleshooting

**Script won't run:**

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**GitHub CLI not found:**

```powershell
winget install GitHub.cli
# Restart PowerShell
```

**Firebase CLI not found:**

```powershell
npm install -g firebase-tools
firebase login
```

**Build fails:**

```powershell
flutter clean
flutter pub get
# Try again
```

## 📚 More Information

See `DEPLOYMENT_GUIDE.md` for:

- Detailed deployment process
- Rollback procedures
- Best practices
- CI/CD integration

---

**TL;DR:** Run `.\deploy-all.ps1 -Version "X.Y.Z" -ReleaseNotes "Notes"` to deploy everything! 🚀
