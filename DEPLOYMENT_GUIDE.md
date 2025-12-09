# Deployment Guide

Complete guide for deploying Budget Pillars to production.

## Deployment Scripts

### Available Scripts

| Script                   | Purpose             | Platforms                     |
| ------------------------ | ------------------- | ----------------------------- |
| **`deploy-all.ps1`**     | Deploy everything   | Android + Web                 |
| **`deploy-android.ps1`** | Deploy Android only | Android APK → GitHub Releases |
| **`deploy-web.ps1`**     | Deploy Web only     | Web App → Firebase Hosting    |

### Quick Start

**Deploy both Android and Web:**

```powershell
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes and improvements"
```

**Deploy only Android:**

```powershell
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes"
# OR
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes" -AndroidOnly
```

**Deploy only Web:**

```powershell
.\deploy-web.ps1
# OR
.\deploy-all.ps1 -WebOnly
```

## Detailed Usage

### 1. Full Deployment (Recommended)

Deploy both Android APK and Web App in one command:

```powershell
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "
- Added beautiful landing page
- Optimized app size
- Bug fixes
"
```

**What it does:**

1. ✅ Updates version in `pubspec.yaml`
2. ✅ Builds optimized Android APK (with code shrinking & obfuscation)
3. ✅ Creates Git tag (`v1.0.2`)
4. ✅ Pushes tag to GitHub
5. ✅ Creates GitHub Release with APK
6. ✅ Builds production web app
7. ✅ Deploys web app to Firebase Hosting

**Expected output:**

```
📱 Android APK:  ✅ Deployed to GitHub Releases
   Version:      v1.0.2
   Download:     https://github.com/Rightiouslight/budget_pillars/releases/tag/v1.0.2

🌐 Web App:      ✅ Deployed to Firebase Hosting
   URL:          https://pocketflow-tw4kf.web.app
```

### 2. Android Only Deployment

Deploy just the Android APK to GitHub Releases:

```powershell
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Hotfix: Fixed critical bug"
```

**Use when:**

- Only Android code changed
- Quick hotfix for mobile users
- Testing Android release process

### 3. Web Only Deployment

Deploy just the web app to Firebase Hosting:

```powershell
.\deploy-web.ps1
```

**Use when:**

- Only web-specific changes (landing page, etc.)
- Quick content update
- No version bump needed

### 4. Partial Deployments

**Android first, web later:**

```powershell
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Update" -AndroidOnly
# ... test Android ...
.\deploy-all.ps1 -WebOnly
```

**Web first, Android later:**

```powershell
.\deploy-all.ps1 -WebOnly
# ... test web ...
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Update"
```

## Script Options

### deploy-all.ps1

```powershell
.\deploy-all.ps1 `
    -Version "X.Y.Z" `           # Required (unless -WebOnly)
    -ReleaseNotes "Notes" `      # Required (unless -WebOnly)
    [-AndroidOnly] `             # Optional: Skip web deployment
    [-WebOnly]                   # Optional: Skip Android deployment
```

### deploy-android.ps1

```powershell
.\deploy-android.ps1 `
    -Version "X.Y.Z" `           # Required
    -ReleaseNotes "Notes" `      # Required
    [-SkipBuild]                 # Optional: Use existing APK
```

### deploy-web.ps1

```powershell
.\deploy-web.ps1 `
    [-SkipBuild]                 # Optional: Use existing web build
```

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH+BUILD

Example: 1.0.2+7
         │ │ │  │
         │ │ │  └─ Build number (auto-incremented)
         │ │ └──── Patch (bug fixes)
         │ └─────── Minor (new features, backward compatible)
         └────────── Major (breaking changes)
