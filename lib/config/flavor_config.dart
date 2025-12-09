enum Flavor { dev, prod }

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String displayName;
  final FlavorValues values;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required String displayName,
    required FlavorValues values,
  }) {
    _instance ??= FlavorConfig._internal(flavor, name, displayName, values);
    return _instance!;
  }

  FlavorConfig._internal(this.flavor, this.name, this.displayName, this.values);

  static FlavorConfig get instance {
    return _instance!;
  }

  static bool get isDevelopment => _instance?.flavor == Flavor.dev;
  static bool get isProduction => _instance?.flavor == Flavor.prod;
}

class FlavorValues {
  final String firebaseProjectId;
  final bool enableLogging;
  final bool useFirebaseEmulator;
  final String firestoreEmulatorHost;
  final int firestoreEmulatorPort;

  FlavorValues({
    required this.firebaseProjectId,
    required this.enableLogging,
    this.useFirebaseEmulator = false,
    this.firestoreEmulatorHost = 'localhost',
    this.firestoreEmulatorPort = 8080,
  });
}
