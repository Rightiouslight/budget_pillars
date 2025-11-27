import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_notification.freezed.dart';
part 'budget_notification.g.dart';

/// Types of notifications that can be generated in the budget system
enum NotificationType {
  @JsonValue('automatic_payment')
  automaticPayment,

  @JsonValue('recurring_income')
  recurringIncome,

  @JsonValue('error')
  error,

  @JsonValue('info')
  info,

  @JsonValue('import_success')
  importSuccess,

  @JsonValue('import_error')
  importError,
}

/// Represents a notification about automatic transactions or system events.
///
/// Notifications are stored in the MonthlyBudget and displayed in a bell icon
/// notification center, providing a non-intrusive way to inform users about
/// automatic processing, errors, and other events.
@freezed
class BudgetNotification with _$BudgetNotification {
  const factory BudgetNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String message,
    required DateTime timestamp,
    @Default(false) bool isRead,
    String? relatedTransactionId,
  }) = _BudgetNotification;

  factory BudgetNotification.fromJson(Map<String, dynamic> json) =>
      _$BudgetNotificationFromJson(json);
}
