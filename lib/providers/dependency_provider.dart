import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nu_news/data/services/bookmark_storage.dart';
import 'package:nu_news/data/services/news_api_service.dart';
import 'package:nu_news/data/services/theme_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

final newsApiServiceProvider = Provider<NewsApiService>((ref) {
  return NewsApiService();
});

final bookmarkStorageProvider = Provider<BookmarkStorage>((ref) {
  return BookmarkStorage(ref.watch(sharedPreferencesProvider));
});

final themeStorageProvider = Provider<ThemeStorage>((ref) {
  return ThemeStorage(ref.watch(sharedPreferencesProvider));
});
