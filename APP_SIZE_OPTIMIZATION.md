# App Size Optimization Guide

This document outlines strategies to reduce Budget Pillars app size.

## Current State Analysis

**APK Size:** 55.9 MB  
**Target:** < 20 MB

## Size Reduction Strategies

### 1. Enable Code Shrinking & Obfuscation ⭐ (Most Impact)

**Expected Reduction:** 30-50% of app size

Add to `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

**What it does:**
- `minifyEnabled` - Removes unused code (R8/ProGuard)
- `shrinkResources` - Removes unused resources (images, layouts, etc.)
- Obfuscates code for additional security

### 2. Split APKs by Architecture ⭐ (Most Impact)

**Expected Reduction:** 40-60% per APK (users download only what they need)

Add to `android/app/build.gradle.kts`:

```kotlin
android {
    // ... existing config
    
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = false
        }
    }
}
```

**What it does:**
- Creates separate APKs for each CPU architecture
- arm64-v8a: ~18-25 MB (most modern devices)
- armeabi-v7a: ~18-25 MB (older 32-bit devices)
- x86_64: ~18-25 MB (emulators/rare devices)
- Users download only the APK for their device

**Note:** For Google Play, use App Bundle instead - it automatically handles splits.

### 3. Optimize Images & Assets

**Current:** Using full-resolution app icon (120x120 displayed, but source may be larger)

**Actions:**
1. Compress app icon with WebP format:
   ```bash
   # Convert PNG to WebP
   flutter pub run flutter_launcher_icons:main
   ```

2. Add to `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     image_path: "assets/icon/app_icon.png"
     adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
     adaptive_icon_background: "#FFFFFF"
     remove_alpha_ios: true
     web:
       generate: true
   ```

### 4. Remove Unused Dependencies

**Current dependencies to review:**

| Dependency | Size Impact | Necessity | Action |
|------------|-------------|-----------|--------|
| `flutter_sms_inbox` | ~2 MB | SMS import feature | Keep (feature-critical) |
| `permission_handler` | ~1 MB | Required for SMS | Keep |
| `fl_chart` | ~3 MB | Charts feature | Keep (core feature) |
| `google_sign_in` | ~5 MB | Authentication | Keep (core feature) |
| `file_picker` | ~2 MB | Import/export | Keep (core feature) |

**No immediate removals recommended** - all dependencies are actively used.

### 5. Use App Bundle (AAB) Instead of APK ⭐

**App Bundle Benefits:**
- Google Play dynamically generates optimized APKs
- Users get only the code and resources for their device
- Automatic language/density splits
- **Typical reduction: 35-50% smaller downloads**

**Build command:**
```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

**Current setup:** ✅ Already using AAB for Play Store

### 6. Optimize Flutter Build Flags

**Current:** Default build settings

**Recommended build command:**
```bash
flutter build appbundle \
  --flavor prod \
  -t lib/main_prod.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info
```

**Flags explained:**
- `--obfuscate` - Obfuscates Dart code (smaller + more secure)
- `--split-debug-info` - Separates debug symbols (reduces size)

### 7. Tree Shake Icons (Already Active)

✅ **Already implemented** - Flutter automatically tree-shakes Material Icons:
- MaterialIcons reduced from 1.6 MB to 31 KB (98.1% reduction)
- CupertinoIcons reduced from 257 KB to 1.5 KB (99.4% reduction)

### 8. Analyze Actual Bundle Size

**Check what's taking space:**

```bash
# Build with size analysis
flutter build appbundle --analyze-size --target-platform android-arm64

# Or use bundletool
bundletool build-apks --bundle=build/app/outputs/bundle/prodRelease/app-prod-release.aab \
  --output=output.apks \
  --mode=universal

bundletool dump config --bundle=build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

### 9. Enable R8 Full Mode (Advanced)

**Default:** R8 compatibility mode

**Full mode:** More aggressive optimization

Add to `android/gradle.properties`:
```properties
android.enableR8.fullMode=true
```

**Warning:** Test thoroughly - may break reflection-based code.

### 10. Web-Specific Optimizations

For web builds, use CanvasKit only when needed:

```bash
# Use HTML renderer (smaller)
flutter build web --web-renderer html

# Or auto-detect
flutter build web --web-renderer auto
```

## Implementation Priority

### Immediate (Low Risk, High Impact)

1. ✅ **Enable minify & shrink resources** - Add to build.gradle.kts
2. ✅ **Use obfuscation flag** - Add to build command
3. ✅ **App Bundle** - Already using for Play Store

### Medium Term (Requires Testing)

4. **Split APKs by ABI** - For direct APK downloads (GitHub Releases)
5. **R8 full mode** - Test extensively
6. **Compress assets** - Optimize app icon

### Long Term (Requires Refactoring)

7. **Lazy load features** - Deferred components (requires restructuring)
8. **Dynamic feature modules** - Advanced Android feature

## Expected Results

| Optimization | Current | After | Reduction |
|--------------|---------|-------|-----------|
| **Current APK** | 55.9 MB | - | - |
| + Code shrinking | 55.9 MB | ~35 MB | -37% |
| + Obfuscation | 35 MB | ~33 MB | -6% |
| + ABI Splits | 33 MB | ~18 MB/APK | -45% |
| **App Bundle (Play Store)** | - | ~15 MB | -73% |

**Target:** 15-20 MB download size on Play Store

## Implementation Steps

### Step 1: Enable ProGuard/R8 (Code Shrinking)

Edit `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

Create `android/app/proguard-rules.pro`:

```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Gson (for JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Freezed models
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
```

### Step 2: Update Build Command

```bash
flutter build appbundle \
  --flavor prod \
  -t lib/main_prod.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info
```

### Step 3: Update Deployment Script

Edit `deploy-release.ps1` to use optimized build command.

### Step 4: Test Thoroughly

After enabling optimizations:
1. Install on physical device
2. Test all features (auth, data sync, import/export, charts)
3. Check for crashes or missing functionality
4. Review ProGuard mapping file for debugging

## Monitoring

**After optimization, check:**
- Download size in Play Console
- Install size on device
- App startup time
- Memory usage
- Crash reports (obfuscation issues)

## Debugging Obfuscated Builds

When crashes occur in release builds:

1. **Upload mapping file** to Firebase Crashlytics:
   ```
   build/app/outputs/mapping/prodRelease/mapping.txt
   ```

2. **Keep debug symbols** for stack trace symbolication:
   ```
   build/debug-info/
   ```

## Resources

- [Android Size Reduction](https://docs.flutter.dev/perf/app-size)
- [R8 Code Shrinking](https://developer.android.com/build/shrink-code)
- [App Bundle Format](https://developer.android.com/guide/app-bundle)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)

---

**Last Updated:** December 9, 2025  
**Target Size:** 15-20 MB (Play Store download)  
**Current Size:** 55.9 MB APK / ~35 MB AAB (estimated)
