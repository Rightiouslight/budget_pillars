import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import '../firebase_options.dart'; // Development options
import 'firebase_options_prod.dart'; // Production options
import 'environment.dart';

/// Returns the appropriate Firebase options based on the current environment
class AppFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return DevelopmentFirebaseOptions.currentPlatform;
      case Environment.production:
        return ProductionFirebaseOptions.currentPlatform;
    }
  }
}
