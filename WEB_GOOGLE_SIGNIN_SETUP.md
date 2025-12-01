# Getting Google Sign-In Web Client ID

## Steps to Get Your Web Client ID

1. **Go to Firebase Console**

   - Visit: https://console.firebase.google.com/project/budgetpillarsdev/authentication/providers

2. **Click on Google Sign-In Provider**

   - Find "Google" in the list of providers
   - Click on it to expand

3. **Find Web SDK Configuration**

   - Look for "Web SDK configuration" section
   - You'll see "Web client ID" listed there
   - It will look like: `487033381743-XXXXXXXXXXXXXX.apps.googleusercontent.com`

4. **Copy the Web Client ID**

5. **Update web/index.html**
   - Open `web/index.html`
   - Find the line with `google-signin-client_id`
   - Replace `487033381743-YOUR_WEB_CLIENT_ID.apps.googleusercontent.com` with your actual Web client ID

## Configure Authorized Redirect URIs (IMPORTANT for Production)

After setting up the Web Client ID, you MUST configure authorized redirect URIs in Google Cloud Console:

1. **Go to Google Cloud Console Credentials**

   - Dev: https://console.cloud.google.com/apis/credentials?project=budgetpillarsdev
   - Prod: https://console.cloud.google.com/apis/credentials?project=pocketflow-tw4kf

2. **Click on your OAuth 2.0 Client ID**

   - Look for "Web client (auto created by Google Service)"
   - Click on it to edit

3. **Add Authorized JavaScript Origins**

   - Development:
     - `http://localhost`
     - `http://localhost:5000`
   - Production:
     - `https://pocketflow-tw4kf.firebaseapp.com`
     - `https://pocketflow-tw4kf.web.app`

4. **Add Authorized Redirect URIs**

   - Development:
     - `http://localhost/__/auth/handler`
     - `http://localhost:5000/__/auth/handler`
   - Production:
     - `https://pocketflow-tw4kf.firebaseapp.com/__/auth/handler`
     - `https://pocketflow-tw4kf.web.app/__/auth/handler`

5. **Save Changes**
   - Click "Save" at the bottom
   - Wait 5 minutes for changes to propagate
   - Clear browser cache or use incognito mode when testing

**Note:** The `__/auth/handler` path is Firebase's authentication redirect handler.

## Alternative: Use Google Cloud Console

If you don't see the Web Client ID in Firebase:

1. Go to: https://console.cloud.google.com/apis/credentials?project=budgetpillarsdev
2. Look for "Web client (auto created by Google Service)"
3. Copy the Client ID
4. Paste it in `web/index.html`

## Enable People API

Google Sign-In requires the People API to be enabled:

1. Go to: https://console.cloud.google.com/apis/library?project=budgetpillarsdev
2. Search for "People API"
3. Click "Enable"
4. Repeat for production project: https://console.cloud.google.com/apis/library?project=pocketflow-tw4kf

## Quick Test Without Google Sign-In

For now, you can test with **Email/Password only**:

1. Make sure Email/Password is enabled in Firebase Console
2. Run the app: `flutter run -d chrome`
3. Click "Sign Up" instead of "Continue with Google"
4. Create an account with email/password
5. Test sign in/sign out

Once you add the Web Client ID and configure redirect URIs, Google Sign-In will work on web!

## Common Errors

### Error 400: redirect_uri_mismatch

- **Cause:** The redirect URI is not authorized in Google Cloud Console
- **Fix:** Follow the "Configure Authorized Redirect URIs" section above
- **Wait Time:** Changes can take 5 minutes to propagate

### People API not enabled

- **Cause:** Google People API is not enabled for your project
- **Fix:** Follow the "Enable People API" section above
