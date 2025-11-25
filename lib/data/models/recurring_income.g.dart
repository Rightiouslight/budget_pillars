// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringIncomeImpl _$$RecurringIncomeImplFromJson(
  Map<String, dynamic> json,
) => _$RecurringIncomeImpl(
  id: json['id'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  amount: (json['amount'] as num).toDouble(),
  accountId: json['accountId'] as String?,
  pocketId: json['pocketId'] as String?,
  dayOfMonth: (json['dayOfMonth'] as num).toInt(),
);

Map<String, dynamic> _$$RecurringIncomeImplToJson(
  _$RecurringIncomeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'amount': instance.amount,
  'accountId': instance.accountId,
  'pocketId': instance.pocketId,
  'dayOfMonth': instance.dayOfMonth,
};
