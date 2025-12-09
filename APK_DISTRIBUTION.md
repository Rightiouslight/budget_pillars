# APK Distribution & Version Management

This document explains how Budget Pillars handles APK distribution through GitHub Releases and automatic version checking for updates.

## Table of Contents

- [Overview](#overview)
- [Version Numbering Strategy](#version-numbering-strategy)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [Deployment Workflow](#deployment-workflow)
- [User Experience](#user-experience)
- [Technical Details](#technical-details)
- [Troubleshooting](#troubleshooting)

---

## Overview

Budget Pillars uses a hybrid approach for APK distribution:

- **GitHub Releases**: Hosts APK files with unlimited bandwidth
- **Firebase Hosting**: Hosts the web app (optional: can show download page)
- **Automatic Version Checking**: Mobile app checks GitHub API on launch/resume

### Why GitHub Releases?

✅ **Free & Unlimited Bandwidth** - No hosting costs or limits  
✅ **Version Control Integration** - Releases tied to Git tags  
✅ **Download Analytics** - Track downloads per release  
✅ **Professional** - Standard practice for app distribution  
✅ **Simple API** - Easy programmatic access

---

## Version Numbering Strategy

Budget Pillars follows Semantic Versioning (`MAJOR.MINOR.PATCH+BUILD`):

### Version Format

```
1.0.1+2
│ │ │  └─ Build number (auto-incremented)
│ │ └──── PATCH version
│ └────── MINOR version
└──────── MAJOR version
```

### Update Types

| Change                       | Version           | Update Type   | User Action |
| ---------------------------- | ----------------- | ------------- | ----------- |
| Bug fix, minor improvement   | `1.0.0` → `1.0.1` | **Optional**  | Can skip    |
| New feature, breaking change | `1.0.0` → `1.1.0` | **Mandatory** | Must update |
| Major overhaul               | `1.0.0` → `2.0.0` | **Mandatory** | Must update |

### Logic

```dart
bool isMandatory(Version current, Version latest) {
  // Mandatory if MAJOR or MINOR version changed
  return latest.major > current.major || latest.minor > current.minor;
}
```

**Examples:**

- `1.0.0` → `1.0.5`: Optional (patch changes)
- `1.0.0` → `1.1.0`: Mandatory (minor version bump)
- `1.5.3` → `2.0.0`: Mandatory (major version bump)

---

## Architecture

```
┌─────────────────────────────────────────────┐
│          GitHub Releases                    │
│  ┌────────────────────────────────────┐    │
│  │  v1.0.1                             │    │
│  │  - budget-pillars-v1.0.1.apk       │    │
│  │  - Release notes                    │    │
│  │  - Download count                   │    │
│  └────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
                    ↑
                    │ GitHub API
                    │ GET /repos/{owner}/{repo}/releases/latest
                    │
┌─────────────────────────────────────────────┐
│        Mobile App (Flutter Android)         │
│  ┌────────────────────────────────────┐    │
│  │  VersionCheckObserver               │    │
│  │  - Checks on app launch             │    │
│  │  - Checks on app resume             │    │
│  │  - Compares versions                │    │
│  │  - Shows update dialog/blocker      │    │
│  └────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

---

## Setup Instructions

### 1. Configure GitHub Repository

1. **Create GitHub Repository**

   ```powershell
   # If not already done
   git remote add origin https://github.com/YOUR_USERNAME/budget_pillars.git
   git push -u origin main
   ```

2. **Update Version Check Service**

   Edit `lib/features/update/services/version_check_service.dart`:

   ```dart
   static const _githubOwner = 'YOUR_GITHUB_USERNAME';  // ← Change this
   static const _githubRepo = 'budget_pillars';
   ```

3. **Install GitHub CLI** (for automated releases)
   ```powershell
   winget install GitHub.cli
   gh auth login
   ```

### 2. Update Deployment Script

Edit `deploy-release.ps1` and replace placeholders:

```powershell
# Line 152: Update GitHub username
$releaseUrl = "https://github.com/YOUR_GITHUB_USERNAME/budget_pillars/releases/tag/$tagName"

# Line 171: Update download URL
Write-Host "https://github.com/YOUR_GITHUB_USERNAME/budget_pillars/releases/download/$tagName/$apkFileName"
```

---

## Deployment Workflow

### Quick Release (Automated)

```powershell
# Deploy version 1.0.1 with custom release notes
.\deploy-release.ps1 -Version "1.0.1" -ReleaseNotes "- Fixed budget deletion bug`n- Improved performance"

# Deploy with default release notes
.\deploy-release.ps1 -Version "1.0.2"
```

The script automatically:

1. ✅ Updates `pubspec.yaml` version and build number
2. ✅ Builds production APK
3. ✅ Creates Git tag (`v1.0.1`)
4. ✅ Pushes tag to GitHub
5. ✅ Creates GitHub Release with APK attached

### Manual Release (Step by Step)

#### Step 1: Update Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.1+2 # Increment version and build number
```

#### Step 2: Build APK

```powershell
flutter clean
flutter pub get
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

APK location: `build/app/outputs/flutter-apk/app-prod-release.apk`

#### Step 3: Create Git Tag

```powershell
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.1"
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin v1.0.1
```

#### Step 4: Create GitHub Release

**Option A: Using GitHub CLI**

```powershell
gh release create v1.0.1 `
  --title "Version 1.0.1" `
  --notes "Bug fixes and improvements" `
  "build/app/outputs/flutter-apk/app-prod-release.apk#budget-pillars-v1.0.1.apk"
```

**Option B: Using GitHub Web UI**

1. Go to repository → Releases → Draft new release
2. Choose tag `v1.0.1`
3. Title: `Version 1.0.1`
4. Description: Release notes
5. Attach APK file
6. Click "Publish release"

---

## User Experience

### Optional Update Flow

1. User opens app
2. App checks GitHub API in background
3. If optional update available (patch version):
   - Shows dialog with "Later" and "Download" buttons
   - User can dismiss and continue using app
   - Dialog shows release notes and file size

### Mandatory Update Flow

1. User opens app
2. App checks GitHub API in background
3. If mandatory update available (major/minor version):
   - Shows full-screen blocker screen
   - User CANNOT use app until updated
   - Shows release notes, download instructions
   - "Download" button opens browser to APK

### Installation Process

1. User taps "Download" button
2. Browser downloads APK
3. User opens APK from notifications
4. Android shows "Install from Unknown Sources" permission
5. User enables permission
6. App installs
7. User opens updated app

---

## Technical Details

### Files Created

```
lib/features/update/
├── models/
│   ├── update_info.dart              # UpdateInfo model
│   └── update_info.freezed.dart      # Generated freezed code
├── services/
│   └── version_check_service.dart    # GitHub API integration
├── widgets/
│   ├── update_dialog.dart            # Optional update dialog
│   └── update_blocker_screen.dart    # Mandatory update screen
└── providers/
    └── version_check_provider.dart   # Version check observer
```

### GitHub API Response

```json
{
  "tag_name": "v1.0.1",
  "name": "Version 1.0.1",
  "body": "## What's New\n- Bug fixes\n- Performance improvements",
  "published_at": "2024-12-09T10:00:00Z",
  "assets": [
    {
      "name": "budget-pillars-v1.0.1.apk",
      "browser_download_url": "https://github.com/.../budget-pillars-v1.0.1.apk",
      "size": 52428800,
      "download_count": 150
    }
  ]
}
```

### Version Check Logic

```dart
// Fetch latest release
final response = await http.get(
  Uri.parse('https://api.github.com/repos/{owner}/{repo}/releases/latest'),
);

// Compare versions
final latest = Version.parse(latestVersion);
final current = Version.parse(currentVersion);

final hasUpdate = latest > current;
final isMandatory = latest.major > current.major || latest.minor > current.minor;
```

### When Version Checks Occur

- ✅ **On app launch**: First time app opens
- ✅ **On app resume**: When app comes to foreground from background
- ❌ **Not in debug mode**: Disabled during development
- ❌ **Not on web**: Only checks on mobile platforms (Android/iOS)

---

## Troubleshooting

### "No releases found in GitHub repository"

**Problem**: GitHub API returns 404  
**Solution**:

1. Ensure you've created at least one release
2. Check repository is public or you're authenticated
3. Verify `_githubOwner` and `_githubRepo` are correct

### "Could not open download link"

**Problem**: URL launcher fails  
**Solution**:

1. Check internet connection
2. Verify download URL is valid
3. Check `url_launcher` package is installed

### Version check not triggering

**Problem**: Update dialog doesn't appear  
**Solution**:

1. Check you're running in **release mode** (not debug)
2. Verify you're on **Android/iOS** (not web)
3. Check console for errors (version check fails silently)
4. Ensure GitHub release exists and is public

### APK installation fails

**Problem**: Android won't install APK  
**Solution**:

1. Enable "Install from Unknown Sources":
   - Settings → Security → Unknown Sources
   - Or: Settings → Apps → Special Access → Install Unknown Apps
2. Ensure APK is not corrupted (re-download)
3. Check Android version compatibility

### Build number not incrementing

**Problem**: `deploy-release.ps1` fails to update version  
**Solution**:

1. Ensure `pubspec.yaml` has format: `version: X.Y.Z+N`
2. Check file permissions (not read-only)
3. Manually update if script fails

---

## Best Practices

### Versioning

✅ **DO**: Use patch versions (1.0.X) for bug fixes  
✅ **DO**: Use minor versions (1.X.0) for new features  
✅ **DO**: Use major versions (X.0.0) for breaking changes  
✅ **DO**: Write clear, user-friendly release notes  
❌ **DON'T**: Skip version numbers  
❌ **DON'T**: Reuse version numbers

### Release Notes

Good example:

```markdown
## What's New

- Fixed crash when deleting pocket with recurring categories
- Improved app performance
- Updated category icons

## Bug Fixes

- Resolved issue with SMS import
- Fixed date picker on Android 14
```

Bad example:

```markdown
Bug fixes and improvements
```

### Testing

Before releasing:

1. ✅ Test APK on physical device
2. ✅ Verify version number is correct
3. ✅ Test update flow (install old version, trigger update)
4. ✅ Check release notes are accurate
5. ✅ Ensure APK file size is reasonable

---

## Future Enhancements

Potential improvements:

- **Staged Rollouts**: Use Firestore to control update percentage
- **In-App Updates**: Use Android's in-app update API
- **Update Scheduling**: Allow users to schedule update installation
- **Delta Updates**: Only download changed parts (reduces file size)
- **Auto-Download**: Download APK in background when on WiFi
- **Beta Channel**: Separate releases for beta testers

---

## Support

For issues:

1. Check GitHub Releases page for download statistics
2. Review version check service logs
3. Test with mock GitHub API responses
4. Consult Flutter `package_info_plus` and `url_launcher` documentation

**Last Updated**: December 9, 2024  
**Version**: 1.0.0
