import 'package:freezed_annotation/freezed_annotation.dart';
import 'currency.dart';
import 'theme.dart';
import 'import_profile.dart';
import 'view_preferences.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    Currency? currency,
    @Default(1)
    int monthStartDate, // Day of month when budget period starts (1-28)
    Theme? theme,
    @Default(false)
    bool isCompactView, // Deprecated - use viewPreferences instead
    @Default([]) List<ImportProfile> importProfiles,
    ViewPreferences? viewPreferences,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
