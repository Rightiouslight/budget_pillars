# Security Incident Response Checklist

**Date**: December 9, 2025  
**Incident**: Exposed Firebase API keys in public GitHub repository

---

## ✅ IMMEDIATE ACTIONS (Do in Google Cloud Console)

### Step 1: Regenerate API Keys

Go to: https://console.cloud.google.com/apis/credentials?project=pocketflow-tw4kf

- [ ] Find Web API key ending in `...ersoFA`
- [ ] Click on the key → Click "Regenerate Key"
- [ ] Copy the new key and save it securely
- [ ] Find Android API key ending in `...DQ1Y`
- [ ] Click on the key → Click "Regenerate Key"
- [ ] Copy the new key and save it securely

### Step 2: Add Restrictions to Web API Key

- [ ] Click on the regenerated Web API key
- [ ] Under "Application restrictions" → Select "HTTP referrers"
- [ ] Add referrers:
  - [ ] `https://pocketflow-tw4kf.web.app/*`
  - [ ] `https://pocketflow-tw4kf.firebaseapp.com/*`
  - [ ] `http://localhost:*`
  - [ ] `http://127.0.0.1:*`
- [ ] Under "API restrictions" → Select "Restrict key"
- [ ] Enable these APIs:
  - [ ] Identity Toolkit API
  - [ ] Cloud Firestore API
  - [ ] Firebase Authentication API
  - [ ] Firebase Installations API
  - [ ] Token Service API
- [ ] Click "Save"

### Step 3: Add Restrictions to Android API Key

- [ ] Click on the regenerated Android API key
- [ ] Under "Application restrictions" → Select "Android apps"
- [ ] Click "Add an item"
- [ ] Package name: `budgetpillars.lojinnovation.com`
- [ ] SHA-1: `B5:CF:06:B9:11:97:BA:39:0A:78:32:2E:12:05:40:A0:66:D7:43:10`
- [ ] Under "API restrictions" → Select "Restrict key"
- [ ] Enable the same APIs as Web key
- [ ] Click "Save"

---

## 🔍 MONITORING (Check for Abuse)

### Check Billing

Go to: https://console.cloud.google.com/billing

- [ ] Go to "Reports"
- [ ] Check usage for last 7 days
- [ ] Look for unusual spikes in API calls
- [ ] Note: Any suspicious activity? ****\_\_\_\_****

### Check Firebase Authentication

Go to: https://console.firebase.google.com/project/pocketflow-tw4kf/authentication/users

- [ ] Review list of users
- [ ] Check for suspicious accounts
- [ ] Check sign-in timestamps
- [ ] Note: Any unauthorized users? ****\_\_\_\_****

### Check Firestore Database

Go to: https://console.firebase.google.com/project/pocketflow-tw4kf/firestore

- [ ] Review recent documents
- [ ] Look for unexpected data
- [ ] Check modification timestamps
- [ ] Note: Any unusual data? ****\_\_\_\_****

### Check Cloud Logging

Go to: https://console.cloud.google.com/logs

- [ ] Filter logs for last 7 days
- [ ] Look for error patterns
- [ ] Check for unusual request sources
- [ ] Note: Any suspicious activity? ****\_\_\_\_****

---

## 🔧 UPDATE LOCAL CONFIGURATION

### Get New Configuration from Firebase

- [ ] Go to: https://console.firebase.google.com/project/pocketflow-tw4kf/settings/general
- [ ] Scroll to "Your apps" section
- [ ] For Web app: Copy the Firebase config
- [ ] For Android app: Download `google-services.json`

### Update Web Configuration

- [ ] Open: `lib\config\firebase_options_prod.dart`
- [ ] Find the `web` section
- [ ] Replace `apiKey` with the new Web API key
- [ ] Save the file
- [ ] Verify file is NOT staged in git (`git status`)

### Update Android Configuration

- [ ] Replace `android\app\google-services.json` with downloaded file
- [ ] Open: `lib\config\firebase_options_prod.dart`
- [ ] Find the `android` section
- [ ] Replace `apiKey` with the new Android API key
- [ ] Save the file
- [ ] Verify files are NOT staged in git (`git status`)

---

## ✅ TEST LOCALLY

- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run -t lib\main_prod.dart`
- [ ] Test sign-in works
- [ ] Test Firestore read/write
- [ ] Verify no errors in console

---

## 🚀 REDEPLOY APPLICATIONS

### Deploy Web App

- [ ] Run: `.\deploy-web.ps1`
- [ ] Wait for deployment to complete
- [ ] Visit: https://pocketflow-tw4kf.web.app
- [ ] Test sign-in on live site
- [ ] Verify everything works

### Deploy Android App

- [ ] Run: `.\deploy-android.ps1 -Version "1.0.1-hotfix.1" -ReleaseNotes "Security update: Regenerated API keys"`
- [ ] Wait for build to complete
- [ ] Wait for GitHub Release to be created
- [ ] Download APK from: https://github.com/Rightiouslight/budget_pillars/releases
- [ ] Install on test device
- [ ] Test sign-in on device
- [ ] Verify everything works

---

## ✅ VERIFICATION

### Verify Old Keys Are Deactivated

- [ ] In Google Cloud Console, check that old API keys are gone/disabled
- [ ] Try using old API key in a test (should fail)
- [ ] Confirm only new keys are active

### Verify New Keys Work

- [ ] Web app authentication works ✅
- [ ] Android app authentication works ✅
- [ ] Firestore reads work ✅
- [ ] Firestore writes work ✅
- [ ] No console errors ✅

### Verify Restrictions Work

- [ ] Try accessing web app from unauthorized domain (should fail)
- [ ] Web app works from approved domains (should work)
- [ ] Android app works with correct package name (should work)

---

## 📋 PREVENTION (Future Protection)

### Files Created

- [x] `.gitignore` updated (already done)
- [x] Template files created (already done)
- [x] Pre-commit hook installed (already done)
- [x] Documentation created (already done)

### Test Pre-commit Hook

- [ ] Make a test change to `firebase_options_prod.dart`
- [ ] Try to commit: `git add -A; git commit -m "test"`
- [ ] Hook should BLOCK the commit
- [ ] Verify it's working

### Enable GitHub Secret Scanning

- [ ] Go to: https://github.com/Rightiouslight/budget_pillars/settings/security_analysis
- [ ] Enable "Secret scanning"
- [ ] Enable "Push protection"

---

## 📝 INCIDENT SUMMARY

**What happened**: Firebase API keys were committed to public GitHub repository

**When discovered**: December 9, 2025 (email from Google)

**What was exposed**:

- Web API key: `AIzaSyB2vISec3_1i_D2KBrqFKGakfUBAersoFA`
- Android API key: `AIzaSyDgU4fkN8RExycQhsR5MbZIDNgcHdWDQ1Y`
- Exposed at: `lib/config/firebase_options_prod.dart`

**What was done**:

1. Keys regenerated: **\_** (date/time)
2. Restrictions added: **\_** (date/time)
3. Local configs updated: **\_** (date/time)
4. Apps redeployed: **\_** (date/time)
5. Verified working: **\_** (date/time)

**Evidence of abuse**: None found ☐ / Found (details): ********\_********

**Lessons learned**:

---

---

---

**Process improvements**:

---

---

---

---

## 🎯 COMPLETION

**All steps completed**: **\_** (date/time)

**Completed by**: ********\_********

**Verified by**: ********\_********

**Incident closed**: ☐

---

**Next Review**: After production launch + 30 days
