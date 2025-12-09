import 'config/flavor_config.dart';
import 'main.dart' as runner;

void main() {
  FlavorConfig(
    flavor: Flavor.prod,
    name: 'PROD',
    displayName: 'Budget Pillars',
    values: FlavorValues(
      firebaseProjectId: 'pocketflow-tw4kf',
      enableLogging: false,
      useFirebaseEmulator: false,
      firestoreEmulatorHost: 'localhost',
      firestoreEmulatorPort: 8080,
    ),
  );

  runner.main();
}
