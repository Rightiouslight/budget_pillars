# Budget Pillars

A Flutter-based budget management application with support for multiple environments using flavors.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Setup](#project-setup)
- [Flutter Flavors](#flutter-flavors)
- [Running the App](#running-the-app)
- [Building for Release](#building-for-release)
- [Development Workflow](#development-workflow)
- [Firebase Configuration](#firebase-configuration)
- [Project Structure](#project-structure)

## Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase CLI (for Firebase configuration)
- Git

## Project Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd budget_pillars
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Clean build cache (if needed)**
   ```bash
   flutter clean
   ```

## Flutter Flavors

This project uses Flutter flavors to support multiple environments (dev and prod) without manual configuration switching.

### Available Flavors

| Flavor   | Firebase Project | Package Name                       | App Name           | Logging  | Purpose                 |
| -------- | ---------------- | ---------------------------------- | ------------------ | -------- | ----------------------- |
| **dev**  | budgetpillarsdev | budgetpillars.lojinnovation.com.dev | Budget Pillars DEV | Enabled  | Development and testing |
| **prod** | pocketflow-tw4kf | budgetpillars.lojinnovation.com    | Budget Pillars     | Disabled | Production releases     |

### Benefits of Flavors

- ✅ Automatic environment selection via command line
- ✅ No manual Firebase config file swapping
- ✅ Different app names to distinguish environments
- ✅ **Different package names - install both dev and prod on the same device simultaneously**
- ✅ CI/CD friendly
- ✅ Prevents accidental production deployments

## Running the App

### Using Command Line

**Development Environment:**

```powershell
flutter run --flavor dev -t lib/main_dev.dart
```

**Production Environment:**

```powershell
flutter run --flavor prod -t lib/main_prod.dart
```

**Web (Development):**

```powershell
flutter run -d chrome -t lib/main_dev.dart
```

**Web (Production):**

```powershell
flutter run -d chrome -t lib/main_prod.dart
```

### Using VS Code

This project includes pre-configured launch configurations in `.vscode/launch.json`.

1. Open the Run and Debug panel (Ctrl+Shift+D)
2. Select from the dropdown:
   - **Development (dev)** - Run dev flavor on mobile
   - **Production (prod)** - Run prod flavor on mobile
   - **Development (Web)** - Run dev flavor on Chrome
   - **Production (Web)** - Run prod flavor on Chrome
3. Press F5 or click the play button

### Quick Start Scripts

**Windows PowerShell:**

```powershell
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

## Building for Release

### Android

**Development APK:**

```powershell
flutter build apk --flavor dev -t lib/main_dev.dart
```

**Production APK:**

```powershell
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

**Production App Bundle (for Google Play):**

```powershell
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

**Output locations:**

- APK: `build/app/outputs/flutter-apk/app-<flavor>-release.apk`
- Bundle: `build/app/outputs/bundle/<flavor>Release/app-<flavor>-release.aab`

### iOS

```bash
flutter build ios --flavor prod -t lib/main_prod.dart --release
```

### Web

```powershell
flutter build web -t lib/main_dev.dart   # Development
flutter build web -t lib/main_prod.dart  # Production
```

## Development Workflow

### Switching Between Environments

With flavors, you **never** need to manually edit configuration files. Just use the appropriate run command:

```powershell
# Work on development
flutter run --flavor dev -t lib/main_dev.dart

# Test production build
flutter run --flavor prod -t lib/main_prod.dart --release
```

### Testing Both Environments

You can install both dev and prod builds on the same device simultaneously since they use the same package name but connect to different Firebase projects.

### Debugging

1. **Development environment** has logging enabled by default
2. Check Firebase project in console output:
   ```
   🚀 Starting Budget Pillars DEV
   📦 Environment: DEV
   🔥 Firebase Project: budgetpillarsdev
   ```

## Firebase Configuration

### Firebase Projects

- **Development:** `budgetpillarsdev`
- **Production:** `pocketflow-tw4kf`

### Configuration Files

Firebase configuration is managed per flavor:

```
android/app/src/
├── dev/
│   └── google-services.json          # Dev Firebase config
└── prod/
    └── google-services.json          # Prod Firebase config

lib/
├── firebase_options_dev.dart         # Dev Firebase options
└── firebase_options_prod.dart        # Prod Firebase options
```

### Regenerating Firebase Configuration

If you need to update Firebase settings:

```bash
# Development
flutterfire configure --project=budgetpillarsdev --out=lib/firebase_options_dev.dart --platforms=android,web

# Production
flutterfire configure --project=pocketflow-tw4kf --out=lib/firebase_options_prod.dart --platforms=android,web
```

## Project Structure

```
lib/
├── main.dart                    # Main entry point (shared logic)
├── main_dev.dart               # Development flavor entry point
├── main_prod.dart              # Production flavor entry point
├── app/
│   ├── app.dart                # Main app widget
│   └── app_router.dart         # Navigation configuration
├── config/
│   └── flavor_config.dart      # Flavor configuration
├── features/                   # Feature modules
├── data/                       # Data layer
├── providers/                  # Riverpod providers
└── utils/                      # Utility functions

android/app/src/
├── dev/                        # Dev flavor resources
├── prod/                       # Prod flavor resources
└── main/                       # Shared Android code
```

## Environment Configuration

The flavor configuration is defined in `lib/config/flavor_config.dart`:

```dart
FlavorConfig(
  flavor: Flavor.dev,
  name: 'DEV',
  displayName: 'Budget Pillars DEV',
  values: FlavorValues(
    firebaseProjectId: 'budgetpillarsdev',
    enableLogging: true,
    useFirebaseEmulator: false,  // Set to true for local emulator
  ),
);
```

### Using Flavor Config in Code

```dart
import 'package:budget_pillars/config/flavor_config.dart';

// Check current flavor
if (FlavorConfig.isDevelopment) {
  // Development-specific code
}

if (FlavorConfig.isProduction) {
  // Production-specific code
}

// Access configuration
final projectId = FlavorConfig.instance.values.firebaseProjectId;
final appName = FlavorConfig.instance.displayName;
```

## Common Tasks

### Clean Build

If you encounter build issues, clean the project:

```powershell
flutter clean
flutter pub get
```

### Update Dependencies

```powershell
flutter pub get
flutter pub upgrade
```

### Run Tests

```powershell
flutter test
```

### Run Integration Tests

```powershell
flutter test integration_test/
```

### Check for Issues

```powershell
flutter analyze
flutter doctor
```

## Troubleshooting

### "No matching client found for package name"

This means the Firebase configuration doesn't match the package name. Ensure:

- Correct `google-services.json` in the flavor directory
- Package name matches: `budgetpillars.lojinnovation.com`

### Build Fails After Switching Flavors

Run:

```powershell
flutter clean
flutter pub get
```

### Firebase Not Connecting

1. Check you're using the correct flavor command
2. Verify Firebase project ID in console output
3. Ensure Firebase configuration files are present in flavor directories

### VS Code Launch Config Not Working

1. Ensure `.vscode/launch.json` exists
2. Reload VS Code window (Ctrl+Shift+P → "Reload Window")
3. Select the correct launch configuration from dropdown

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Flutter Flavors Guide](https://docs.flutter.dev/deployment/flavors)
- [Riverpod Documentation](https://riverpod.dev/)

## Support

For issues or questions:

1. Check existing documentation in the `/docs` folder
2. Review the troubleshooting section above
3. Check console output for specific error messages
4. Ensure you're using the correct flavor command

---

**Remember:** Always use `--flavor <env> -t lib/main_<env>.dart` when running or building the app!