```

### Version Examples

| Change          | Old Version | New Version | Update Type       |
| --------------- | ----------- | ----------- | ----------------- |
| Bug fix         | 1.0.1       | 1.0.2       | Patch (optional)  |
| New feature     | 1.0.2       | 1.1.0       | Minor (mandatory) |
| Breaking change | 1.1.0       | 2.0.0       | Major (mandatory) |

**Note:** Minor and Major updates trigger **mandatory updates** in the app.

## Pre-Deployment Checklist

Before deploying, ensure:

- [ ] All changes committed to Git
- [ ] All tests passing
- [ ] No console errors or warnings
- [ ] App tested on physical device (Android)
- [ ] Web app tested in browser (incognito mode for landing page)
- [ ] Version number follows semantic versioning
- [ ] Release notes written clearly

## Prerequisites

### Required Tools

| Tool             | Installation                    | Check Version        |
| ---------------- | ------------------------------- | -------------------- |
| **Flutter**      | https://flutter.dev             | `flutter --version`  |
| **GitHub CLI**   | https://cli.github.com          | `gh --version`       |
| **Firebase CLI** | `npm install -g firebase-tools` | `firebase --version` |
| **Git**          | https://git-scm.com             | `git --version`      |

### Authentication

**GitHub CLI:**

```powershell
gh auth login
```

**Firebase CLI:**

```powershell
firebase login
```

## Deployment Process Details

### Android Deployment Steps

1. **Version Update**

   - Reads current version from `pubspec.yaml`
   - Increments build number automatically
   - Updates version to specified `X.Y.Z+BUILD`

2. **Build APK**

   - Runs `flutter clean` to ensure clean build
   - Runs `flutter pub get` to update dependencies
   - Builds with: `--release --obfuscate --split-debug-info`
   - Optimizations: Code shrinking, resource shrinking, obfuscation
   - Result: ~52.6 MB APK

3. **Create Git Tag**

   - Commits version change to Git
   - Creates annotated tag: `v1.0.2`
   - Pushes tag to GitHub

4. **Create GitHub Release**
   - Creates release on GitHub
   - Attaches APK file
   - Adds release notes
   - Marks as "Latest Release"

### Web Deployment Steps

1. **Build Web App**

   - Builds with: `flutter build web -t lib/main_prod.dart --release`
   - Optimizations: Tree-shaking, minification
   - Result: 33 files in `build/web/`

2. **Deploy to Firebase**
   - Uploads all files from `build/web/` to Firebase Hosting
   - Firebase serves files with CDN
   - Available immediately at production URL

## Troubleshooting

### Android Deployment Issues

**Error: "APK build failed"**

```powershell
# Clean and retry
flutter clean
flutter pub get
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Update"
```

**Error: "GitHub CLI not found"**

```powershell
# Install GitHub CLI
winget install GitHub.cli
# Then refresh PowerShell
```

**Error: "Tag already exists"**

```powershell
# Delete tag locally and remotely
git tag -d v1.0.2
git push origin :refs/tags/v1.0.2
# Then retry deployment
```

### Web Deployment Issues

**Error: "Firebase CLI not found"**

```powershell
npm install -g firebase-tools
firebase login
```

**Error: "Web build failed"**

```powershell
flutter clean
flutter pub get
flutter build web -t lib/main_prod.dart --release
```

**Error: "Deployment failed"**

```powershell
# Check Firebase project
firebase projects:list
firebase use pocketflow-tw4kf
# Retry deployment
.\deploy-web.ps1
```

## Post-Deployment Verification

### Android Verification

1. **GitHub Release:**

   - Visit: https://github.com/Rightiouslight/budget_pillars/releases
   - Verify release exists with correct version
   - Download APK and check size (~52.6 MB)

2. **Version Check:**

   - Install on device from Play Store (older version)
   - Open app → Should show update dialog
   - Verify update type (optional for PATCH, mandatory for MINOR/MAJOR)

3. **APK Installation:**
   - Download APK from GitHub Releases
   - Install on fresh device
   - Test all features

### Web Verification

1. **Landing Page:**

   - Visit: https://pocketflow-tw4kf.web.app (incognito)
   - Should see landing page for unauthenticated users
   - Test "Sign In or Register" button
   - Mobile: Check download section appears

2. **Authentication:**

   - Sign in with test account
   - Should redirect to dashboard
   - Verify all features work

3. **Performance:**
   - Check page load time
   - Test navigation
   - Verify no console errors

## Rollback Procedure

### Android Rollback

**Delete release:**

```powershell
gh release delete v1.0.2 --yes
git tag -d v1.0.2
git push origin :refs/tags/v1.0.2
```

**Note:** Users who already downloaded can't be forced to downgrade.

### Web Rollback

**Revert to previous deployment:**

```powershell
firebase hosting:channel:deploy previous-version
# Then make it live
firebase hosting:channel:deploy previous-version --only hosting
```

**Or rebuild previous version:**

```powershell
git checkout v1.0.1
flutter build web -t lib/main_prod.dart --release
firebase deploy --only hosting
git checkout main
```

## CI/CD Integration (Future)

These scripts can be integrated into GitHub Actions:

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    tags:
      - "v*"
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ./deploy-all.ps1 -Version ${{ github.ref_name }}
```

## Best Practices

1. **Always test locally** before deploying to production
2. **Use semantic versioning** consistently
3. **Write clear release notes** for users
4. **Deploy during low-traffic hours** when possible
5. **Monitor crash reports** after deployment
6. **Keep debug symbols** (`build/debug-info/`) for each release
7. **Tag releases** in Git for easy rollback
8. **Test on physical devices** before releasing to all users

## Support

For issues with deployment scripts:

1. Check error messages in script output
2. Verify all prerequisites installed
3. Check authentication (gh, firebase)
4. Review troubleshooting section
5. Check Git status and tags

---

**Last Updated:** December 9, 2025  
**Scripts Version:** 1.0  
**Supports:** Android APK (GitHub Releases) + Web (Firebase Hosting)
