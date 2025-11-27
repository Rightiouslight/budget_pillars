# Environment Configuration Guide

This app supports switching between development and production Firebase environments.

## Quick Start

To switch environments, edit `lib/config/environment.dart`:

```dart
static const Environment current = Environment.development; // or Environment.production
```

## Environment Options

### Development
- Uses `budgetpillarsdev` Firebase project
- App title shows "(Dev)"
- Debug logging enabled
- Can use Firebase emulator

### Production
- Uses `budgetpillars` Firebase project
- Standard app title
- Debug logging disabled
- Production Firebase backend

## Setup Instructions

### 1. Configure Development (Already Done)
Your development Firebase options are in `lib/firebase_options.dart`

### 2. Configure Production
Run the FlutterFire CLI to generate production config:

```bash
flutterfire configure --project=budgetpillars --out=lib/config/firebase_options_prod.dart
```

Then update the class name in that file from `DefaultFirebaseOptions` to `ProductionFirebaseOptions`

Alternatively, manually copy your production Firebase config into `lib/config/firebase_options_prod.dart`

### 3. Using Firebase Emulator (Optional)
For local development with Firebase emulator:

1. Start the Firebase emulator suite:
   ```bash
   firebase emulators:start
   ```

2. In `lib/config/environment.dart`, set:
   ```dart
   static bool get useFirebaseEmulator => true;
   ```

3. Adjust host/port if needed:
   ```dart
   static String get firestoreEmulatorHost => 'localhost';
   static int get firestoreEmulatorPort => 8080;
   ```

## Configuration Options

### `lib/config/environment.dart`

- `current` - Set to `Environment.development` or `Environment.production`
- `useFirebaseEmulator` - Enable local Firebase emulator (dev only)
- `enableDebugLogging` - Show startup logs (auto-enabled in dev)
- `firestoreEmulatorHost` - Emulator host address
- `firestoreEmulatorPort` - Emulator port number

## Environment Indicators

When running the app:
- **Development**: Title shows "Budget Pillars (Dev)"
- **Production**: Title shows "Budget Pillars"
- Console logs show:
  - 🚀 App name
  - 📦 Environment (development/production)
  - 🔥 Firebase project ID
  - 🔧 Emulator status (if enabled)

## Best Practices

1. **Never commit production secrets** to version control
2. **Always test in development** before switching to production
3. **Use emulator for local testing** to avoid consuming Firebase quotas
4. **Review environment** before releasing builds

## Switching Checklist

Before switching to production:
- [ ] Production Firebase config is populated in `firebase_options_prod.dart`
- [ ] `Environment.current` is set to `Environment.production`
- [ ] `useFirebaseEmulator` is set to `false`
- [ ] App has been tested in dev environment
- [ ] Firestore security rules are properly configured in production

## Troubleshooting

**Error: Firebase options not configured**
- Make sure you've run `flutterfire configure` for the production project
- Check that `ProductionFirebaseOptions` class exists in `firebase_options_prod.dart`

**Error: Can't connect to Firestore**
- Verify the environment is set correctly
- Check Firebase project ID matches your console
- Ensure emulator is running if `useFirebaseEmulator` is true

**Data appearing in wrong environment**
- Double-check `EnvironmentConfig.current` in `environment.dart`
- Restart the app after changing environment
- Check console logs confirm correct Firebase project
