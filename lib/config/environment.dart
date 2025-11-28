/// Environment configuration for the app
enum Environment { development, production }

/// Configuration settings for the current environment
class EnvironmentConfig {
  // Change this to switch between dev and prod
  static const Environment current = Environment.production;

  static bool get isDevelopment => current == Environment.development;
  static bool get isProduction => current == Environment.production;

  /// Firebase project ID based on environment
  static String get firebaseProjectId {
    switch (current) {
      case Environment.development:
        return 'budgetpillarsdev';
      case Environment.production:
        return 'budgetpillars'; // Replace with your actual prod project ID
    }
  }

  /// App display name based on environment
  static String get appName {
    switch (current) {
      case Environment.development:
        return 'Budget Pillars (Dev)';
      case Environment.production:
        return 'Budget Pillars';
    }
  }

  /// Enable debug logging
  static bool get enableDebugLogging => isDevelopment;

  /// Enable Firebase emulator (local development)
  static bool get useFirebaseEmulator =>
      false; // Set to true for local emulator

  /// Firestore emulator host
  static String get firestoreEmulatorHost => 'localhost';

  /// Firestore emulator port
  static int get firestoreEmulatorPort => 8080;
}
