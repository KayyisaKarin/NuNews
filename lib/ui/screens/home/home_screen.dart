import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/providers/news_provider.dart';
import 'package:nu_news/ui/screens/home/widgets/category_chips.dart';
import 'package:nu_news/ui/screens/home/widgets/featured_article_card.dart';
import 'package:nu_news/ui/widgets/article_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenBookmarks,
    required this.onSelectArticle,
    required this.onViewAllLatest,
  });

  final VoidCallback onOpenBookmarks;
  final void Function(Article article) onSelectArticle;
  final VoidCallback onViewAllLatest;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearchOpen = false;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final ok = await ref.read(newsProvider.notifier).refreshNews();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Berita terbaru berhasil diperbarui'
                : 'Gagal memperbarui berita',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(newsProvider);
    final filtered = state.filteredArticles;
    final featured = state.featuredArticle;
    final bookmarkCount = state.bookmarkedArticles.length;

    final queryTrimmed = state.searchQuery.trim().toLowerCase();
    final activeList = queryTrimmed.isEmpty
        ? filtered
        : filtered.where((a) {
            return a.title.toLowerCase().contains(queryTrimmed) ||
                a.summary.toLowerCase().contains(queryTrimmed) ||
                a.category.toLowerCase().contains(queryTrimmed) ||
                a.authorName.toLowerCase().contains(queryTrimmed);
          }).toList();

    final latestArticles = queryTrimmed.isEmpty && featured != null
        ? activeList.where((a) => a.id != featured.id).toList()
        : activeList;

    return RefreshIndicator(
      color: isDark ? AppTheme.pastelYellowDarkText : AppTheme.slate900,
      backgroundColor: isDark ? AppTheme.slate800 : AppTheme.pastelYellowLightBg,
      displacement: 48,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // 1. Header: NuNews + Newspaper icon (no background) + Search + Bookmark
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.newspaper_rounded,
                      size: 24,
                      color: isDark ? Colors.white : AppTheme.slate900,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NuNews',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : AppTheme.slate900,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Material(
                      color: _isSearchOpen
                          ? (isDark
                              ? AppTheme.pastelYellowDarkBg
                              : AppTheme.pastelYellowLightPill)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() => _isSearchOpen = !_isSearchOpen);
                          if (_isSearchOpen) {
                            _searchFocusNode.requestFocus();
                          } else {
                            _searchController.clear();
                            ref.read(newsProvider.notifier).setSearchQuery('');
                          }
                        },
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            _isSearchOpen
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            size: 21,
                            color: _isSearchOpen
                                ? (isDark
                                    ? AppTheme.pastelYellowDarkText
                                    : AppTheme.pastelYellowLightText)
                                : (isDark ? Colors.white : AppTheme.slate900),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Stack(
                      children: [
                        IconButton(
                          tooltip: 'Buka Markah Tersimpan',
                          onPressed: widget.onOpenBookmarks,
                          icon: Icon(
                            Icons.bookmark_border_rounded,
                            color: isDark ? Colors.white : AppTheme.slate900,
                          ),
                        ),
                        if (bookmarkCount > 0)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.rose500,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isDark ? AppTheme.slate900 : Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Inline Search Bar (high-contrast dark mode input)
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _isSearchOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? AppTheme.slate100 : AppTheme.slate900,
                          ),
                          onChanged: (value) {
                            ref
                                .read(newsProvider.notifier)
                                .setSearchQuery(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari berita terkini di sini...',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.slate400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppTheme.slate400,
                            ),
                            suffixIcon: state.searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                          .read(newsProvider.notifier)
                                          .setSearchQuery('');
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark
                                ? AppTheme.slate800
                                : AppTheme.slate100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppTheme.slate700
                                    : AppTheme.slate200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppTheme.pastelYellowDarkText
                                    : AppTheme.slate900,
                              ),
                            ),
                          ),
                        ),
                        if (queryTrimmed.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.pastelYellowDarkBg
                                  : AppTheme.pastelYellowLightBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.pastelYellowDarkBorder
                                    : AppTheme.pastelYellowLightBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Hasil: "${state.searchQuery}" (${activeList.length} artikel)',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppTheme.pastelYellowDarkText
                                          : AppTheme.pastelYellowLightText,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    ref
                                        .read(newsProvider.notifier)
                                        .setSearchQuery('');
                                    setState(() => _isSearchOpen = false);
                                  },
                                  child: Text(
                                    'Tutup',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      color: isDark
                                          ? AppTheme.pastelYellowDarkText
                                          : AppTheme.pastelYellowLightText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // // 3. Filter Tabs (Populer, Tren, Terkini)
          // const Padding(
          //   padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
          //   child: FeedFilterTabs(),
          // ),

          // // 4. Category Chips (hidden horizontal scrollbar)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: CategoryChips(),
          ),

          // 5. Loading / Error / Feed Content
          if (state.isLoading && filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.slate800 : AppTheme.slate200,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.slate800
                                  : AppTheme.slate200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 72,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.slate800
                                        : AppTheme.slate200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.slate800
                                        : AppTheme.slate200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          else if (state.loadError != null && filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  Text(
                    state.loadError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _handleRefresh,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.white : AppTheme.slate900,
                      foregroundColor:
                          isDark ? AppTheme.slate900 : Colors.white,
                    ),
                    child: const Text('Muat Ulang Berita'),
                  ),
                ],
              ),
            )
          else ...[
            if (queryTrimmed.isEmpty && filtered.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                child: FeaturedArticleCard(
                  articles: filtered,
                  onSelect: widget.onSelectArticle,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    queryTrimmed.isNotEmpty
                        ? 'Hasil Pencarian'
                        : 'Latest News',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.slate900,
                    ),
                  ),
                  if (queryTrimmed.isEmpty)
                    TextButton(
                      onPressed: widget.onViewAllLatest,
                      child: const Text(
                        'See more',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.rose500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (latestArticles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42),
                child: Center(
                  child: Text(
                    queryTrimmed.isNotEmpty
                        ? 'Tidak ada berita yang sesuai dengan kata kunci "${state.searchQuery}".'
                        : 'Belum ada berita lain pada kategori ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppTheme.slate500 : AppTheme.slate400,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: latestArticles
                      .map(
                        (article) => ArticleTile(
                          article: article,
                          onTap: () => widget.onSelectArticle(article),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
