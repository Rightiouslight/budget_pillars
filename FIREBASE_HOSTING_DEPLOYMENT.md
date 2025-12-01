# Firebase Hosting Deployment Guide

This guide will walk you through deploying your Flutter web app to Firebase Hosting.

## Prerequisites

- [x] Firebase project set up (budgetpillarsdev)
- [x] Flutter web app working locally
- [ ] Firebase CLI installed
- [ ] Firebase Hosting initialized

## Step 1: Install Firebase CLI

If you haven't installed Firebase CLI yet:

```powershell
npm install -g firebase-tools
```

Verify installation:

```powershell
firebase --version
```

## Step 2: Login to Firebase

```powershell
firebase login
```

This will open a browser window for you to authenticate with your Google account.

## Step 3: Initialize Firebase Hosting

In your project directory:

```powershell
cd D:\Development\Flutter\budget_pillars
firebase init hosting
```

When prompted:

1. **"What do you want to use as your public directory?"**

   - Answer: `build/web`

2. **"Configure as a single-page app (rewrite all urls to /index.html)?"**

   - Answer: `Yes` (y)

3. **"Set up automatic builds and deploys with GitHub?"**

   - Answer: `No` (n) - unless you want CI/CD

4. **"File build/web/index.html already exists. Overwrite?"**
   - Answer: `No` (n)

This will create:

- `.firebaserc` - Project configuration
- `firebase.json` - Hosting configuration (will update existing file)

## Step 4: Update firebase.json

After initialization, update your `firebase.json` to include both Flutter and hosting configurations:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css|woff|woff2|ttf|eot|svg|png|jpg|jpeg|gif|webp|ico)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  },
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "pocketflow-tw4kf",
          "appId": "1:1065513142302:android:9a98b4fa2e44ef3956860f",
          "fileOutput": "android/app/google-services.json"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "budgetpillarsdev",
          "configurations": {
            "android": "1:487033381743:android:084b0794211a73c456fe9a",
            "ios": "1:487033381743:ios:3ee7f4e77d252de756fe9a",
            "macos": "1:487033381743:ios:3ee7f4e77d252de756fe9a",
            "web": "1:487033381743:web:715a4f67cc76c77f56fe9a",
            "windows": "1:487033381743:web:94227b0359ae47fc56fe9a"
          }
        },
        "lib/config/firebase_options_prod.dart": {
          "projectId": "pocketflow-tw4kf",
          "configurations": {
            "android": "1:1065513142302:android:9a98b4fa2e44ef3956860f",
            "web": "1:1065513142302:web:773525822d7436e856860f",
            "windows": "1:1065513142302:web:b25b49732d7fda0756860f"
          }
        }
      }
    }
  }
}
```

## Step 5: Build Flutter Web App for Production

Build your Flutter web app in release mode:

```powershell
flutter build web --release
```

This creates optimized files in `build/web/`.

**Optional: Build with custom base href if deploying to a subdirectory:**

```powershell
flutter build web --release --base-href /
```

## Step 6: Test Locally (Optional)

Before deploying, test the hosting locally:

```powershell
firebase serve --only hosting
```

This will serve your app at `http://localhost:5000`. Test thoroughly!

## Step 7: Deploy to Firebase Hosting

Deploy your app:

```powershell
firebase deploy --only hosting
```

This will:

1. Upload your `build/web` files to Firebase Hosting
2. Provide you with a hosting URL (e.g., `https://budgetpillarsdev.web.app`)

## Step 8: Verify Deployment

