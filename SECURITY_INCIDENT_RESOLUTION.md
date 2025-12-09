# Security Incident Resolution - Exposed Firebase API Keys

## Incident Summary

**Date**: December 9, 2025  
**Severity**: HIGH  
**Issue**: Firebase API keys publicly exposed in GitHub repository  
**Affected Project**: BudgetPillars (pocketflow-tw4kf)  
**Exposed Key**: `AIzaSyB2vISec3_1i_D2KBrqFKGakfUBAersoFA` (Web)  
**Exposure Point**: https://github.com/Rightiouslight/budget_pillars/blob/aef071b9a319e333543e9d5f89eca61435cba7fc/lib/config/firebase_options_prod.dart

## Immediate Actions Required

### 1. Regenerate Compromised API Keys (DO THIS FIRST)

1. **Go to Google Cloud Console**:

   - Visit: https://console.cloud.google.com/
   - Select project: `pocketflow-tw4kf` (BudgetPillars)

2. **Navigate to Credentials**:

   - Go to: APIs & Services → Credentials
   - Or search for "Credentials" in the search bar

3. **Regenerate the Web API Key**:

   - Find the API key: `AIzaSyB2vISec3_1i_D2KBrqFKGakfUBAersoFA`
   - Click on the key name to edit
   - Click **"Regenerate Key"** button
   - Save the new key securely (you'll need it shortly)

4. **Also Check Android API Key**:
   - The Android key `AIzaSyDgU4fkN8RExycQhsR5MbZIDNgcHdWDQ1Y` is also in the repo
   - Regenerate this one too for safety

### 2. Add API Key Restrictions

After regenerating, restrict each key:

#### Web API Key Restrictions:

1. Click on the regenerated web API key
2. Under "Application restrictions":
   - Select **"HTTP referrers (web sites)"**
   - Add these referrers:
     ```
     https://pocketflow-tw4kf.web.app/*
     https://pocketflow-tw4kf.firebaseapp.com/*
     http://localhost:*
     http://127.0.0.1:*
     ```
3. Under "API restrictions":
   - Select **"Restrict key"**
   - Enable only these APIs:
     - Identity Toolkit API
     - Cloud Firestore API
     - Firebase Authentication API
     - Firebase Hosting API
4. Click **Save**

#### Android API Key Restrictions:

1. Click on the regenerated Android API key
2. Under "Application restrictions":
   - Select **"Android apps"**
   - Add package name: `budgetpillars.lojinnovation.com`
   - Add SHA-1 fingerprint from your keystore:
     ```powershell
     keytool -list -v -keystore android/upload-keystore.jks -alias upload
     ```
3. Under "API restrictions":
   - Select **"Restrict key"**
   - Enable only these APIs:
     - Identity Toolkit API
     - Cloud Firestore API
     - Firebase Authentication API
4. Click **Save**

### 3. Monitor Project Activity

1. **Check Billing & Usage**:

   - Go to: Billing → Reports
   - Review usage for the past 7 days
   - Look for unusual spikes in API calls

2. **Check Authentication**:

   - Go to Firebase Console → Authentication
   - Review recent users
   - Check for unauthorized sign-ups

3. **Check Firestore**:

   - Go to Firebase Console → Firestore Database
   - Review recent writes/reads
   - Look for unusual data access patterns

4. **Review Cloud Logging**:
   - Go to: Logging → Logs Explorer
   - Filter by the past 7 days
   - Search for unusual activity

## Update Your Local Configuration

### Step 1: Get New Keys from Firebase

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select project: `pocketflow-tw4kf`
3. Go to Project Settings (gear icon) → General
4. Scroll down to "Your apps"
5. For Web app, copy the new config
6. For Android app, download new `google-services.json`

### Step 2: Update Local Files

Create `lib/config/firebase_options_prod.dart` with new keys:

```dart
// IMPORTANT: Never commit this file to git
// It's already in .gitignore
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ProductionFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'ProductionFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_NEW_WEB_API_KEY_HERE',
    appId: '1:1065513142302:web:773525822d7436e856860f',
    messagingSenderId: '1065513142302',
    projectId: 'pocketflow-tw4kf',
    authDomain: 'pocketflow-tw4kf.firebaseapp.com',
    storageBucket: 'pocketflow-tw4kf.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_NEW_ANDROID_API_KEY_HERE',
    appId: '1:1065513142302:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '1065513142302',
    projectId: 'pocketflow-tw4kf',
  );
}
```

### Step 3: Update Android google-services.json

Replace `android/app/google-services.json` with the new file downloaded from Firebase Console.

## Redeploy Applications

After updating configurations:

```powershell
# Test locally first
flutter run -t lib/main_prod.dart

# Deploy web app
.\deploy-web.ps1

# Build and deploy Android
.\deploy-android.ps1 -Version "1.0.1-hotfix.1" -ReleaseNotes "Security update: Regenerated API keys"
```

## Remove Sensitive Data from Git History

**WARNING**: This is complex and will rewrite git history. Only do this if you understand the implications.

### Option 1: Use BFG Repo-Cleaner (Recommended)

```powershell
# Install BFG (requires Java)
# Download from: https://rtyley.github.io/bfg-repo-cleaner/

# Clone a fresh copy
git clone --mirror https://github.com/Rightiouslight/budget_pillars.git

# Remove the file from history
java -jar bfg.jar --delete-files firebase_options_prod.dart budget_pillars.git

# Clean up
cd budget_pillars.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (DANGEROUS - coordinate with team)
git push --force
```

### Option 2: Accept the Risk

Since you've already:

1. Regenerated the API keys (old ones are now invalid)
2. Added restrictions (new keys are protected)
3. The file is already in `.gitignore` (won't be committed again)

You can accept that the old (now invalid) keys are in history and move forward.

## Prevention Measures

### ✅ Already Implemented:

- Firebase config files in `.gitignore`
- Backup system for sensitive files
- Template files for developers

### 🔧 Additional Measures:

1. **Pre-commit Hooks**:

   ```powershell
   # Create .git/hooks/pre-commit
   # Add checks for API keys before allowing commits
   ```

2. **Environment Variables** (Future consideration):

   - Use `--dart-define` for API keys
   - Never hardcode secrets
   - Use Flutter's environment configuration

3. **Secret Scanning**:

   - Enable GitHub secret scanning (Settings → Security)
   - Use `git-secrets` tool locally

4. **Regular Audits**:
   - Monthly review of committed files
   - Check `.gitignore` is working correctly
   - Verify no secrets in repository

## Verification Checklist

- [ ] Web API key regenerated in Google Cloud Console
- [ ] Android API key regenerated in Google Cloud Console
- [ ] API restrictions added (HTTP referrers for web)
- [ ] API restrictions added (Android package for mobile)
- [ ] Billing/usage reviewed for unusual activity
- [ ] Authentication logs checked for unauthorized users
- [ ] Firestore data reviewed for tampering
- [ ] Local `firebase_options_prod.dart` updated with new keys
- [ ] Local `google-services.json` updated
- [ ] Web app redeployed with new keys
- [ ] Android app rebuilt and released with new keys
- [ ] New keys tested in production
- [ ] Old keys confirmed to be deactivated

## Support Resources

- **Google Cloud Support**: https://cloud.google.com/support
- **Firebase Security Best Practices**: https://firebase.google.com/docs/projects/api-keys
- **API Key Restrictions Guide**: https://cloud.google.com/docs/authentication/api-keys#adding_restrictions

## Post-Incident Review

After completing remediation:

1. **Document Timeline**:

   - When keys were exposed
   - When notification received
   - When keys were regenerated
   - When restrictions were added

2. **Lessons Learned**:

   - What went wrong
   - What worked well
   - What to improve

3. **Update Processes**:
   - Improve developer onboarding
   - Add security training
   - Implement automated scanning

---

**Last Updated**: December 9, 2025  
**Next Review**: After incident resolution
