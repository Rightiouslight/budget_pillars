import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase/auth_repository.dart';
import '../data/firebase/firestore_repository.dart';
import '../data/models/user_data.dart';

/// Provider that streams user data from Firestore
final userDataProvider = StreamProvider<UserData?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.userDataStream(user.uid);
});
