import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard_controller.dart';

/// Provider that triggers automatic payment processing on app startup
final autoPaymentServiceProvider = Provider<AutoPaymentService>((ref) {
  return AutoPaymentService(ref);
});

class AutoPaymentService {
  final Ref _ref;
  bool _hasProcessed = false;

  AutoPaymentService(this._ref);

  /// Process automatic payments once per app session
  Future<void> processIfNeeded() async {
    if (_hasProcessed) return;

    _hasProcessed = true;
    await _ref
        .read(dashboardControllerProvider.notifier)
        .processAutomaticPayments();
  }
}
