import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/app.dart';
import 'config/firebase_config.dart';
import 'config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with environment-specific options
  await Firebase.initializeApp(options: AppFirebaseOptions.currentPlatform);

  // Configure Firestore emulator if enabled
  if (EnvironmentConfig.useFirebaseEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator(
      EnvironmentConfig.firestoreEmulatorHost,
      EnvironmentConfig.firestoreEmulatorPort,
    );

    if (EnvironmentConfig.enableDebugLogging) {
      debugPrint(
        '🔧 Using Firestore Emulator: '
        '${EnvironmentConfig.firestoreEmulatorHost}:'
        '${EnvironmentConfig.firestoreEmulatorPort}',
      );
    }
  }

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (EnvironmentConfig.enableDebugLogging) {
    debugPrint('🚀 Starting ${EnvironmentConfig.appName}');
    debugPrint('📦 Environment: ${EnvironmentConfig.current.name}');
    debugPrint('🔥 Firebase Project: ${EnvironmentConfig.firebaseProjectId}');
  }

  runApp(const ProviderScope(child: BudgetPillarsApp()));
}
