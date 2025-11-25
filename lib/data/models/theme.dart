import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

@freezed
class Theme with _$Theme {
  const factory Theme({
    @Default('system') String mode, // 'light', 'dark', 'system'
    @Default('#1976D2') String primaryColor,
    @Default('#DC004E') String accentColor,
  }) = _Theme;

  factory Theme.fromJson(Map<String, dynamic> json) => _$ThemeFromJson(json);
}
