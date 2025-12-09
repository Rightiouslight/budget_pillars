# Deployment Scripts - Complete Overview

## 📁 Available Scripts

### Primary Deployment Scripts

1. **`deploy-all.ps1`** - Master deployment script

   - Deploys both Android and Web
   - Coordinates the entire release process
   - Most commonly used for production releases

2. **`deploy-android.ps1`** - Android-only deployment

   - Builds optimized APK
   - Creates GitHub Release
   - Useful for Android hotfixes

3. **`deploy-web.ps1`** - Web-only deployment
   - Builds web app
   - Deploys to Firebase Hosting
   - Useful for web-specific updates

### Legacy Script

4. **`deploy-release.ps1`** - Original Android deployment
   - Kept for backward compatibility
   - Functionally similar to `deploy-android.ps1`
   - Consider using `deploy-android.ps1` instead

## 🎯 Which Script to Use?

### Use `deploy-all.ps1` when:

✅ Regular release with changes to both platforms  
✅ Major version update  
✅ You want one-command deployment  
✅ Default choice for most releases

**Example:**

```powershell
.\deploy-all.ps1 -Version "1.1.0" -ReleaseNotes "New features and improvements"
```

### Use `deploy-android.ps1` when:

✅ Android-only bug fix  
✅ Android performance improvements  
✅ No web changes  
✅ Testing Android release process

**Example:**

```powershell
.\deploy-android.ps1 -Version "1.0.3" -ReleaseNotes "Fixed crash on Android 14"
```

### Use `deploy-web.ps1` when:

✅ Landing page updates  
✅ Web UI improvements  
✅ No mobile changes  
✅ Quick web-only deployment

**Example:**

```powershell
.\deploy-web.ps1
```

### Use `deploy-release.ps1` when:

⚠️ You need backward compatibility  
⚠️ Existing scripts reference it

**Recommendation:** Migrate to `deploy-android.ps1` or `deploy-all.ps1`

## 📊 Feature Comparison

| Feature               | deploy-all.ps1 | deploy-android.ps1 | deploy-web.ps1 | deploy-release.ps1 |
| --------------------- | -------------- | ------------------ | -------------- | ------------------ |
| **Android APK**       | ✅             | ✅                 | ❌             | ✅                 |
| **Web App**           | ✅             | ❌                 | ✅             | ❌                 |
| **GitHub Release**    | ✅             | ✅                 | ❌             | ✅                 |
| **Firebase Deploy**   | ✅             | ❌                 | ✅             | ❌                 |
| **Version Update**    | ✅             | ✅                 | ❌             | ✅                 |
| **Git Tag**           | ✅             | ✅                 | ❌             | ✅                 |
| **Code Optimization** | ✅             | ✅                 | ✅             | ✅                 |
| **Flexible Options**  | ✅             | ✅                 | ✅             | ❌                 |
| **Partial Deploy**    | ✅             | ❌                 | ❌             | ❌                 |

## 🔄 Migration Guide

### From `deploy-release.ps1` to New Scripts

**Old way:**

```powershell
.\deploy-release.ps1 -Version "1.0.2" -ReleaseNotes "Update"
# Then manually deploy web separately
```

**New way (both platforms):**

```powershell
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Update"
```

**New way (Android only):**

```powershell
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Update"
```

**Benefits:**

- ✅ Single command for full deployment
- ✅ Clearer script names
- ✅ Better error handling
- ✅ More flexible options

## 🎨 Advanced Usage

### Staged Deployment

Deploy Android first, test, then deploy web:

```powershell
# Step 1: Deploy Android
.\deploy-all.ps1 -Version "1.2.0" -ReleaseNotes "Update" -AndroidOnly

# Step 2: Test Android APK on devices

# Step 3: Deploy Web
.\deploy-all.ps1 -WebOnly
```

### Skip Build (For Testing)

Use existing builds without rebuilding:

```powershell
# Android with existing APK
.\deploy-android.ps1 -Version "1.0.2" -ReleaseNotes "Notes" -SkipBuild

# Web with existing build
.\deploy-web.ps1 -SkipBuild
```

### Partial Deployment Examples

**Only update web app:**

```powershell
.\deploy-web.ps1
```

**Only update Android APK:**

```powershell
.\deploy-android.ps1 -Version "1.0.3" -ReleaseNotes "Hotfix"
```

**Full deployment:**

```powershell
.\deploy-all.ps1 -Version "1.1.0" -ReleaseNotes "New features"
```

