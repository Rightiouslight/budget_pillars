import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/monthly_budget.dart';
import '../models/user_settings.dart';
import '../models/user_data.dart';
import '../models/share_invitation.dart';
import '../models/shared_budget_access.dart';

/// Provider for FirestoreRepository
final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(FirebaseFirestore.instance);
});

class FirestoreRepository {
  final FirebaseFirestore _firestore;

  FirestoreRepository(this._firestore);

  // ===== Monthly Budget Operations =====

  /// Get a stream of the monthly budget for a specific user and month
  Stream<MonthlyBudget?> budgetStream(String userId, String monthKey) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }

          try {
            final budget = MonthlyBudget.fromJson(snapshot.data()!);
            return budget;
          } catch (e, stackTrace) {
            print('❌ Error parsing MonthlyBudget: $e');
            print('Stack trace: $stackTrace');
            return null;
          }
        });
  }

  /// Get a single monthly budget snapshot (not a stream)
  Future<MonthlyBudget?> getBudget(String userId, String monthKey) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    try {
      return MonthlyBudget.fromJson(snapshot.data()!);
    } catch (e, stackTrace) {
      print('❌ Error parsing MonthlyBudget: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Save the monthly budget for a specific user and month
  Future<void> saveBudget(
    String userId,
    String monthKey,
    MonthlyBudget budget,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey)
        .set(budget.toJson());
  }

  /// Update specific fields in a budget
  Future<void> updateBudget(
    String userId,
    String monthKey,
    Map<String, dynamic> updates,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey)
        .update(updates);
  }

  /// Delete a monthly budget
  Future<void> deleteBudget(String userId, String monthKey) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey)
        .delete();
  }

  // ===== User Settings Operations =====

  /// Get a stream of user settings
  Stream<UserSettings?> userSettingsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('data')
        .doc('settings')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            print(
              '⚠️  Firestore: No settings document found for user: $userId',
            );
            print('   Returning null (not default settings)');
            return null; // Return null instead of default settings
          }
          try {
            print('✅ Firestore: Settings loaded for user: $userId');
            return UserSettings.fromJson(snapshot.data()!);
          } catch (e) {
            print('❌ Error parsing UserSettings: $e');
            return null; // Return null on error instead of default settings
          }
        });
  }

  /// Save user settings
  Future<void> saveUserSettings(String userId, UserSettings settings) async {
    print('📝 Firestore: Saving user settings for user: $userId');
    print('   Path: /users/$userId/data/settings');
    print('   Data: ${settings.toJson()}');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('data')
        .doc('settings')
        .set(settings.toJson());

    print('✅ Firestore: Settings saved successfully');
  }

  // ===== User Data Operations =====

  /// Get a stream of user data
  Stream<UserData?> userDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('data')
        .doc('userData')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            print(
              '⚠️  Firestore: No userData document found for user: $userId',
            );
            print('   Returning null');
            return null;
          }
          try {
            print('✅ Firestore: UserData loaded for user: $userId');
            return UserData.fromJson(snapshot.data()!);
          } catch (e) {
            print('❌ Error parsing UserData: $e');
            return null;
          }
        });
  }

  /// Save user data
  Future<void> saveUserData(String userId, UserData userData) async {
    print('📝 Firestore: Saving user data for user: $userId');
    print('   Path: /users/$userId/data/userData');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('data')
        .doc('userData')
        .set(userData.toJson());

    print('✅ Firestore: UserData saved successfully');
  }

  // ===== Share Invitation Operations =====

  /// Send a share invitation
  Future<void> sendShareInvitation(ShareInvitation invitation) async {
    await _firestore
        .collection('share_invitations')
        .doc(invitation.id)
        .set(invitation.toJson());
  }

  /// Get invitations sent by a user
  Stream<List<ShareInvitation>> sentInvitationsStream(String userId) {
    return _firestore
        .collection('share_invitations')
        .where('fromUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ShareInvitation.fromJson(doc.data()))
              .toList();
        });
  }

  /// Get invitations received by a user
  Stream<List<ShareInvitation>> receivedInvitationsStream(String userEmail) {
    return _firestore
        .collection('share_invitations')
        .where('toUserEmail', isEqualTo: userEmail)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ShareInvitation.fromJson(doc.data()))
              .toList();
        });
  }

  /// Update invitation status
  Future<void> updateInvitationStatus(
    String invitationId,
    String status,
  ) async {
    await _firestore.collection('share_invitations').doc(invitationId).update({
      'status': status,
    });
  }

  /// Delete an invitation
  Future<void> deleteInvitation(String invitationId) async {
    await _firestore.collection('share_invitations').doc(invitationId).delete();
  }

  // ===== Shared Budget Access Operations =====

  /// Add shared budget access for a user
  Future<void> addSharedBudgetAccess(
    String userId,
    SharedBudgetAccess access,
  ) async {
    final docId = '${access.ownerId}_${access.monthKey}';
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('shared_budgets')
        .doc(docId)
        .set(access.toJson());
  }

  /// Get all shared budgets for a user
  Stream<List<SharedBudgetAccess>> sharedBudgetsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shared_budgets')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SharedBudgetAccess.fromJson(doc.data()))
              .toList();
        });
  }

  /// Remove shared budget access
  Future<void> removeSharedBudgetAccess(
    String userId,
    String ownerId,
    String monthKey,
  ) async {
    final docId = '${ownerId}_$monthKey';
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('shared_budgets')
        .doc(docId)
        .delete();
  }

  // ===== Helper Methods =====

  /// Get a reference to a budget document
  DocumentReference getBudgetRef(String userId, String monthKey) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey);
  }

  /// Check if a budget exists
  Future<bool> budgetExists(String userId, String monthKey) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey)
        .get();
    return doc.exists;
  }
}
