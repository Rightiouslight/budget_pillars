// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetNotificationImpl _$$BudgetNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$BudgetNotificationImpl(
  id: json['id'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  title: json['title'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isRead: json['isRead'] as bool? ?? false,
  relatedTransactionId: json['relatedTransactionId'] as String?,
);

Map<String, dynamic> _$$BudgetNotificationImplToJson(
  _$BudgetNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
  'isRead': instance.isRead,
  'relatedTransactionId': instance.relatedTransactionId,
};

const _$NotificationTypeEnumMap = {
  NotificationType.automaticPayment: 'automatic_payment',
  NotificationType.recurringIncome: 'recurring_income',
  NotificationType.error: 'error',
  NotificationType.info: 'info',
  NotificationType.importSuccess: 'import_success',
  NotificationType.importError: 'import_error',
};
