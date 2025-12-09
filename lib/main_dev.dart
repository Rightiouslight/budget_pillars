import 'config/flavor_config.dart';
import 'main.dart' as runner;

void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    displayName: 'Budget Pillars DEV',
    values: FlavorValues(
      firebaseProjectId: 'budgetpillarsdev',
      enableLogging: true,
      useFirebaseEmulator:
          false, // Set to true if you want to use local emulator
      firestoreEmulatorHost: 'localhost',
      firestoreEmulatorPort: 8080,
    ),
  );

  runner.main();
}
