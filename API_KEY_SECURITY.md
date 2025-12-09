# API Key Security Guide

## Overview

This guide explains how to securely manage Firebase API keys and prevent accidental exposure.

## What are API Keys?

Firebase API keys are used to identify your Firebase project when making API calls. While they're not meant to be secret (they're embedded in apps), they should still be protected with restrictions to prevent abuse.

## Security Best Practices

### 1. Always Add Restrictions

Every API key should have restrictions:

#### Web API Keys:

- **HTTP referrer restrictions**: Only allow your domains
  ```
  https://yourdomain.web.app/*
  https://yourdomain.firebaseapp.com/*
  http://localhost:* (for development)
  ```
- **API restrictions**: Only enable required APIs
  - Identity Toolkit API
  - Cloud Firestore API
  - Firebase Authentication API

#### Android API Keys:

- **Android app restrictions**:
  - Package name: `budgetpillars.lojinnovation.com`
  - SHA-1 fingerprint from your keystore
- **API restrictions**: Only enable required APIs

### 2. Never Commit Real Keys to Git

Files that contain API keys should be in `.gitignore`:

```gitignore
# Firebase configuration files with actual keys
lib/config/firebase_options_*.dart
!lib/config/firebase_options_*.dart.template

android/app/google-services*.json
!android/app/google-services*.json.template
```

### 3. Use Template Files

Commit `.template` files that show structure without real keys:

- `firebase_options_prod.dart.template`
- `google-services.json.template`

### 4. Set Up Pre-commit Hooks

Create `.git/hooks/pre-commit`:

```bash
#!/bin/sh
# Check for accidentally committed API keys

if git diff --cached --name-only | grep -E "firebase_options_(dev|prod)\.dart$"; then
    echo "ERROR: Attempting to commit Firebase options file!"
    echo "Please use the .template file instead."
    exit 1
fi

if git diff --cached --name-only | grep "google-services\.json$"; then
    echo "ERROR: Attempting to commit google-services.json!"
    echo "Please use the .template file instead."
    exit 1
fi
```

### 5. Use Environment Variables (Advanced)

For even better security, use environment variables:

```dart
// Instead of hardcoding keys
const apiKey = String.fromEnvironment('FIREBASE_API_KEY');

// Build with:
// flutter build web --dart-define=FIREBASE_API_KEY=your_key_here
```

## What to Do If Keys Are Exposed

### Immediate Actions:

1. **Regenerate the exposed keys** in Google Cloud Console
2. **Add restrictions** to the new keys
3. **Check billing/usage** for unusual activity
4. **Review authentication logs** for unauthorized access
5. **Update applications** with new keys
6. **Redeploy** all affected apps

### Detailed Steps:

See `SECURITY_INCIDENT_RESOLUTION.md` for complete incident response guide.

## Firebase API Key Facts

### What They Are:

- **Public identifiers** for your Firebase project
- Included in your app bundles (web, Android, iOS)
- Used by Firebase SDKs to connect to your project

### What They Are NOT:

- **NOT secrets** in the traditional sense
- **NOT sufficient** for authentication alone
- **NOT meant** to be hidden from users

### The Real Security:

Firebase security comes from:

1. **API key restrictions** (domain/package restrictions)
2. **Firebase Security Rules** (Firestore, Storage, etc.)
3. **Firebase Authentication** (user verification)
4. **App Check** (prevents abuse from unauthorized apps)

## Monitoring & Alerts

### Set Up Budget Alerts:

1. Go to Google Cloud Console → Billing
2. Set up budget alerts for unusual usage
3. Get notified before costs spiral

### Enable Cloud Monitoring:

1. Go to Google Cloud Console → Monitoring
2. Set up alerts for API usage spikes
3. Monitor authentication patterns

### Regular Audits:

- Monthly review of API key restrictions
- Quarterly security assessment
- Annual penetration testing (for production apps)

## Resources

- [Firebase API Key Best Practices](https://firebase.google.com/docs/projects/api-keys)
- [Google Cloud API Key Restrictions](https://cloud.google.com/docs/authentication/api-keys)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

## Quick Reference

### Get SHA-1 Fingerprint:

```powershell
# For your release keystore
keytool -list -v -keystore android/upload-keystore.jks -alias upload

# For debug (development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
```

### Check Current Restrictions:

1. Go to: https://console.cloud.google.com/
2. APIs & Services → Credentials
3. Click on each API key to view restrictions

### Test Restrictions:

Try accessing your Firebase project from:

- An unauthorized domain (should fail)
- An unauthorized app (should fail)
- A valid domain/app (should succeed)

---

**Remember**: The best security is layered security. API key restrictions are just one layer - always use Firebase Security Rules and Authentication as well.
