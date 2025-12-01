# Keystore Setup Guide for Budget Pillars

## Creating Your Upload Keystore

### Step 1: Generate the Keystore

Run this command in PowerShell from `android/app` directory:

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Answer the Prompts

You'll be asked for the following information. **SAVE ALL PASSWORDS SECURELY!**

1. **Enter keystore password**: Create a strong password (e.g., `MySecurePass123!`)

   - Write this down immediately!
   - You'll need it every time you build a release

2. **Re-enter new password**: Type the same password again

3. **What is your first and last name?**: Your name (e.g., `Heinrich Dutoit`)

4. **What is the name of your organizational unit?**: Your team/department (e.g., `Development` or just press Enter)

5. **What is the name of your organization?**: Your company (e.g., `Loj Innovation` or your company name)

6. **What is the name of your City or Locality?**: Your city (e.g., `Johannesburg`)

7. **What is the name of your State or Province?**: Your state/province (e.g., `Gauteng`)

8. **What is the two-letter country code for this unit?**: Country code (e.g., `ZA` for South Africa)

9. **Is CN=..., OU=..., O=..., L=..., ST=..., C=... correct?**: Type `yes`

10. **Enter key password for <upload>**: Press Enter to use the same password, or create a different one
    - If different, write this down too!

### Step 3: Verify Keystore was Created

```powershell
# Check if file exists
ls upload-keystore.jks

# Get SHA fingerprints
keytool -list -v -keystore upload-keystore.jks -alias upload
```

You should see output with SHA1 and SHA256 fingerprints.

---

## Create key.properties File

Create a new file: `android/key.properties` (in the `android` folder, NOT `android/app`)

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

**Replace:**

- `YOUR_KEYSTORE_PASSWORD` with the keystore password you created
- `YOUR_KEY_PASSWORD` with the key password (same as keystore if you pressed Enter)

**Example:**

```properties
storePassword=MySecurePass123!
keyPassword=MySecurePass123!
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

---

## Configure build.gradle.kts for Signing

The deployment guide has the full configuration, but here's a quick summary:

1. Make sure `.gitignore` includes:

   ```
   *.jks
   *.keystore
   **/key.properties
   ```

2. Update `android/app/build.gradle.kts` to load the keystore and use it for release builds

---

## Get SHA Fingerprints for Firebase

After creating the keystore, run:

```powershell
keytool -list -v -keystore upload-keystore.jks -alias upload
```

Copy the **SHA1** and **SHA256** values and add them to Firebase:

1. Go to Firebase Console → Project Settings
2. Select your Android app
3. Add both fingerprints under "SHA certificate fingerprints"
4. Download the updated `google-services.json`
5. Replace `android/app/google-services.json`

---

## Also Get Debug Keystore SHA (for Development)

For testing Google Sign-In during development:

```powershell
keytool -list -v -keystore C:\Users\YOUR_USERNAME\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Replace `YOUR_USERNAME` with your Windows username.

Add these debug SHA fingerprints to Firebase too (so Google Sign-In works during development).

---

## IMPORTANT: Security

⚠️ **NEVER commit these files to Git:**

- `upload-keystore.jks`
- `key.properties`

⚠️ **BACKUP your keystore:**

- Copy `upload-keystore.jks` to a secure location (USB drive, password manager, cloud backup)
- Save your passwords in a password manager
- **If you lose the keystore, you CANNOT update your app on Google Play Store!**

---

## Quick Reference

| File                  | Location       | Purpose                             |
| --------------------- | -------------- | ----------------------------------- |
| `upload-keystore.jks` | `android/app/` | Keystore for signing releases       |
| `key.properties`      | `android/`     | Passwords and keystore path         |
| `.gitignore`          | Root           | Prevents committing sensitive files |

**Passwords to Save:**

- Keystore password
- Key password (might be same as keystore)
- SHA1 fingerprint
- SHA256 fingerprint
