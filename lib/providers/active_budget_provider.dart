import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase/auth_repository.dart';
import '../data/firebase/firestore_repository.dart';
import '../data/models/monthly_budget.dart';
import '../utils/date_utils.dart' as budget_date_utils;
import 'user_settings_provider.dart';

/// Represents which budget is currently active (own or shared)
class ActiveBudgetInfo {
  final String userId;
  final String monthKey;
  final bool isShared;
  final bool canWrite;

  const ActiveBudgetInfo({
    required this.userId,
    required this.monthKey,
    this.isShared = false,
    this.canWrite = true,
  });

  ActiveBudgetInfo copyWith({
    String? userId,
    String? monthKey,
    bool? isShared,
    bool? canWrite,
  }) {
    return ActiveBudgetInfo(
      userId: userId ?? this.userId,
      monthKey: monthKey ?? this.monthKey,
      isShared: isShared ?? this.isShared,
      canWrite: canWrite ?? this.canWrite,
    );
  }
}

/// Provider for the currently active budget info (which user's budget and which month)
final activeBudgetInfoProvider =
    StateNotifierProvider<ActiveBudgetInfoNotifier, ActiveBudgetInfo?>((ref) {
      final currentUser = ref.watch(currentUserProvider);

      if (currentUser == null) {
        return ActiveBudgetInfoNotifier(null);
      }

      // Get the user's month start date setting
      final monthStartDate = ref.watch(monthStartDateProvider);

      // Use the date utility to get the effective initial date based on user's settings
      final effectiveDate = budget_date_utils.DateUtils.getEffectiveInitialDate(
        day: monthStartDate,
      );
      final monthKey =
          '${effectiveDate.year}-${effectiveDate.month.toString().padLeft(2, '0')}';

      return ActiveBudgetInfoNotifier(
        ActiveBudgetInfo(
          userId: currentUser.uid,
          monthKey: monthKey,
          isShared: false,
          canWrite: true,
        ),
      );
    });

class ActiveBudgetInfoNotifier extends StateNotifier<ActiveBudgetInfo?> {
  ActiveBudgetInfoNotifier(super.initialState);

  /// Switch to a different month for the current user
  void changeMonth(String monthKey) {
    if (state != null) {
      state = state!.copyWith(monthKey: monthKey);
    }
  }

  /// Navigate to next month
  void nextMonth() {
    if (state == null) return;

    final parts = state!.monthKey.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);

    month++;
    if (month > 12) {
      month = 1;
      year++;
    }

    final newMonthKey = '$year-${month.toString().padLeft(2, '0')}';
    state = state!.copyWith(monthKey: newMonthKey);
  }

  /// Navigate to previous month
  void previousMonth() {
    if (state == null) return;

    final parts = state!.monthKey.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);

    month--;
    if (month < 1) {
      month = 12;
      year--;
    }

    final newMonthKey = '$year-${month.toString().padLeft(2, '0')}';
    state = state!.copyWith(monthKey: newMonthKey);
  }

  /// Switch to a shared budget
  void switchToSharedBudget(String ownerId, String monthKey, bool canWrite) {
    state = ActiveBudgetInfo(
      userId: ownerId,
      monthKey: monthKey,
      isShared: true,
      canWrite: canWrite,
    );
  }

  /// Switch back to own budget
  void switchToOwnBudget(String userId) {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    state = ActiveBudgetInfo(
      userId: userId,
      monthKey: monthKey,
      isShared: false,
      canWrite: true,
    );
  }
}

/// Provider for the active budget stream
final activeBudgetProvider = StreamProvider<MonthlyBudget?>((ref) {
  final budgetInfo = ref.watch(activeBudgetInfoProvider);

  if (budgetInfo == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.budgetStream(budgetInfo.userId, budgetInfo.monthKey);
});

/// Helper provider to get the current month key
final currentMonthKeyProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

/// Helper provider to format the month display name
final monthDisplayNameProvider = Provider<String>((ref) {
  final budgetInfo = ref.watch(activeBudgetInfoProvider);

  if (budgetInfo == null) {
    return '';
  }

  final parts = budgetInfo.monthKey.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);

  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${monthNames[month - 1]} $year';
});

/// Provider to check if the currently viewed month is the active current month
/// This is used to determine if automatic transactions should be processed
final isViewingCurrentActiveMonthProvider = Provider<bool>((ref) {
  final budgetInfo = ref.watch(activeBudgetInfoProvider);

  if (budgetInfo == null) {
    return false;
  }

  // Get the user's month start date setting
  final monthStartDate = ref.watch(monthStartDateProvider);

  // Calculate the current active month key based on effective date
  final effectiveDate = budget_date_utils.DateUtils.getEffectiveInitialDate(
    day: monthStartDate,
  );
  final currentMonthKey =
      '${effectiveDate.year}-${effectiveDate.month.toString().padLeft(2, '0')}';

  // Compare with the currently viewed month
  return budgetInfo.monthKey == currentMonthKey;
});
