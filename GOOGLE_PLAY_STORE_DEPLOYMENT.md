# Google Play Store Deployment Guide

## Budget Pillars - Android Release Checklist

This document outlines all the steps required to publish Budget Pillars to the Google Play Store.

---

## Pre-Launch Checklist

### 1. App Preparation

#### Update App Information

- [ ] **App Name**: Verify "Budget Pillars" is the final name
- [ ] **Package Name**: Check `android/app/build.gradle.kts` - `applicationId`
  - Current: `com.example.easy_budget_pillars` (⚠️ Should be changed from "example")
  - Recommended: `com.budgetpillars.app` or `com.yourcompany.budgetpillars`
- [ ] **Version Code & Name**: Update in `android/app/build.gradle.kts`
  - `versionCode`: Integer that increments with each release (e.g., 1, 2, 3...)
  - `versionName`: User-facing version (e.g., "1.0.0")

#### App Icon & Branding

- [ ] **App Icon**: Create launcher icons for all densities
  - Use `flutter_launcher_icons` package
  - Icon sizes: mdpi (48x48), hdpi (72x72), xhdpi (96x96), xxhdpi (144x144), xxxhdpi (192x192)
  - Location: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- [ ] **Adaptive Icon**: For Android 8.0+ (API 26+)
  - Foreground and background layers
  - Location: `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
- [ ] **Feature Graphic**: 1024x500 px (for Play Store listing)
- [ ] **Screenshots**:
  - Phone: Min 2, max 8 (recommended: 4-6)
  - Sizes: 320-3840 pixels (16:9 or 9:16 recommended)
  - Tablet screenshots (optional but recommended)
- [ ] **Promo Video**: YouTube link (optional)

#### App Configuration

- [ ] **Remove Debug Code**:
  - Remove hardcoded test credentials from `lib/features/auth/auth_screen.dart`

    ```dart
    // REMOVE THESE LINES:
    final _emailController = TextEditingController(text: 'heinrichdut@gmail.com');
    final _passwordController = TextEditingController(text: 'password');

    // REPLACE WITH:
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    ```
- [ ] **Environment Variables**: Ensure no sensitive data is hardcoded
- [ ] **Analytics**: Set up Firebase Analytics for production
- [ ] **Crash Reporting**: Enable Firebase Crashlytics

---

## 2. Firebase Configuration

### Android Setup

- [ ] **Firebase Console**: Create production project
- [ ] **Add Android App**:
  - Package name must match `applicationId` in `build.gradle.kts`
  - Download `google-services.json`
  - Place in `android/app/` directory
- [ ] **Enable Authentication**:
  - Email/Password: Enable in Firebase Console → Authentication
  - Google Sign-In: Add SHA-1 and SHA-256 fingerprints
- [ ] **Firestore Rules**: Update for production
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      // User data - only owner can read/write
      match /users/{userId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;

        // Monthly budgets subcollection
        match /monthly_budgets/{budgetId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
  }
  ```
- [ ] **Firebase Storage Rules**: If using file storage
- [ ] **API Keys**: Restrict API keys in Google Cloud Console

### Get SHA-1 and SHA-256 Fingerprints

```powershell
# Debug keystore (for testing)
cd android
.\gradlew signingReport

# Release keystore (after creating it)
keytool -list -v -keystore path/to/your-release-key.jks -alias your-key-alias
```

---

## 3. App Signing

### Create Upload Keystore

```powershell
# Navigate to android/app directory
cd android\app

# Generate keystore (replace values with your info)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# You'll be prompted for:
# - Keystore password (SAVE THIS SECURELY)
# - Key password (SAVE THIS SECURELY)
# - Your name, organization, etc.
```

### Create key.properties File

- [ ] Create `android/key.properties` (⚠️ DO NOT commit to Git)

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

### Update .gitignore

- [ ] Ensure these are in `.gitignore`:

```gitignore
# Keystore files
*.jks
*.keystore
**/key.properties
```

### Configure Signing in build.gradle.kts

