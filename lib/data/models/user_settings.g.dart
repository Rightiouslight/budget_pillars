// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      currency: json['currency'] == null
          ? null
          : Currency.fromJson(json['currency'] as Map<String, dynamic>),
      monthStartDate: (json['monthStartDate'] as num?)?.toInt() ?? 1,
      theme: json['theme'] == null
          ? null
          : Theme.fromJson(json['theme'] as Map<String, dynamic>),
      isCompactView: json['isCompactView'] as bool? ?? false,
      importProfiles:
          (json['importProfiles'] as List<dynamic>?)
              ?.map((e) => ImportProfile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      viewPreferences: json['viewPreferences'] == null
          ? null
          : ViewPreferences.fromJson(
              json['viewPreferences'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'monthStartDate': instance.monthStartDate,
      'theme': instance.theme,
      'isCompactView': instance.isCompactView,
      'importProfiles': instance.importProfiles,
      'viewPreferences': instance.viewPreferences,
    };
