# Flutter Flavors Implementation Guide

## Overview

Flutter flavors allow you to build different versions of your app from a single codebase with different configurations, Firebase projects, app names, and bundle identifiers - all controlled by the build command.

## Current vs. Flavors Approach

### Current Workflow (Manual)

```dart
// lib/config/environment.dart
static const Environment currentEnvironment = Environment.development; // Manual change
```

- Manually edit environment.dart
- Manually swap google-services.json files
- Risk of deploying wrong environment
- No compile-time safety

### With Flavors (Automatic)

```bash
flutter run --flavor dev           # Uses development Firebase
flutter run --flavor prod          # Uses production Firebase
flutter build appbundle --flavor prod  # Production build
```

- Command line controls everything
- No manual file editing
- Impossible to mix configs
- Different app IDs can coexist on same device

## Implementation Difficulty

**Estimated Time:** 2-3 hours for initial setup

**Complexity:** Medium

- Android: Moderate (Gradle configuration)
- iOS/macOS: Moderate (Xcode schemes)
- Web: Easy (build arguments)
- Code: Easy (compile-time constants)

**Benefits:**

- ✅ Automatic environment selection
- ✅ No manual config file swapping
- ✅ Multiple builds can run simultaneously
- ✅ CI/CD friendly
- ✅ Prevents production accidents
- ✅ Different app names per flavor
- ✅ Different app icons possible

## Implementation Steps

### Step 1: Android Configuration

**1.1: Create Flavor Directories**

```
android/app/src/
├── dev/
│   └── google-services.json          # Development Firebase config
├── prod/
│   └── google-services.json          # Production Firebase config
└── main/
    └── AndroidManifest.xml
    └── kotlin/...
```

**1.2: Update `android/app/build.gradle.kts`**

Add product flavors configuration:

```kotlin
android {
    namespace = "budgetpillars.lojinnovation.com"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // ... existing configuration ...

    defaultConfig {
        applicationId = "budgetpillars.lojinnovation.com"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
    }

    // ADD THIS SECTION
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Budget Pillars DEV")
        }

        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Budget Pillars")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
```

**1.3: Update AndroidManifest.xml to use flavor-specific app name**

```xml
<application
    android:label="@string/app_name"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

**1.4: Move Firebase Config Files**

```powershell
# Create flavor directories
New-Item -ItemType Directory -Force -Path "android\app\src\dev"
New-Item -ItemType Directory -Force -Path "android\app\src\prod"

# Move config files
Move-Item "android\app\google-services.dev.json" "android\app\src\dev\google-services.json"
Move-Item "android\app\google-services.prod.json" "android\app\src\prod\google-services.json"

# Delete the old main google-services.json
Remove-Item "android\app\google-services.json"
```

### Step 2: iOS Configuration

**2.1: Create Xcode Schemes**

In Xcode (for iOS/macOS):

1. Open `ios/Runner.xcworkspace`
2. Product → Scheme → Manage Schemes
3. Duplicate "Runner" scheme, name it "dev"
4. Duplicate "Runner" scheme, name it "prod"
5. For each scheme:
   - Edit Scheme → Build → Pre-actions
   - Add Run Script action

**2.2: Create Configuration Files**

Create flavor-specific configs:

```
ios/
├── Firebase/
│   ├── Dev/
│   │   └── GoogleService-Info.plist
│   └── Prod/
│       └── GoogleService-Info.plist
```

**2.3: Build Script for iOS**

Create `ios/Scripts/firebase_config.sh`:

```bash
#!/bin/sh

# Get the flavor from environment variable
FLAVOR=${CONFIGURATION}

if [ "${FLAVOR}" == "Debug-dev" ] || [ "${FLAVOR}" == "Release-dev" ]; then
    echo "Using DEV Firebase configuration"
    cp -r "${PROJECT_DIR}/Firebase/Dev/GoogleService-Info.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
elif [ "${FLAVOR}" == "Debug-prod" ] || [ "${FLAVOR}" == "Release-prod" ]; then
    echo "Using PROD Firebase configuration"
    cp -r "${PROJECT_DIR}/Firebase/Prod/GoogleService-Info.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
else
    echo "Using DEV Firebase configuration (default)"
    cp -r "${PROJECT_DIR}/Firebase/Dev/GoogleService-Info.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
fi
```

### Step 3: Dart/Flutter Code

**3.1: Create Flavor Configuration**

Create `lib/config/flavor_config.dart`:

```dart
enum Flavor {
  dev,
  prod,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String displayName;
  final FlavorValues values;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required String displayName,
    required FlavorValues values,
  }) {
    _instance ??= FlavorConfig._internal(
      flavor,
      name,
      displayName,
      values,
    );
    return _instance!;
  }

  FlavorConfig._internal(
    this.flavor,
    this.name,
    this.displayName,
    this.values,
  );

  static FlavorConfig get instance {
    return _instance!;
  }

  static bool get isDevelopment => _instance?.flavor == Flavor.dev;
  static bool get isProduction => _instance?.flavor == Flavor.prod;
}

