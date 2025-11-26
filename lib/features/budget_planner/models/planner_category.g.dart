// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlannerCategoryImpl _$$PlannerCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$PlannerCategoryImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  accountId: json['accountId'] as String,
  originalValue: (json['originalValue'] as num).toDouble(),
  budgetValue: (json['budgetValue'] as num).toDouble(),
);

Map<String, dynamic> _$$PlannerCategoryImplToJson(
  _$PlannerCategoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'accountId': instance.accountId,
  'originalValue': instance.originalValue,
  'budgetValue': instance.budgetValue,
};
