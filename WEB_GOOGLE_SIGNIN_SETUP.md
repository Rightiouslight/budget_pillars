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

## Alternative: Use Google Cloud Console

If you don't see the Web Client ID in Firebase:

1. Go to: https://console.cloud.google.com/apis/credentials?project=budgetpillarsdev
2. Look for "Web client (auto created by Google Service)"
3. Copy the Client ID
4. Paste it in `web/index.html`

## Quick Test Without Google Sign-In

For now, you can test with **Email/Password only**:

1. Make sure Email/Password is enabled in Firebase Console
2. Run the app: `flutter run -d chrome`
3. Click "Sign Up" instead of "Continue with Google"
4. Create an account with email/password
5. Test sign in/sign out

Once you add the Web Client ID, Google Sign-In will work on web!
