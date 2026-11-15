import 'package:flutter/material.dart';

enum ReaderFontStyle { sans, serif }

enum ReaderThemeColor { white, sepia, slate, oled }

/// Immutable reading customization state ("Customize your view").
class ReaderSettings {
  const ReaderSettings({
    this.fontStyle = ReaderFontStyle.sans,
    this.fontSize = 16.0,
    this.brightness = 1.0,
    this.themeColor = ReaderThemeColor.white,
  });

  final ReaderFontStyle fontStyle;
  final double fontSize;
  final double brightness;
  final ReaderThemeColor themeColor;

  ReaderSettings copyWith({
    ReaderFontStyle? fontStyle,
    double? fontSize,
    double? brightness,
    ReaderThemeColor? themeColor,
  }) {
    return ReaderSettings(
      fontStyle: fontStyle ?? this.fontStyle,
      fontSize: fontSize ?? this.fontSize,
      brightness: brightness ?? this.brightness,
      themeColor: themeColor ?? this.themeColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'fontStyle': fontStyle.name,
        'fontSize': fontSize,
        'brightness': brightness,
        'themeColor': themeColor.name,
      };

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    final fontName = json['fontStyle'] as String?;
    final colorName = json['themeColor'] as String?;
    return ReaderSettings(
      fontStyle: ReaderFontStyle.values.firstWhere(
        (e) => e.name == fontName,
        orElse: () => ReaderFontStyle.sans,
      ),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 1.0,
      themeColor: ReaderThemeColor.values.firstWhere(
        (e) => e.name == colorName,
        orElse: () => ReaderThemeColor.white,
      ),
    );
  }

  double get brightnessOverlayOpacity =>
      ((1.0 - brightness) * 0.8).clamp(0.0, 0.5);
}

/// Application colors and Material 3 light/dark themes including pastel yellow sub-accents.
class AppTheme {
  AppTheme._();

  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);

  // Compatible Pastel Yellow Sub-Accent (Light & Dark)
  static const Color pastelYellowLightBg = Color(0xFFFEFCE8);
  static const Color pastelYellowLightPill = Color(0xFFFEF9C3);
  static const Color pastelYellowLightBorder = Color(0xFFFDE68A);
  static const Color pastelYellowLightText = Color(0xFF713F12);

  static const Color pastelYellowDarkBg = Color(0xFF28200D);
  static const Color pastelYellowDarkBorder = Color(0xFF785A18);
  static const Color pastelYellowDarkText = Color(0xFFFEF08A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: slate900,
        onPrimary: Colors.white,
        secondary: rose500,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: slate900,
        surfaceContainerHighest: slate100,
        outline: slate200,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: slate900,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: slate200,
      cardColor: Colors.white,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: slate900,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: slate900,
        secondary: rose500,
        onSecondary: Colors.white,
        surface: slate900,
        onSurface: Colors.white,
        surfaceContainerHighest: slate800,
        outline: slate700,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: slate900,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: slate800,
      cardColor: slate900,
    );
  }
}
