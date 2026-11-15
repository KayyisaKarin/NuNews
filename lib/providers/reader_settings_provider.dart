import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/providers/dependency_provider.dart';

class ReaderSettingsNotifier extends Notifier<ReaderSettings> {
  @override
  ReaderSettings build() {
    return ref.read(themeStorageProvider).getReaderSettings();
  }

  void setFontStyle(ReaderFontStyle fontStyle) {
    state = state.copyWith(fontStyle: fontStyle);
    ref.read(themeStorageProvider).saveReaderSettings(state);
  }

  void setFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize);
    ref.read(themeStorageProvider).saveReaderSettings(state);
  }

  void setBrightness(double brightness) {
    state = state.copyWith(brightness: brightness);
    ref.read(themeStorageProvider).saveReaderSettings(state);
  }

  void setThemeColor(ReaderThemeColor themeColor) {
    state = state.copyWith(themeColor: themeColor);
    ref.read(themeStorageProvider).saveReaderSettings(state);
  }

  void reset() {
    state = const ReaderSettings();
    ref.read(themeStorageProvider).saveReaderSettings(state);
  }
}

final readerSettingsProvider =
    NotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
  ReaderSettingsNotifier.new,
);
