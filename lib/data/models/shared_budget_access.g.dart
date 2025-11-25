// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_budget_access.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedBudgetAccessImpl _$$SharedBudgetAccessImplFromJson(
  Map<String, dynamic> json,
) => _$SharedBudgetAccessImpl(
  ownerId: json['ownerId'] as String,
  ownerEmail: json['ownerEmail'] as String,
  monthKey: json['monthKey'] as String,
  canWrite: json['canWrite'] as bool? ?? false,
);

Map<String, dynamic> _$$SharedBudgetAccessImplToJson(
  _$SharedBudgetAccessImpl instance,
) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'ownerEmail': instance.ownerEmail,
  'monthKey': instance.monthKey,
  'canWrite': instance.canWrite,
};