## 📋 Script Parameters

### `deploy-all.ps1`

```powershell
.\deploy-all.ps1 `
    -Version "X.Y.Z" `           # Semantic version (required unless -WebOnly)
    -ReleaseNotes "Notes" `      # Release description (required unless -WebOnly)
    [-AndroidOnly] `             # Deploy only Android (skip web)
    [-WebOnly]                   # Deploy only web (skip Android)
```

### `deploy-android.ps1`

```powershell
.\deploy-android.ps1 `
    -Version "X.Y.Z" `           # Semantic version (required)
    -ReleaseNotes "Notes" `      # Release description (required)
    [-SkipBuild]                 # Use existing APK (optional)
```

### `deploy-web.ps1`

```powershell
.\deploy-web.ps1 `
    [-SkipBuild]                 # Use existing web build (optional)
```

### `deploy-release.ps1` (Legacy)

```powershell
.\deploy-release.ps1 `
    -Version "X.Y.Z" `           # Semantic version (required)
    -ReleaseNotes "Notes" `      # Release description (required)
    [-SkipBuild]                 # Use existing APK (optional)
```

## 🎯 Common Workflows

### Workflow 1: Standard Release

**Scenario:** New version with features for both platforms

```powershell
# One command deploys everything
.\deploy-all.ps1 -Version "1.2.0" -ReleaseNotes "
- New budget templates feature
- Improved charts UI
- Bug fixes for both platforms
"
```

**Result:**

- ✅ Android APK v1.2.0 on GitHub
- ✅ Web app deployed to Firebase
- ✅ Git tagged v1.2.0

### Workflow 2: Android Hotfix

**Scenario:** Critical bug only affects Android

```powershell
# Deploy only Android
.\deploy-android.ps1 -Version "1.1.1" -ReleaseNotes "Fixed crash on Android 14"
```

**Result:**

- ✅ Android APK v1.1.1 on GitHub
- ❌ Web app unchanged (still v1.1.0)

### Workflow 3: Web UI Update

**Scenario:** Updated landing page design

```powershell
# Deploy only web
.\deploy-web.ps1
```

**Result:**

- ❌ Android APK unchanged
- ✅ Web app updated on Firebase
- ❌ No version bump needed

### Workflow 4: Phased Rollout

**Scenario:** Deploy Android first, verify, then web

```powershell
# Phase 1: Android
.\deploy-all.ps1 -Version "1.3.0" -ReleaseNotes "Update" -AndroidOnly

# Test Android for 24 hours...

# Phase 2: Web
.\deploy-all.ps1 -WebOnly
```

**Result:**

- ✅ Android deployed on Day 1
- ✅ Web deployed on Day 2
- ✅ Risk mitigated with staged rollout

## 🆚 Script Comparison Table

| Aspect             | deploy-all.ps1 | deploy-android.ps1 | deploy-web.ps1 | deploy-release.ps1 |
| ------------------ | -------------- | ------------------ | -------------- | ------------------ |
| **Complexity**     | Medium         | Low                | Low            | Low                |
| **Flexibility**    | High           | Medium             | Low            | Low                |
| **Use Frequency**  | Very High      | Medium             | Medium         | Low                |
| **Recommended**    | ⭐⭐⭐⭐⭐     | ⭐⭐⭐⭐           | ⭐⭐⭐⭐       | ⭐⭐               |
| **Learning Curve** | Easy           | Easy               | Easy           | Easy               |
| **Maintenance**    | Active         | Active             | Active         | Legacy             |

## 📚 Documentation

For more details, see:

- **`DEPLOYMENT_GUIDE.md`** - Comprehensive deployment guide
- **`DEPLOY_QUICK_REF.md`** - Quick reference card
- **`README.md`** - Project overview with deployment section
- **`SIZE_OPTIMIZATION_SUMMARY.md`** - Build optimization details

## 🎉 Recommendation

**For most releases:** Use `deploy-all.ps1`

It provides:

- ✅ Single command deployment
- ✅ Consistent versioning across platforms
- ✅ Flexible options for partial deployment
- ✅ Best developer experience

**Quick start:**

```powershell
.\deploy-all.ps1 -Version "1.0.2" -ReleaseNotes "Bug fixes and improvements"
```

---

**Created:** December 9, 2025  
**Purpose:** Guide developers in choosing the right deployment script  
**Recommendation:** Use `deploy-all.ps1` for most scenarios
