import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase/auth_repository.dart';
import '../data/firebase/firestore_repository.dart';
import '../data/models/user_settings.dart';

/// Controller for managing user settings updates
final userSettingsControllerProvider =
    StateNotifierProvider<UserSettingsController, AsyncValue<void>>((ref) {
      return UserSettingsController(ref);
    });

class UserSettingsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  UserSettingsController(this._ref) : super(const AsyncValue.data(null));

  FirestoreRepository get _repository => _ref.read(firestoreRepositoryProvider);

  String? get _userId => _ref.read(currentUserProvider)?.uid;

  /// Update user settings in Firestore
  Future<void> updateSettings(UserSettings settings) async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveUserSettings(_userId!, settings);
    });
  }
}
