import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase/auth_repository.dart';
import '../data/firebase/firestore_repository.dart';
import '../data/models/user_data.dart';
import '../utils/profile_picture_cache.dart';
import 'user_data_provider.dart';

/// Provider that handles caching user profile pictures
final profilePictureCacheProvider = Provider<ProfilePictureCacheController>((
  ref,
) {
  return ProfilePictureCacheController(ref);
});

class ProfilePictureCacheController {
  final Ref _ref;

  ProfilePictureCacheController(this._ref);

  /// Checks if profile picture needs to be cached and caches it
  Future<void> cacheProfilePictureIfNeeded() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    // Wait for user data to load from Firestore
    final userDataAsync = _ref.read(userDataProvider);
    if (userDataAsync is! AsyncData) return; // Don't proceed if still loading

    final userData = userDataAsync.value;

    // If we already have a cached picture, no need to download again
    if (userData?.cachedProfilePicture != null &&
        userData!.cachedProfilePicture!.isNotEmpty) {
      return;
    }

    // If user has a photo URL and it's not cached, download and cache it
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      final base64Image = await downloadAndCacheProfilePicture(user.photoURL);

      if (base64Image != null) {
        // Read user data again to ensure we have the latest data
        final latestUserDataAsync = _ref.read(userDataProvider);
        if (latestUserDataAsync is! AsyncData) return;

        final latestUserData = latestUserDataAsync.value;

        final repository = _ref.read(firestoreRepositoryProvider);
        final updatedUserData = (latestUserData ?? const UserData()).copyWith(
          cachedProfilePicture: base64Image,
          displayName: user.displayName,
          email: user.email,
        );
        await repository.saveUserData(user.uid, updatedUserData);
      }
    }
  }

  /// Forces a refresh of the cached profile picture
  Future<void> refreshProfilePicture() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    // Wait for user data to load from Firestore
    final userDataAsync = _ref.read(userDataProvider);
    if (userDataAsync is! AsyncData) return; // Don't proceed if still loading

    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      final base64Image = await downloadAndCacheProfilePicture(user.photoURL);

      if (base64Image != null) {
        // Read user data again to ensure we have the latest data
        final latestUserDataAsync = _ref.read(userDataProvider);
        if (latestUserDataAsync is! AsyncData) return;

        final latestUserData = latestUserDataAsync.value;

        final repository = _ref.read(firestoreRepositoryProvider);
        final updatedUserData = (latestUserData ?? const UserData()).copyWith(
          cachedProfilePicture: base64Image,
          displayName: user.displayName,
          email: user.email,
        );
        await repository.saveUserData(user.uid, updatedUserData);
      }
    }
  }
}
