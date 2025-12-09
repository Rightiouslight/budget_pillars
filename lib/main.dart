import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/app.dart';
import 'config/flavor_config.dart';
import 'firebase_options.dart' as firebase_dev;
import 'config/firebase_options_prod.dart' as firebase_prod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with flavor-specific options
  if (FlavorConfig.isDevelopment) {
    await Firebase.initializeApp(
      options: firebase_dev.DevelopmentFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: firebase_prod.ProductionFirebaseOptions.currentPlatform,
    );
  }

  // Configure Firestore emulator if enabled
  if (FlavorConfig.instance.values.useFirebaseEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator(
      FlavorConfig.instance.values.firestoreEmulatorHost,
      FlavorConfig.instance.values.firestoreEmulatorPort,
    );

    if (FlavorConfig.instance.values.enableLogging) {
      debugPrint(
        '🔧 Using Firestore Emulator: '
        '${FlavorConfig.instance.values.firestoreEmulatorHost}:'
        '${FlavorConfig.instance.values.firestoreEmulatorPort}',
      );
    }
  }

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (FlavorConfig.instance.values.enableLogging) {
    debugPrint('🚀 Starting ${FlavorConfig.instance.displayName}');
    debugPrint('📦 Environment: ${FlavorConfig.instance.name}');
    debugPrint(
      '🔥 Firebase Project: ${FlavorConfig.instance.values.firebaseProjectId}',
    );
  }

  runApp(const ProviderScope(child: BudgetPillarsApp()));
}
