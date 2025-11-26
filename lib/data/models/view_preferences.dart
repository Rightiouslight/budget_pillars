import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_preferences.freezed.dart';
part 'view_preferences.g.dart';

@freezed
class ViewPreferences with _$ViewPreferences {
  const factory ViewPreferences({
    @Default('full') String mobile, // 'full' or 'compact'
    @Default('full') String desktop, // 'full' or 'compact'
  }) = _ViewPreferences;

  factory ViewPreferences.fromJson(Map<String, dynamic> json) =>
      _$ViewPreferencesFromJson(json);
}
