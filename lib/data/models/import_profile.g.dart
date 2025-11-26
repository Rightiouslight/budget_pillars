// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ColumnMappingImpl _$$ColumnMappingImplFromJson(Map<String, dynamic> json) =>
    _$ColumnMappingImpl(
      date: json['date'] as String?,
      description: json['description'] as String?,
      amount: json['amount'] as String?,
    );

Map<String, dynamic> _$$ColumnMappingImplToJson(_$ColumnMappingImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'description': instance.description,
      'amount': instance.amount,
    };

_$ImportProfileImpl _$$ImportProfileImplFromJson(Map<String, dynamic> json) =>
    _$ImportProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      hasHeader: json['hasHeader'] as bool? ?? true,
      dateFormat: json['dateFormat'] as String? ?? 'M/d/yyyy',
      columnMapping: json['columnMapping'] == null
          ? const ColumnMapping()
          : ColumnMapping.fromJson(
              json['columnMapping'] as Map<String, dynamic>,
            ),
      columnCount: (json['columnCount'] as num?)?.toInt(),
      smsStartWords: json['smsStartWords'] as String? ?? '',
      smsStopWords: json['smsStopWords'] as String? ?? '',
    );

Map<String, dynamic> _$$ImportProfileImplToJson(_$ImportProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hasHeader': instance.hasHeader,
      'dateFormat': instance.dateFormat,
      'columnMapping': instance.columnMapping.toJson(),
      'columnCount': instance.columnCount,
      'smsStartWords': instance.smsStartWords,
      'smsStopWords': instance.smsStopWords,
    };
