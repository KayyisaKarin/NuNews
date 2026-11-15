import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/providers/dependency_provider.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.read(themeStorageProvider).getThemeMode();
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    ref.read(themeStorageProvider).saveThemeMode(mode);
  }

  void toggle(Brightness currentBrightness) {
    final next =
        currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }
}

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
