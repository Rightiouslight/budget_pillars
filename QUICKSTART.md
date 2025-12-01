# Quick Start Guide - Budget Pillars Flutter

## Prerequisites Checklist

Before running the app, ensure you have:

- [ ] Flutter SDK installed (3.9.2 or higher)
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
- [ ] A Firebase project created at https://console.firebase.google.com

## Initial Setup (One-Time)

### 1. Configure Firebase

```bash
# Make sure you're in the project directory
cd d:\Development\Flutter\budget_pillars

# Configure Firebase for your project
flutterfire configure
```

Follow the prompts to:

- Select your Firebase project
- Choose platforms (iOS, Android, Web, etc.)

This will generate the correct `lib/data/firebase/firebase_options.dart` file.

### 2. Enable Firebase Services

In your Firebase Console:

1. **Authentication**

   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Enable "Google"

2. **Firestore Database**

   - Go to Firestore Database
   - Create database (start in test mode)
   - Update security rules (see PHASE1_SETUP.md)

3. **Google Sign-In (Android Only)**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   - Copy the SHA-1 fingerprint
   - Add it in Firebase Console → Project Settings → Your Apps

### 3. Install Dependencies

```bash
flutter pub get
```

## Running the App

### Development

```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

### Common Devices

```bash
flutter run -d chrome       # Chrome browser
flutter run -d windows      # Windows desktop
flutter run -d macos        # macOS desktop
```

## Development Workflow

### Making Model Changes

If you modify any model with `@freezed`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Clean Build

If you encounter issues:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Analyzing Code

```bash
flutter analyze
```

## Project Status

### ✅ Phase 1: Complete

- Firebase integration
- Authentication (Email & Google)
- Data models
- App structure & routing

### 🚧 Phase 2: Next

- Dashboard implementation
- Budget display (read-only)
- Month navigation

## Troubleshooting

### "Firebase not configured" Error

Make sure you ran `flutterfire configure` and the `firebase_options.dart` file was generated.

### Google Sign-In Not Working

1. Verify SHA-1 is added in Firebase Console
2. Make sure Google Sign-In is enabled in Authentication
3. Check that you're using the correct Firebase project

### Build Runner Errors

```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

## Useful Commands

```bash
# Check Flutter doctor
flutter doctor

# Update dependencies
flutter pub upgrade

# Format code
dart format lib/

# Run tests
flutter test
```

## Resources

- [Requirements Document](requirements.md)
- [Phase 1 Setup Details](PHASE1_SETUP.md)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)

---

**Ready to start?** Run `flutterfire configure` and then `flutter run`!
