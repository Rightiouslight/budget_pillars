// File for production Firebase configuration
// Run: flutterfire configure --project=budgetpillars --out=lib/config/firebase_options_prod.dart
// to generate this file with your production Firebase project settings
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Production [FirebaseOptions] for use with your Firebase apps.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'ProductionFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'ProductionFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace these with your actual production Firebase configuration
  // Run: flutterfire configure --project=your-prod-project-id
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_PROD_WEB_API_KEY',
    appId: 'YOUR_PROD_WEB_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'budgetpillars', // Your production project ID
    authDomain: 'budgetpillars.firebaseapp.com',
    storageBucket: 'budgetpillars.firebasestorage.app',
    measurementId: 'YOUR_PROD_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_PROD_ANDROID_API_KEY',
    appId: 'YOUR_PROD_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'budgetpillars',
    storageBucket: 'budgetpillars.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_PROD_IOS_API_KEY',
    appId: 'YOUR_PROD_IOS_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'budgetpillars',
    storageBucket: 'budgetpillars.firebasestorage.app',
    iosClientId: 'YOUR_PROD_IOS_CLIENT_ID',
    iosBundleId: 'budgetpillars.lojinnovation.com.easyBudgetPillars',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_PROD_MACOS_API_KEY',
    appId: 'YOUR_PROD_MACOS_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'budgetpillars',
    storageBucket: 'budgetpillars.firebasestorage.app',
    iosClientId: 'YOUR_PROD_MACOS_CLIENT_ID',
    iosBundleId: 'budgetpillars.lojinnovation.com.easyBudgetPillars',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_PROD_WINDOWS_API_KEY',
    appId: 'YOUR_PROD_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
    projectId: 'budgetpillars',
    authDomain: 'budgetpillars.firebaseapp.com',
    storageBucket: 'budgetpillars.firebasestorage.app',
    measurementId: 'YOUR_PROD_WINDOWS_MEASUREMENT_ID',
  );
}
