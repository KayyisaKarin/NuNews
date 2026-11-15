import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/data/services/news_api_exception.dart';
import 'package:nu_news/providers/dependency_provider.dart';

enum AppNavDestination { feed, explore, bookmarks, settings }

class NewsState {
  const NewsState({
    this.articles = const [],
    this.extraArticles = const {},
    this.isLoading = true,
    this.isRefreshing = false,
    this.loadError,
    this.selectedCategory = 'semua',
    this.searchQuery = '',
    this.bookmarkedIds = const [],
    this.likedIds = const [],
    this.activeNav = AppNavDestination.feed,
  });

  final List<Article> articles;
  final Map<String, Article> extraArticles;
  final bool isLoading;
  final bool isRefreshing;
  final String? loadError;
  final String selectedCategory;
  final String searchQuery;
  final List<String> bookmarkedIds;
  final List<String> likedIds;
  final AppNavDestination activeNav;

  List<Article> get filteredArticles {
    return articles.where((article) {
      return selectedCategory == 'semua' ||
          article.categorySlug == selectedCategory;
    }).toList();
  }

  Article? get featuredArticle {
    final list = filteredArticles;
    if (list.isEmpty) return null;
    for (final item in list) {
      if (item.isFeatured) return item;
    }
    return list.first;
  }

  List<Article> get bookmarkedArticles {
    final Map<String, Article> byId = {};
    for (final item in articles) {
      byId[item.id] = item;
    }
    for (final entry in extraArticles.entries) {
      byId.putIfAbsent(entry.key, () => entry.value);
    }
    return bookmarkedIds
        .map((id) => byId[id])
        .whereType<Article>()
        .toList();
  }

  bool isBookmarked(String articleId) => bookmarkedIds.contains(articleId);

  bool isLiked(String articleId) => likedIds.contains(articleId);

  int likesFor(Article article) =>
      isLiked(article.id) ? article.likesCount + 1 : article.likesCount;

  NewsState copyWith({
    List<Article>? articles,
    Map<String, Article>? extraArticles,
    bool? isLoading,
    bool? isRefreshing,
    String? loadError,
    bool clearError = false,
    String? selectedCategory,
    String? searchQuery,
    List<String>? bookmarkedIds,
    List<String>? likedIds,
    AppNavDestination? activeNav,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      extraArticles: extraArticles ?? this.extraArticles,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      loadError: clearError ? null : (loadError ?? this.loadError),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      likedIds: likedIds ?? this.likedIds,
      activeNav: activeNav ?? this.activeNav,
    );
  }
}

class NewsNotifier extends Notifier<NewsState> {
  @override
  NewsState build() {
    final storage = ref.read(bookmarkStorageProvider);
    final savedIds = storage.getBookmarkedIds();
    final savedArticles = storage.getSavedArticles();
    final likedIds = storage.getLikedIds();

    final Map<String, Article> initialExtras = {
      for (final item in savedArticles) item.id: item,
    };

    Future.microtask(() => _loadCategory('semua', forceRefresh: false));

    return NewsState(
      extraArticles: initialExtras,
      bookmarkedIds: savedIds,
      likedIds: likedIds,
    );
  }

  void setActiveNav(AppNavDestination nav) {
    state = state.copyWith(activeNav: nav);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> setCategory(String categorySlug) async {
    if (state.selectedCategory == categorySlug) return;
    state = state.copyWith(selectedCategory: categorySlug);
    await _loadCategory(categorySlug, forceRefresh: false);
  }

  /// Manual pull-to-refresh triggered by user gesture in HomeScreen.
  Future<bool> refreshNews() async {
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 450));
    final loadFuture = _loadCategory(
      state.selectedCategory,
      forceRefresh: true,
      isManualRefresh: true,
    );
    final results = await Future.wait<Object?>([loadFuture, minDelay]);
    return results.first == true;
  }

  Future<bool> _loadCategory(
    String categorySlug, {
    required bool forceRefresh,
    bool isManualRefresh = false,
  }) async {
    state = state.copyWith(
      isLoading: isManualRefresh ? state.isLoading : true,
      isRefreshing: isManualRefresh,
      clearError: true,
    );

    try {
      final api = ref.read(newsApiServiceProvider);
      if (categorySlug == 'semua') {
        final all = await api.getAllArticles(forceRefresh: forceRefresh);
        state = state.copyWith(
          articles: all,
          isLoading: false,
          isRefreshing: false,
          loadError: all.isEmpty ? 'Tidak dapat memuat berita saat ini.' : null,
        );
        return all.isNotEmpty;
      } else {
        final catNews = await api.fetchCategoryNews(
          categorySlug,
          forceRefresh: forceRefresh,
        );
        final others = state.articles
            .where((a) => a.categorySlug != categorySlug)
            .toList();
        state = state.copyWith(
          articles: [...catNews, ...others],
          isLoading: false,
          isRefreshing: false,
          loadError: catNews.isEmpty
              ? 'Berita untuk kategori ini belum tersedia.'
              : null,
        );
        return catNews.isNotEmpty;
      }
    } on NewsApiException catch (err) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        loadError: err.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        loadError: 'Gagal terhubung ke server berita.',
      );
      return false;
    }
  }

  void registerArticles(List<Article> list) {
    if (list.isEmpty) return;
    final next = Map<String, Article>.from(state.extraArticles);
    var changed = false;
    for (final item in list) {
      if (!next.containsKey(item.id)) {
        next[item.id] = item;
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(extraArticles: next);
    }
  }

  /// Toggles bookmark for [article] and returns true if it is now saved.
  bool toggleBookmark(Article article) {
    final current = List<String>.from(state.bookmarkedIds);
    final isCurrentlySaved = current.contains(article.id);

    final updatedIds = isCurrentlySaved
        ? current.where((id) => id != article.id).toList()
        : [article.id, ...current];

    final nextExtras = Map<String, Article>.from(state.extraArticles)
      ..[article.id] = article;

    state = state.copyWith(
      bookmarkedIds: updatedIds,
      extraArticles: nextExtras,
    );

    final savedArticles = updatedIds
        .map((id) => nextExtras[id])
        .whereType<Article>()
        .toList();
    ref.read(bookmarkStorageProvider).saveBookmarks(updatedIds, savedArticles);

    return !isCurrentlySaved;
  }

  void toggleLike(String articleId) {
    final current = List<String>.from(state.likedIds);
    final updated = current.contains(articleId)
        ? current.where((id) => id != articleId).toList()
        : [...current, articleId];

    state = state.copyWith(likedIds: updated);
    ref.read(bookmarkStorageProvider).saveLikedIds(updated);
  }
}

final newsProvider = NotifierProvider<NewsNotifier, NewsState>(
  NewsNotifier.new,
);