import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nu_news/core/theme/app_theme.dart';

/// NuNews - Local Theme & Reader Customization Persistence
class ThemeStorage {
  ThemeStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeKey = 'nunews_theme_mode_v1';
  static const String _readerSettingsKey = 'nunews_reader_settings_v1';

  ThemeMode getThemeMode() {
    final saved = _prefs.getString(_themeKey);
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    await _prefs.setString(_themeKey, value);
  }

  ReaderSettings getReaderSettings() {
    final raw = _prefs.getString(_readerSettingsKey);
    if (raw == null || raw.isEmpty) return const ReaderSettings();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ReaderSettings.fromJson(map);
    } catch (_) {
      return const ReaderSettings();
    }
  }

  Future<void> saveReaderSettings(ReaderSettings settings) async {
    await _prefs.setString(_readerSettingsKey, jsonEncode(settings.toJson()));
  }
}
