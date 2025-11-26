import 'package:flutter/material.dart';

/// HSL to Color conversion helper
Color hslToColor(int h, int s, int l, [double opacity = 1.0]) {
  final hue = h / 360;
  final saturation = s / 100;
  final lightness = l / 100;

  double r, g, b;

  if (saturation == 0) {
    r = g = b = lightness;
  } else {
    double hue2rgb(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }

    final q = lightness < 0.5
        ? lightness * (1 + saturation)
        : lightness + saturation - lightness * saturation;
    final p = 2 * lightness - q;

    r = hue2rgb(p, q, hue + 1 / 3);
    g = hue2rgb(p, q, hue);
    b = hue2rgb(p, q, hue - 1 / 3);
  }

  return Color.fromRGBO(
    (r * 255).round(),
    (g * 255).round(),
    (b * 255).round(),
    opacity,
  );
}

class AppTheme {
  // Mint Theme Colors (Default)
  static final Color mintPrimary = hslToColor(166, 47, 65); // Soft Teal
  static final Color mintBackgroundLight = hslToColor(
    60,
    56,
    91,
  ); // Light Cream
  static final Color mintAccent = hslToColor(32, 63, 51); // Muted Orange

  // Oceanic Theme Colors
  static final Color oceanicPrimary = hslToColor(194, 88, 48); // Bright Blue
  static final Color oceanicBackgroundLight = hslToColor(
    251,
    20,
    92,
  ); // Cool Gray
  static final Color oceanicAccent = hslToColor(355, 71, 58); // Vibrant Red

  // Super Theme Colors
  static final Color superPrimary = hslToColor(355, 85, 55); // Strong Red
  static final Color superBackgroundLight = hslToColor(
    220,
    20,
    94,
  ); // Light Gray-Blue
  static final Color superAccent = hslToColor(210, 80, 60); // Sky Blue

  /// Get theme data based on theme name and appearance
  static ThemeData getTheme({
    required String themeName,
    required String appearance,
  }) {
    // Determine brightness
    Brightness brightness;

    switch (appearance) {
      case 'light':
        brightness = Brightness.light;
        break;
      case 'dark':
        brightness = Brightness.dark;
        break;
      case 'black':
        brightness = Brightness.dark;
        break;
      case 'system':
      default:
        // System will be handled by themeMode in the app
        brightness = Brightness.light;
        break;
    }

    // Get colors based on theme name
    Color primaryColor;
    Color accentColor;
    Color? lightBackground;

    switch (themeName) {
      case 'oceanic':
        primaryColor = oceanicPrimary;
        accentColor = oceanicAccent;
        lightBackground = oceanicBackgroundLight;
        break;
      case 'super':
        primaryColor = superPrimary;
        accentColor = superAccent;
        lightBackground = superBackgroundLight;
        break;
      case 'mint':
      default:
        primaryColor = mintPrimary;
        accentColor = mintAccent;
        lightBackground = mintBackgroundLight;
        break;
    }

    // Create color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      secondary: accentColor,
      surface: appearance == 'black'
          ? Colors.black
          : (brightness == Brightness.light ? lightBackground : null),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: appearance == 'black'
          ? Colors.black
          : colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: appearance == 'black' ? Colors.black : null,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: appearance == 'black'
            ? const Color(0xFF121212)
            : null, // Slightly lighter than pure black
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Convenience getters for common theme configurations
  static ThemeData get lightTheme =>
      getTheme(themeName: 'mint', appearance: 'light');

  static ThemeData get darkTheme =>
      getTheme(themeName: 'mint', appearance: 'dark');
}
