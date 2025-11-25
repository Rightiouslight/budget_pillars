// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Object),
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      targetAccountId: json['targetAccountId'] as String?,
      targetPocketId: json['targetPocketId'] as String?,
      targetPocketName: json['targetPocketName'] as String?,
      sourcePocketId: json['sourcePocketId'] as String?,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'description': instance.description,
      'date': const TimestampConverter().toJson(instance.date),
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'targetAccountId': instance.targetAccountId,
      'targetPocketId': instance.targetPocketId,
      'targetPocketName': instance.targetPocketName,
      'sourcePocketId': instance.sourcePocketId,
    };
