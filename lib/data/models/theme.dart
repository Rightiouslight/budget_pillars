import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

@freezed
class Theme with _$Theme {
  const factory Theme({
    @Default('system') String appearance, // 'light', 'dark', 'black', 'system'
    @Default('mint') String name, // 'mint', 'oceanic', 'super'
  }) = _Theme;

  factory Theme.fromJson(Map<String, dynamic> json) => _$ThemeFromJson(json);
}
