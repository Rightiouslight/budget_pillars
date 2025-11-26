import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/app_theme.dart';
import '../providers/user_settings_provider.dart';

/// Provider that returns the current light theme based on user settings
final lightThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  final themeName = settings?.theme?.name ?? 'mint';

  return AppTheme.getTheme(themeName: themeName, appearance: 'light');
});

/// Provider that returns the current dark theme based on user settings
final darkThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  final themeName = settings?.theme?.name ?? 'mint';

  return AppTheme.getTheme(themeName: themeName, appearance: 'dark');
});

/// Provider that returns the current black theme based on user settings
final blackThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  final themeName = settings?.theme?.name ?? 'mint';

  return AppTheme.getTheme(themeName: themeName, appearance: 'black');
});

/// Provider that returns the current theme mode based on user settings
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  final appearance = settings?.theme?.appearance ?? 'system';

  switch (appearance) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
    case 'black':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
});

/// Provider that indicates if black theme should be used
/// (for dark mode when appearance is 'black')
final useBlackThemeProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  final appearance = settings?.theme?.appearance ?? 'system';
  return appearance == 'black';
});
