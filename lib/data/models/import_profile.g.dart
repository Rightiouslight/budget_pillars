// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImportProfileImpl _$$ImportProfileImplFromJson(Map<String, dynamic> json) =>
    _$ImportProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'csv',
      columnMapping: json['columnMapping'] as Map<String, dynamic>? ?? const {},
      regex: json['regex'] as String?,
      categoryMappings:
          (json['categoryMappings'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$$ImportProfileImplToJson(_$ImportProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'columnMapping': instance.columnMapping,
      'regex': instance.regex,
      'categoryMappings': instance.categoryMappings,
    };