class FlavorValues {
  final String firebaseProjectId;
  final String apiBaseUrl;
  final bool enableLogging;

  FlavorValues({
    required this.firebaseProjectId,
    required this.apiBaseUrl,
    required this.enableLogging,
  });
}
```

**3.2: Create Flavor Entry Points**

Create `lib/main_dev.dart`:

```dart
import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main.dart' as runner;

void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    displayName: 'Budget Pillars DEV',
    values: FlavorValues(
      firebaseProjectId: 'budgetpillarsdev',
      apiBaseUrl: 'https://dev-api.example.com',
      enableLogging: true,
    ),
  );

  runner.main();
}
```

Create `lib/main_prod.dart`:

```dart
import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main.dart' as runner;

void main() {
  FlavorConfig(
    flavor: Flavor.prod,
    name: 'PROD',
    displayName: 'Budget Pillars',
    values: FlavorValues(
      firebaseProjectId: 'pocketflow-tw4kf',
      apiBaseUrl: 'https://api.example.com',
      enableLogging: false,
    ),
  );

  runner.main();
}
```

**3.3: Update Firebase Initialization**

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'firebase_options_dev.dart' as firebase_dev;
import 'firebase_options_prod.dart' as firebase_prod;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with flavor-specific options
  if (FlavorConfig.isDevelopment) {
    await Firebase.initializeApp(
      options: firebase_dev.DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: firebase_prod.DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlavorConfig.instance.displayName,
      // ... rest of your app
    );
  }
}
```

**3.4: Generate Firebase Options for Each Flavor**

```bash
# Development
flutterfire configure --project=budgetpillarsdev --out=lib/firebase_options_dev.dart

# Production
flutterfire configure --project=pocketflow-tw4kf --out=lib/firebase_options_prod.dart
```

**3.5: Remove Old Environment File**

Delete or deprecate `lib/config/environment.dart` since it's replaced by FlavorConfig.

### Step 4: Web Configuration

**4.1: Create Flavor-Specific Web Configs**

Create separate Firebase config scripts:

`web/firebase_config_dev.js`:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_DEV_API_KEY",
  authDomain: "budgetpillarsdev.firebaseapp.com",
  projectId: "budgetpillarsdev",
  storageBucket: "budgetpillarsdev.appspot.com",
  messagingSenderId: "487033381743",
  appId: "YOUR_DEV_APP_ID",
};
```

`web/firebase_config_prod.js`:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_PROD_API_KEY",
  authDomain: "pocketflow-tw4kf.firebaseapp.com",
  projectId: "pocketflow-tw4kf",
  storageBucket: "pocketflow-tw4kf.appspot.com",
  messagingSenderId: "1065513142302",
  appId: "YOUR_PROD_APP_ID",
};
```

**4.2: Build Script for Web**

Create `build_web.ps1`:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','prod')]
    [string]$Flavor
)

Write-Host "Building web for $Flavor environment..." -ForegroundColor Green

# Build with flavor-specific entry point
flutter build web --target=lib/main_$Flavor.dart

# Copy flavor-specific Firebase config
Copy-Item "web\firebase_config_$Flavor.js" "build\web\firebase_config.js" -Force

Write-Host "Build complete!" -ForegroundColor Green
```

### Step 5: Update .gitignore

Since configs are now in flavor directories, update `.gitignore`:

```gitignore
# Firebase configs are now flavor-specific, still ignored
android/app/src/dev/google-services.json
android/app/src/prod/google-services.json
lib/firebase_options_dev.dart
lib/firebase_options_prod.dart
ios/Firebase/Dev/GoogleService-Info.plist
ios/Firebase/Prod/GoogleService-Info.plist
web/firebase_config_dev.js
web/firebase_config_prod.js
```

## Usage

### Running the App

**Development:**

```bash
# Android
flutter run --flavor dev -t lib/main_dev.dart

# iOS
flutter run --flavor dev -t lib/main_dev.dart

# Web
flutter run -d chrome -t lib/main_dev.dart

# Shorthand (create scripts)
flutter run --flavor dev  # if main_dev.dart is configured in flutter build
```

**Production:**

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

### Building Release Versions

**Android:**

```bash
# Development APK/Bundle
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build appbundle --flavor dev -t lib/main_dev.dart

# Production APK/Bundle
flutter build apk --flavor prod -t lib/main_prod.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

**iOS:**

```bash
flutter build ios --flavor prod -t lib/main_prod.dart
```

**Web:**

```powershell
.\build_web.ps1 -Flavor dev
.\build_web.ps1 -Flavor prod
```