- [ ] Update `android/app/build.gradle.kts`:

```kotlin
// Add before android block
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing configuration ...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ... other release config ...
        }
    }
}
```

---

## 4. Build Configuration

### Update android/app/build.gradle.kts

```kotlin
android {
    namespace = "com.budgetpillars.app" // Change from example
    compileSdk = 34 // Use latest stable

    defaultConfig {
        applicationId = "com.budgetpillars.app" // Must match Firebase
        minSdk = 21 // Android 5.0
        targetSdk = 34 // Latest
        versionCode = 1 // Increment for each release
        versionName = "1.0.0" // Semantic versioning
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### ProGuard Rules (android/app/proguard-rules.pro)

- [ ] Add rules for Firebase and other libraries:

```proguard
# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
```

### Update AndroidManifest.xml

- [ ] Check `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" />

    <application
        android:label="Budget Pillars"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">

        <!-- ... activities ... -->

    </application>
</manifest>
```

---

## 5. Build Release APK/AAB

### Test Release Build

```powershell
# Build release APK for testing
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### Verify Build

- [ ] **Location**:
  - APK: `build/app/outputs/flutter-apk/app-release.apk`
  - AAB: `build/app/outputs/bundle/release/app-release.aab`
- [ ] **Test APK**: Install on physical device and test thoroughly