After deployment, Firebase will show:

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/budgetpillarsdev/overview
Hosting URL: https://budgetpillarsdev.web.app
```

Visit the Hosting URL to verify your app is live!

---

## Common Issues & Solutions

### Issue: "Authorization failed"

**Solution:**

```powershell
firebase logout
firebase login
```

### Issue: Build files not found

**Solution:** Make sure you ran `flutter build web --release` first

### Issue: App shows blank screen

**Solutions:**

1. Check browser console for errors
2. Verify Firebase configuration in `web/index.html`
3. Check that all Firebase SDKs are initialized correctly
4. Ensure CORS is configured properly for Firestore

### Issue: "Firebase project not found"

**Solution:**

```powershell
firebase use --add
```

Then select `budgetpillarsdev` from the list.

### Issue: Routing doesn't work (404 on refresh)

**Solution:** Ensure `firebase.json` has the rewrite rule for single-page apps (Step 4)

---

## Update Web Configuration (Important!)

Before deploying, make sure your `web/index.html` has the correct Firebase configuration:

### Update Google Sign-In Client ID (if needed)

In `web/index.html`, update the meta tag:

```html
<meta
  name="google-signin-client_id"
  content="487033381743-YOUR_ACTUAL_WEB_CLIENT_ID.apps.googleusercontent.com"
/>
```

Get this from:

- Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration

---

## Custom Domain (Optional)

To use a custom domain (e.g., `budgetpillars.app`):

1. Go to Firebase Console: https://console.firebase.google.com/project/budgetpillarsdev/hosting
2. Click "Add custom domain"
3. Follow the DNS configuration steps
4. Update DNS records with your domain provider
5. Wait for SSL certificate provisioning (can take 24-48 hours)

---

## Continuous Deployment

### Quick Redeploy Command

After making changes:

```powershell
flutter build web --release; firebase deploy --only hosting
```

### Preview Before Deploy

```powershell
flutter build web --release
firebase hosting:channel:deploy preview
```

This creates a temporary preview URL for testing.

---

## Deployment Checklist

Before deploying to production:

- [ ] Remove test/debug code
- [ ] Update version number in `pubspec.yaml`
- [ ] Test thoroughly in release mode locally
- [ ] Verify Firebase config (Firestore, Auth, etc.)
- [ ] Check Google Sign-In is configured (or removed)
- [ ] Test on multiple browsers (Chrome, Firefox, Safari)
- [ ] Test responsive design (mobile, tablet, desktop)
- [ ] Review Firebase Console for any errors
- [ ] Set up Firebase security rules for production
- [ ] Configure Firestore indexes if needed
- [ ] Test authentication flows
- [ ] Verify all features work in production environment

---

## Security Rules

Before going live, update your Firestore security rules:

Go to: https://console.firebase.google.com/project/budgetpillarsdev/firestore/rules

Example production rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Monitoring & Analytics

After deployment:

1. **Firebase Console:** https://console.firebase.google.com/project/budgetpillarsdev
2. **Hosting Dashboard:** Monitor traffic, bandwidth usage
3. **Performance Monitoring:** Track app performance
4. **Analytics:** User engagement and behavior (if configured)
5. **Crashlytics:** Monitor errors (if configured)

---

## Quick Reference Commands

```powershell
# Build
flutter build web --release

# Deploy
firebase deploy --only hosting

# Preview
firebase hosting:channel:deploy preview

# Rollback to previous version
firebase hosting:clone SOURCE_SITE_ID:SOURCE_CHANNEL DESTINATION_SITE_ID:live

# View deployment history
firebase hosting:releases:list
```

---

## URLs

- **Firebase Console:** https://console.firebase.google.com/project/budgetpillarsdev
- **Hosting URL:** https://budgetpillarsdev.web.app (or .firebaseapp.com)
- **Firebase CLI Docs:** https://firebase.google.com/docs/cli

---

## Cost & Limits

Firebase Hosting **Spark Plan (Free)**:

- 10 GB storage
- 360 MB/day transfer
- Custom domain SSL included

Monitor usage: https://console.firebase.google.com/project/budgetpillarsdev/usage

If you exceed limits, you'll need to upgrade to the **Blaze Plan (Pay as you go)**.

---

## Next Steps After Deployment

1. Share the hosting URL with testers
2. Monitor Firebase Console for errors
3. Collect user feedback
4. Set up analytics and monitoring
5. Configure custom domain (optional)
6. Set up CI/CD pipeline (optional)
7. Enable performance monitoring
8. Plan for production database migration (if using test data)

---

**You're ready to deploy! 🚀**

Start with Step 1 and follow through each step carefully.
