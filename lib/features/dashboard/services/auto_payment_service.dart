import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<void> processIfNeeded() async {
    if (_hasProcessed) return;

    _hasProcessed = true;
    await _ref
        .read(dashboardControllerProvider.notifier)
        .processAutomaticTransactions();
  }
}
