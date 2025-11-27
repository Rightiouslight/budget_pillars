import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/monthly_budget.dart';
import 'active_budget_provider.dart';

/// Provider that holds a temporary budget override during optimistic updates
/// This prevents UI jumping when reordering items before Firestore confirms the update
final budgetOverrideProvider =
    StateProvider<MonthlyBudget?>((ref) => null);

/// Combined provider that returns the override if present, otherwise the stream value
final effectiveBudgetProvider = Provider<AsyncValue<MonthlyBudget?>>((ref) {
  final override = ref.watch(budgetOverrideProvider);
  
  if (override != null) {
    // Return the optimistic update
    return AsyncValue.data(override);
  }
  
  // Return the actual stream value
  return ref.watch(activeBudgetProvider);
});
