import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase/auth_repository.dart';
import '../../data/firebase/firestore_repository.dart';
import '../../data/models/budget_notification.dart';
import '../../data/models/monthly_budget.dart';
import '../../providers/active_budget_provider.dart';

/// Provider for managing budget notifications
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
      return NotificationController(ref);
    });

/// Controller for managing budget notifications
class NotificationController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  NotificationController(this._ref) : super(const AsyncValue.data(null));

  FirestoreRepository get _repository => _ref.read(firestoreRepositoryProvider);

  String get _userId => _ref.read(authRepositoryProvider).currentUser!.uid;
  String get _monthKey => _ref.read(currentMonthKeyProvider);

  Future<MonthlyBudget?> _getCurrentBudget() async {
    final budgetAsync = _ref.read(activeBudgetProvider);
    return budgetAsync.value;
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedNotifications = budget.notifications.map((notif) {
        if (notif.id == notificationId) {
          return notif.copyWith(isRead: true);
        }
        return notif;
      }).toList();

      final updatedBudget = budget.copyWith(
        notifications: updatedNotifications,
      );
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedNotifications = budget.notifications.map((notif) {
        return notif.copyWith(isRead: true);
      }).toList();

      final updatedBudget = budget.copyWith(
        notifications: updatedNotifications,
      );
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedBudget = budget.copyWith(notifications: []);
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }

  /// Delete a single notification
  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final budget = await _getCurrentBudget();
      if (budget == null) return;

      final updatedNotifications = budget.notifications
          .where((notif) => notif.id != notificationId)
          .toList();

      final updatedBudget = budget.copyWith(
        notifications: updatedNotifications,
      );
      await _repository.saveBudget(_userId, _monthKey, updatedBudget);
    });
  }
}

/// Provider for the count of unread notifications
final unreadNotificationCountProvider = Provider<int>((ref) {
  final budgetAsync = ref.watch(activeBudgetProvider);

  return budgetAsync.when(
    data: (budget) {
      if (budget == null) return 0;
      return budget.notifications.where((n) => !n.isRead).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for all notifications (sorted by timestamp, newest first)
final allNotificationsProvider = Provider<List<BudgetNotification>>((ref) {
  final budgetAsync = ref.watch(activeBudgetProvider);

  return budgetAsync.when(
    data: (budget) {
      if (budget == null) return [];
      final notifications = List<BudgetNotification>.from(budget.notifications);
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notifications;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