```powershell
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Build Size Optimization

- [ ] **Split APKs by ABI** (optional, in build.gradle.kts):

```kotlin
android {
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
}
```

---

## 6. Testing

### Pre-Release Testing

- [ ] **Functional Testing**: All features work correctly
  - Authentication (email/password, Google Sign-In)
  - Account creation and management
  - Budget creation and editing
  - Categories and pockets
  - Transactions (add, edit, delete)
  - SMS import
  - Sinking funds
  - Reports and analytics
  - Settings and preferences
- [ ] **Performance Testing**: App runs smoothly on low-end devices
- [ ] **Security Testing**:
  - Sensitive data is encrypted
  - API keys are secure
  - User data is protected
- [ ] **Permission Testing**: SMS permissions work correctly
- [ ] **Offline Testing**: App handles no internet gracefully
- [ ] **Different Android Versions**: Test on API 21-34
- [ ] **Different Screen Sizes**: Test on phones and tablets

### Beta Testing

- [ ] **Internal Testing**: Google Play Console internal testing track
- [ ] **Closed Testing**: Invite specific testers
- [ ] **Open Testing**: Public beta (optional)

---

## 7. Google Play Console Setup

### Create Developer Account

- [ ] **Sign up**: https://play.google.com/console
- [ ] **Pay fee**: $25 one-time registration fee
- [ ] **Verify identity**: Complete account verification

### Create New App

- [ ] **App Details**:
  - App name: "Budget Pillars"
  - Default language: English (US)
  - App or game: Application
  - Free or paid: Free
- [ ] **Store Listing**:

  - **Short description** (80 chars max):
    ```
    Manage your budget with pillars. Track income, expenses, and savings goals.
    ```
  - **Full description** (4000 chars max):

    ```
    Budget Pillars helps you take control of your finances with a unique
    pillar-based budgeting system. Create custom categories, track expenses,
    manage multiple accounts, and achieve your savings goals.

    KEY FEATURES:
    • 📊 Visual Budget Tracking - See your spending at a glance
    • 💰 Multiple Accounts - Manage checking, savings, and cash accounts
    • 🎯 Sinking Funds - Save for specific goals over time
    • 📱 SMS Import - Automatically import transactions from bank SMS
    • 📈 Detailed Reports - Analyze spending patterns by category
    • 🔄 Account Transfers - Move money between accounts easily
    • 🎨 Custom Categories - Create categories with icons and budgets
    • 💵 Pocket System - Allocate money to specific purposes
    • 🔒 Secure - Firebase authentication and cloud sync
    • 📊 Monthly Budgets - Plan and track month by month

    PERFECT FOR:
    • Personal finance management
    • Budget planning and tracking
    • Expense categorization
    • Savings goal achievement
    • Multi-account management

    Start building your financial pillars today!
    ```

  - **Screenshots**: Upload 4-8 screenshots
  - **Feature graphic**: Upload 1024x500 image
  - **App icon**: 512x512 PNG
  - **App category**: Finance
  - **Tags**: budget, finance, expense tracker, money management
  - **Contact details**: Email, phone (optional), website (optional)
  - **Privacy policy**: URL to privacy policy (REQUIRED)

### Content Rating

- [ ] Complete questionnaire
- [ ] Budget Pillars should be rated: Everyone

### App Content

- [ ] **Privacy Policy**: Create and host privacy policy
  - Required sections:
    - What data is collected (email, budget data)
    - How data is used (authentication, budget storage)
    - Data sharing (none, or specify)
    - User rights (access, deletion)
    - Contact information
  - Host on website or use: https://app-privacy-policy-generator.nisrulz.com/
- [ ] **Data Safety**:
  - Declare data collection and security practices
  - Data types: Personal info (email), Financial info (transactions, budgets)
  - Data usage: App functionality, account management
  - Data sharing: No third-party sharing
  - Security practices: Data encrypted in transit, data encrypted at rest
  - User controls: Can request data deletion
- [ ] **App Access**:
  - If app requires login, provide demo account credentials
  - Or enable app access without sign-in for reviewers
- [ ] **Ads**: Does app contain ads? No
- [ ] **Target Audience**:
  - Age: 13+
  - Appeals to children: No

### Pricing & Distribution

- [ ] **Countries**: Select all available countries or specific regions
- [ ] **Pricing**: Free
- [ ] **Contains ads**: No
- [ ] **In-app purchases**: No (unless you plan to add premium features)
- [ ] **Content guidelines**: Confirm app follows all policies
- [ ] **US export laws**: Confirm compliance

---

## 8. Upload to Play Console

### Production Release

- [ ] **Go to**: Production → Create new release
- [ ] **Upload AAB**: Upload `app-release.aab`
- [ ] **Release name**: 1.0.0 (matches versionName)
- [ ] **Release notes** (500 chars per language):

  ```
  Initial release of Budget Pillars!

  Features:
  • Visual budget tracking with categories and pockets
  • Multiple account management
  • Sinking funds for savings goals
  • SMS transaction import
  • Detailed spending reports
  • Secure cloud sync with Firebase
  • Dark mode support

  Start managing your budget today!
  ```

- [ ] **Review summary**: Check all information
- [ ] **Save** (don't submit yet)

### Internal Testing (Recommended First)

- [ ] **Create internal testing release**
- [ ] **Add testers**: Use email list
- [ ] **Share link**: Send to testers
- [ ] **Collect feedback**: Fix any issues
- [ ] **Iterate**: Upload new versions as needed

---

## 9. Review Process

### Submit for Review

- [ ] **Complete all sections**: Ensure 100% completion in dashboard
- [ ] **Submit app**: Click "Send for review"
- [ ] **Wait**: Review typically takes 1-7 days (sometimes longer)

### Common Rejection Reasons

- Missing privacy policy
- Incomplete store listing
- App crashes on launch
- Missing permissions declarations
- Unclear app functionality
- Misleading screenshots or description
- Permissions not used (remove unused permissions)

### After Approval

- [ ] **App goes live**: Usually within hours of approval
- [ ] **Monitor**: Check for crash reports and user reviews
- [ ] **Respond**: Reply to user reviews
- [ ] **Update**: Plan future releases

---

## 10. Post-Launch

### Monitoring

- [ ] **Firebase Console**: Monitor active users, crashes
- [ ] **Play Console**: Check statistics, reviews, ratings
- [ ] **User Feedback**: Read and respond to reviews
- [ ] **Crash Reports**: Fix critical bugs immediately

### Updates

- [ ] **Version Management**: Increment versionCode and versionName
- [ ] **Release Notes**: Write clear update descriptions
- [ ] **Staged Rollout**: Release to percentage of users first (recommended)
- [ ] **Testing**: Always test updates before releasing

### Marketing

- [ ] **App Store Optimization (ASO)**:
  - Optimize title and description for search
  - Use relevant keywords
  - Update screenshots regularly
  - Encourage positive reviews
- [ ] **Social Media**: Share on platforms
- [ ] **Website**: Create landing page
- [ ] **User Acquisition**: Consider ads or organic growth strategies

---

## 11. Important Files Checklist

### Must Be Updated

- ✅ `android/app/build.gradle.kts` - Package name, version, signing
- ✅ `android/app/src/main/AndroidManifest.xml` - App name, permissions
- ✅ `android/app/google-services.json` - Firebase config
- ✅ `android/app/src/main/res/mipmap-*/` - App icons
- ✅ `android/key.properties` - Signing credentials (create new)
- ✅ `lib/features/auth/auth_screen.dart` - Remove test credentials

### Must Be Created

- ✅ Privacy Policy (hosted URL)
- ✅ Upload Keystore (`upload-keystore.jks`)
- ✅ Feature Graphic (1024x500)
- ✅ Screenshots (4-8 images)
- ✅ App Icon (512x512)

### Must Be Added to .gitignore

- ✅ `*.jks`
- ✅ `*.keystore`
- ✅ `**/key.properties`
- ✅ `android/app/google-services.json` (if contains sensitive data)

---

## 12. Quick Command Reference

```powershell
# Clean build
flutter clean
flutter pub get

