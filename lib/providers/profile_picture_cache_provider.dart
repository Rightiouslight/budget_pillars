import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase/auth_repository.dart';
import '../data/firebase/firestore_repository.dart';
import '../utils/profile_picture_cache.dart';
import 'user_settings_provider.dart';

/// Provider that handles caching user profile pictures
final profilePictureCacheProvider = Provider<ProfilePictureCacheController>((ref) {
  return ProfilePictureCacheController(ref);
});

class ProfilePictureCacheController {
  final Ref _ref;

  ProfilePictureCacheController(this._ref);

  /// Checks if profile picture needs to be cached and caches it
  Future<void> cacheProfilePictureIfNeeded() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final settings = _ref.read(userSettingsProvider).value;
    if (settings == null) return;

    // If we already have a cached picture, no need to download again
    if (settings.cachedProfilePicture != null && settings.cachedProfilePicture!.isNotEmpty) {
      return;
    }

    // If user has a photo URL and it's not cached, download and cache it
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      final base64Image = await downloadAndCacheProfilePicture(user.photoURL);
      
      if (base64Image != null) {
        final repository = _ref.read(firestoreRepositoryProvider);
        final updatedSettings = settings.copyWith(cachedProfilePicture: base64Image);
        await repository.saveUserSettings(user.uid, updatedSettings);
      }
    }
  }

  /// Forces a refresh of the cached profile picture
  Future<void> refreshProfilePicture() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final settings = _ref.read(userSettingsProvider).value;
    if (settings == null) return;

    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      final base64Image = await downloadAndCacheProfilePicture(user.photoURL);
      
      if (base64Image != null) {
        final repository = _ref.read(firestoreRepositoryProvider);
        final updatedSettings = settings.copyWith(cachedProfilePicture: base64Image);
        await repository.saveUserSettings(user.uid, updatedSettings);
      }
    }
  }
}
