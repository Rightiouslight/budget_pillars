import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/active_budget_provider.dart';
import '../dashboard_controller.dart';

/// Provider that triggers automatic transaction processing on app startup
final autoPaymentServiceProvider = Provider<AutoPaymentService>((ref) {
  return AutoPaymentService(ref);
});

class AutoPaymentService {
  final Ref _ref;
  bool _hasProcessed = false;

  AutoPaymentService(this._ref);

  /// Process automatic transactions (recurring expenses and incomes) once per app session
  /// Only processes if viewing the current active budget month
  Future<void> processIfNeeded() async {
    if (_hasProcessed) return;

    // Check if we're viewing the current active month
    final isCurrentMonth = _ref.read(isViewingCurrentActiveMonthProvider);

    if (!isCurrentMonth) {
      // Don't process automatic transactions for past/future months
      return;
    }

    _hasProcessed = true;
    await _ref
        .read(dashboardControllerProvider.notifier)
        .processAutomaticTransactions();
  }
}
