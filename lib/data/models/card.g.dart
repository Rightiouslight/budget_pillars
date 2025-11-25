// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PocketCardImpl _$$PocketCardImplFromJson(Map<String, dynamic> json) =>
    _$PocketCardImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      balance: (json['balance'] as num).toDouble(),
      color: json['color'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$PocketCardImplToJson(_$PocketCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'balance': instance.balance,
      'color': instance.color,
      'type': instance.$type,
    };

_$CategoryCardImpl _$$CategoryCardImplFromJson(Map<String, dynamic> json) =>
    _$CategoryCardImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      budgetValue: (json['budgetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      color: json['color'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      dueDate: (json['dueDate'] as num?)?.toInt(),
      destinationPocketId: json['destinationPocketId'] as String?,
      destinationAccountId: json['destinationAccountId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$CategoryCardImplToJson(_$CategoryCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'budgetValue': instance.budgetValue,
      'currentValue': instance.currentValue,
      'color': instance.color,
      'isRecurring': instance.isRecurring,
      'dueDate': instance.dueDate,
      'destinationPocketId': instance.destinationPocketId,
      'destinationAccountId': instance.destinationAccountId,
      'type': instance.$type,
    };
