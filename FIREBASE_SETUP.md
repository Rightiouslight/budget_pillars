# Firebase Console Setup - Quick Guide

## Enable Authentication

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **budgetpillarsdev**
3. Click on **Authentication** in the left sidebar
4. Click **Get Started** (if first time) or **Sign-in method** tab
5. Enable the following sign-in providers:

### Email/Password
- Click on **Email/Password**
- Toggle **Enable**
- Click **Save**

### Google Sign-In
- Click on **Google**
- Toggle **Enable**
- Enter project support email (your email)
- Click **Save**

## Set Up Firestore Database

1. In Firebase Console, click **Firestore Database** in the left sidebar
2. Click **Create database**
3. Choose **Start in test mode** (we'll add security rules later)
4. Select a location (choose closest to your users)
5. Click **Enable**

## Update Security Rules (Important!)

Once Firestore is created:

1. Go to **Firestore Database** → **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /budgets/{monthKey} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /settings/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /shared_budgets/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Share invitations - users can read all, but only modify their own
    match /share_invitations/{invitationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.fromUserId == request.auth.uid || 
         resource.data.toUserEmail == request.auth.token.email);
    }
  }
}
```

3. Click **Publish**

## Testing Checklist

After setup is complete, you should be able to:
- [x] Firebase initialized without errors
- [ ] Sign up with email/password
- [ ] Sign in with email/password
- [ ] Sign in with Google
- [ ] See user data in Firebase Console → Authentication → Users

## Next Steps

Once authentication is working:
- Test creating a user account
- Verify user appears in Firebase Console
- Test Google Sign-In
- Ready to move to Phase 2!
