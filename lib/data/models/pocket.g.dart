// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pocket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PocketImpl _$$PocketImplFromJson(Map<String, dynamic> json) => _$PocketImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  balance: (json['balance'] as num).toDouble(),
  color: json['color'] as String?,
);

Map<String, dynamic> _$$PocketImplToJson(_$PocketImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'balance': instance.balance,
      'color': instance.color,
    };