# Build release APK (for testing)
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Install APK on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Check app size
adb shell pm list packages -f | findstr budgetpillars

# Get signing report
cd android
.\gradlew signingReport

# Check for issues
flutter analyze
flutter test
```

---

## 13. Troubleshooting

### Build Errors

- **Gradle sync failed**: Update Android Studio and Gradle versions
- **Signing failed**: Check `key.properties` path and passwords
- **Firebase error**: Verify `google-services.json` package name matches

### Upload Errors

- **Package name conflict**: Can't change after first upload
- **Version conflict**: Increment versionCode
- **Size too large**: Enable ProGuard, split APKs by ABI

### Review Rejections

- **Privacy policy**: Must be accessible and comprehensive
- **Permissions**: Only request necessary permissions
- **Crashes**: Test thoroughly before submitting

---

## Resources

- **Flutter Deployment Guide**: https://docs.flutter.dev/deployment/android
- **Google Play Console**: https://play.google.com/console
- **Firebase Console**: https://console.firebase.google.com
- **Material Design Icons**: https://fonts.google.com/icons
- **Privacy Policy Generator**: https://app-privacy-policy-generator.nisrulz.com/
- **App Store Optimization**: https://developer.android.com/distribute/best-practices/grow

---

## Timeline Estimate

- **Preparation**: 2-4 hours (icons, screenshots, descriptions)
- **Configuration**: 1-2 hours (signing, Firebase, build config)
- **Testing**: 4-8 hours (thorough testing on multiple devices)
- **Play Console Setup**: 1-2 hours (filling out all forms)
- **Review Wait**: 1-7 days (Google's timeline)
- **Total**: Approximately 1-2 weeks from start to live

---

## Notes

⚠️ **CRITICAL**:

- Never commit signing keys or passwords to Git
- Test the release build thoroughly before submitting
- Package name cannot be changed after first upload
- Keep keystore file and passwords secure - losing them means you can't update your app

📝 **RECOMMENDATIONS**:

- Use internal testing track first
- Start with a staged rollout (10% → 50% → 100%)
- Set up Firebase Crashlytics before launch
- Have a support email ready for user questions
- Plan your first update before launch

🎯 **SUCCESS CHECKLIST**:

- [ ] All features work in release build
- [ ] No test/debug code in production
- [ ] Firebase configured for production
- [ ] App signed with upload keystore
- [ ] Privacy policy published
- [ ] Store listing complete with all assets
- [ ] Tested on multiple devices and Android versions
- [ ] Ready to respond to user feedback

---

**Good luck with your launch! 🚀**
