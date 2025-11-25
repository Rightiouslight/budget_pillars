import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase/auth_repository.dart';
import '../data/firebase/firestore_repository.dart';
import '../data/models/user_settings.dart';

/// Provider that streams the current user's settings from Firestore
final userSettingsProvider = StreamProvider<UserSettings>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    // Return default settings when not authenticated
    return Stream.value(const UserSettings());
  }

  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository
      .userSettingsStream(user.uid)
      .map((settings) => settings ?? const UserSettings());
});

/// Provider that extracts just the monthStartDate from user settings
final monthStartDateProvider = Provider<int>((ref) {
  final settingsAsync = ref.watch(userSettingsProvider);
  return settingsAsync.maybeWhen(
    data: (settings) => settings.monthStartDate,
    orElse: () => 1, // Default to 1st of month
  );
});