### VS Code Launch Configurations

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"]
    },
    {
      "name": "Development (Web)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["-d", "chrome"]
    }
  ]
}
```

Now you can just click the play button and select the flavor!

## Advanced: Make It Even Easier

### Create Helper Scripts

**`run_dev.ps1`:**

```powershell
flutter run --flavor dev -t lib/main_dev.dart
```

**`run_prod.ps1`:**

```powershell
flutter run --flavor prod -t lib/main_prod.dart
```

**`build_android_release.ps1`:**

```powershell
param([ValidateSet('dev','prod')][string]$Flavor = 'prod')
flutter build appbundle --flavor $Flavor -t lib/main_$Flavor.dart
```

### Update package.json Scripts (if using)

```json
{
  "scripts": {
    "dev": "flutter run --flavor dev -t lib/main_dev.dart",
    "prod": "flutter run --flavor prod -t lib/main_prod.dart",
    "build:dev": "flutter build appbundle --flavor dev -t lib/main_dev.dart",
    "build:prod": "flutter build appbundle --flavor prod -t lib/main_prod.dart"
  }
}
```

## Migration from Current Setup

### Migration Steps

1. **Backup current setup**

   ```powershell
   git checkout -b backup-before-flavors
   git push origin backup-before-flavors
   ```

2. **Create flavor directories** (Step 1.4 above)

3. **Update Android build.gradle.kts** (Step 1.2 above)

4. **Generate Firebase options for each flavor** (Step 3.4 above)

5. **Create flavor entry points** (Step 3.2 above)

6. **Update main.dart** (Step 3.3 above)

7. **Test each flavor**

   ```bash
   flutter clean
   flutter pub get
   flutter run --flavor dev -t lib/main_dev.dart
   flutter run --flavor prod -t lib/main_prod.dart
   ```

8. **Update documentation**

### What Changes in Your Code

**Before:**

```dart
import 'package:budget_pillars/config/environment.dart';

if (Environment.currentEnvironment == Environment.development) {
  // dev code
}
```

**After:**

```dart
import 'package:budget_pillars/config/flavor_config.dart';

if (FlavorConfig.isDevelopment) {
  // dev code
}
```

### Files to Update

Search and replace in these files:

- Any file using `Environment.currentEnvironment`
- Any file checking `Environment.development` or `Environment.production`
- Replace with `FlavorConfig.isDevelopment` / `FlavorConfig.isProduction`

## Benefits Summary

| Feature                | Current (Manual)  | With Flavors                   |
| ---------------------- | ----------------- | ------------------------------ |
| **Change environment** | Edit code file    | Change run command             |
| **Wrong config risk**  | High              | Impossible                     |
| **Firebase config**    | Manual copy/paste | Automatic                      |
| **Multiple installs**  | No (same app ID)  | Yes (different app IDs)        |
| **CI/CD complexity**   | Medium            | Low                            |
| **App name per env**   | Same              | Different (Budget Pillars DEV) |
| **Setup complexity**   | Low               | Medium (one-time)              |
| **Daily workflow**     | Manual steps      | Just run command               |

## Maintenance

### Adding a New Flavor (e.g., staging)

1. Add to `android/app/build.gradle.kts`:

```kotlin
create("staging") {
    dimension = "environment"
    applicationIdSuffix = ".staging"
    versionNameSuffix = "-staging"
    resValue("string", "app_name", "Budget Pillars STAGING")
}
```

2. Create `lib/main_staging.dart`

3. Add flavor to `FlavorConfig` enum

4. Create Firebase configs in flavor directories

## Troubleshooting

**Issue: "No Firebase App has been created"**

- Ensure firebase_options_dev.dart and firebase_options_prod.dart exist
- Run `flutterfire configure` for each project

**Issue: "Flavor not found"**

- Check spelling of --flavor argument
- Ensure flavor is defined in build.gradle.kts

**Issue: Wrong Firebase project**

- Check which main\_\*.dart is being run
- Verify firebase_options file is correct

## Cost/Benefit Analysis

### Costs

- 2-3 hours initial setup
- Learning curve for team
- More complex project structure
- iOS requires Xcode knowledge

### Benefits

- Eliminates manual config swapping
- Prevents production deployment mistakes
- Professional development workflow
- Can run dev and prod on same device
- CI/CD becomes much simpler
- Required for proper multi-environment setup

## Recommendation

**Should you implement flavors?**

✅ **Yes, if:**

- You want to prevent production accidents
- You plan to have staging environment
- You want professional workflow
- You're deploying to production regularly
- You have CI/CD pipeline

⚠️ **Maybe not, if:**

- Solo project, rarely switching environments
- Only deploying to production once
- Very tight deadline

**For your project:** I'd recommend **YES** because:

1. You have both dev and prod Firebase projects
2. You're deploying to production
3. Manual config swapping is error-prone
4. Setup time (2-3 hours) pays off quickly
5. Makes repository more professional

## Next Steps

If you want to proceed:

1. I can help implement this step-by-step
2. We'll start with Android (easiest to test)
3. Then add iOS/macOS support
4. Finally web configuration
5. Test thoroughly before removing old system

Would you like me to start with Step 1 (Android flavor setup)?
