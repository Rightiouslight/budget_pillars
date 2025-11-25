// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThemeImpl _$$ThemeImplFromJson(Map<String, dynamic> json) => _$ThemeImpl(
  mode: json['mode'] as String? ?? 'system',
  primaryColor: json['primaryColor'] as String? ?? '#1976D2',
  accentColor: json['accentColor'] as String? ?? '#DC004E',
);

Map<String, dynamic> _$$ThemeImplToJson(_$ThemeImpl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'primaryColor': instance.primaryColor,
      'accentColor': instance.accentColor,
    };
