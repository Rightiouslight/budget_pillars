# API Key Restriction Quick Reference

## Your Project Details

**Project ID**: `pocketflow-tw4kf`  
**Project Name**: BudgetPillars  
**Package Name**: `budgetpillars.lojinnovation.com`

## Web API Key Restrictions

### Application Restrictions

**Type**: HTTP referrers (web sites)

**Allowed referrers**:

```
https://pocketflow-tw4kf.web.app/*
https://pocketflow-tw4kf.firebaseapp.com/*
http://localhost:*
http://127.0.0.1:*
```

### API Restrictions

**Type**: Restrict key

**Allowed APIs**:

- Identity Toolkit API
- Cloud Firestore API
- Firebase Authentication API (Firebase Auth)
- Firebase Installations API
- Token Service API

## Android API Key Restrictions

### Application Restrictions

**Type**: Android apps

**App details**:

- **Package name**: `budgetpillars.lojinnovation.com`
- **SHA-1 certificate fingerprint**: `B5:CF:06:B9:11:97:BA:39:0A:78:32:2E:12:05:40:A0:66:D7:43:10`

> **Note**: This is your debug keystore SHA-1. When you create a release keystore for production, you'll need to add that SHA-1 as well.

### API Restrictions

**Type**: Restrict key

**Allowed APIs**:

- Identity Toolkit API
- Cloud Firestore API
- Firebase Authentication API (Firebase Auth)
- Firebase Installations API
- Token Service API

## How to Apply Restrictions

### In Google Cloud Console:

1. Go to: https://console.cloud.google.com/apis/credentials?project=pocketflow-tw4kf
2. Click on the API key you want to restrict
3. Under "Application restrictions":
   - For Web: Select "HTTP referrers" and add the URLs above
   - For Android: Select "Android apps", add package name and SHA-1
4. Under "API restrictions":
   - Select "Restrict key"
   - Click "Select APIs" and enable only the APIs listed above
5. Click "Save"

### In Firebase Console (Alternative):

1. Go to: https://console.firebase.google.com/project/pocketflow-tw4kf/settings/general
2. Select your Web or Android app
3. For Android: Add the SHA-1 fingerprint in the app settings

## Verification

After adding restrictions, test that:

✅ **Should work**:

- Your web app at pocketflow-tw4kf.web.app
- Your web app at pocketflow-tw4kf.firebaseapp.com
- Your Android app with the correct package name
- Local development (localhost)

❌ **Should fail**:

- Any other domain trying to use your web API key
- Any other Android app trying to use your Android API key
- APIs not in the allowed list

## Testing Restrictions

### Test Web Restrictions:

1. Open your web app: https://pocketflow-tw4kf.web.app
2. Try to sign in - should work ✅
3. Try accessing from an unauthorized domain - should fail ❌

### Test Android Restrictions:

1. Install your APK on a device
2. Try to sign in - should work ✅
3. Try using the same API key from a different package - should fail ❌

## Common Issues

### "API key not valid" error

- Check that you've added the correct domain/package name
- Make sure you clicked "Save" after adding restrictions
- Wait a few minutes for changes to propagate

### "This app is not authorized" error

- For web: Check the referrer is in your allowed list
- For Android: Check package name matches exactly
- For Android: Verify SHA-1 fingerprint is correct

### Web app works locally but not in production

- Make sure you added your production domains to allowed referrers
- Check that domain includes `/*` at the end

## When to Update Restrictions

You'll need to update restrictions when:

- Adding a new domain for your web app
- Creating a release keystore (add production SHA-1)
- Moving to a different hosting provider
- Adding support for additional platforms

## Additional Security

Beyond API key restrictions, ensure you have:

- ✅ Firebase Security Rules for Firestore
- ✅ Firebase Security Rules for Storage (if used)
- ✅ Firebase App Check (advanced - prevents abuse)
- ✅ Regular security audits

## Quick Commands Reference

### Get SHA-1 from debug keystore:

```powershell
keytool -list -v -keystore $env:USERPROFILE\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Get SHA-1 from release keystore (when created):

```powershell
keytool -list -v -keystore android\upload-keystore.jks -alias upload
```

### Check current API key restrictions:

Go to: https://console.cloud.google.com/apis/credentials?project=pocketflow-tw4kf

---

**Last Updated**: December 9, 2025  
**Status**: Ready to apply restrictions after key regeneration
