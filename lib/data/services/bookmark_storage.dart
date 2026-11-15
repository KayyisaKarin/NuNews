import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nu_news/data/models/article.dart';

/// NuNews - Local Bookmark & Likes Persistence
class BookmarkStorage {
  BookmarkStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _bookmarksKey = 'nunews_saved_bookmarks_v1';
  static const String _bookmarkArticlesKey = 'nunews_saved_bookmark_articles_v1';
  static const String _likedIdsKey = 'nunews_liked_articles_v1';

  List<String> getBookmarkedIds() {
    final raw = _prefs.getStringList(_bookmarksKey) ?? const [];
    return raw
        .where((id) => id != 'dumplings-art-1' && id != 'skincare-serum-2')
        .toList();
  }

  List<Article> getSavedArticles() {
    final raw = _prefs.getString(_bookmarkArticlesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBookmarks(List<String> ids, List<Article> articles) async {
    await _prefs.setStringList(_bookmarksKey, ids);
    final encoded = jsonEncode(articles.map((a) => a.toJson()).toList());
    await _prefs.setString(_bookmarkArticlesKey, encoded);
  }

  List<String> getLikedIds() {
    return _prefs.getStringList(_likedIdsKey) ?? const [];
  }

  Future<void> saveLikedIds(List<String> ids) async {
    await _prefs.setStringList(_likedIdsKey, ids);
  }
}
