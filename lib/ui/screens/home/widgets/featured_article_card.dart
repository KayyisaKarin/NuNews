import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/providers/news_provider.dart';

/// Interactive 3-dot featured news carousel card.
class FeaturedArticleCard extends ConsumerStatefulWidget {
  const FeaturedArticleCard({
    super.key,
    required this.articles,
    required this.onSelect,
  });

  final List<Article> articles;
  final void Function(Article article) onSelect;

  @override
  ConsumerState<FeaturedArticleCard> createState() =>
      _FeaturedArticleCardState();
}

class _FeaturedArticleCardState extends ConsumerState<FeaturedArticleCard> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _activeSlide = 0;

  List<Article> get _items => widget.articles.take(3).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant FeaturedArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activeSlide >= _items.length && _items.isNotEmpty) {
      _activeSlide = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || _items.length <= 1 || !_pageController.hasClients) return;
      final next = (_activeSlide + 1) % _items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = items[_activeSlide.clamp(0, items.length - 1)];
    final bookmarked = ref.watch(
      newsProvider.select((s) => s.isBookmarked(current.id)),
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.slate900 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.slate800 : AppTheme.slate200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 45 : 14),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => widget.onSelect(current),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: items.length,
                        onPageChanged: (idx) {
                          setState(() => _activeSlide = idx);
                        },
                        itemBuilder: (context, idx) {
                          final slide = items[idx];
                          return slide.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: slide.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: isDark
                                        ? AppTheme.slate800
                                        : AppTheme.slate200,
                                  ),
                                  errorWidget: (_, __, ___) => Image.asset(
                                    'assets/images/fallback_news.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/fallback_news.jpg',
                                  fit: BoxFit.cover,
                                );
                        },
                      ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppTheme.slate950.withAlpha(110),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.pastelYellowDarkBg.withAlpha(230)
                                : AppTheme.pastelYellowLightPill.withAlpha(235),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.pastelYellowDarkBorder
                                  : AppTheme.pastelYellowLightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Berita Utama #${_activeSlide + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppTheme.pastelYellowDarkText
                                      : AppTheme.pastelYellowLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Material(
                          color: AppTheme.slate900.withAlpha(225),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              final saved = ref
                                  .read(newsProvider.notifier)
                                  .toggleBookmark(current);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      saved
                                          ? 'Berita disimpan ke markah'
                                          : 'Dihapus dari markah',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                            },
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                bookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 20,
                                color: bookmarked
                                    ? AppTheme.rose500
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    isDark ? Colors.white : AppTheme.slate900,
                                child: Text(
                                  current.authorName.isNotEmpty
                                      ? current.authorName[0].toUpperCase()
                                      : 'N',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppTheme.slate900
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 140),
                                child: Text(
                                  current.authorName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.slate200
                                        : AppTheme.slate900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text('·'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: isDark
                                    ? AppTheme.slate400
                                    : AppTheme.slate500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${current.readTimeMinutes} min read',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppTheme.slate400
                                      : AppTheme.slate500,
                                ),
                              ),
                            ],
                          ),
                          const Text('·'),
                          Text(
                            current.category,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.rose500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (items.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (idx) {
                final isActive = _activeSlide == idx;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      idx,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isActive ? 28 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark ? Colors.white : AppTheme.slate900)
                          : (isDark ? AppTheme.slate700 : AppTheme.slate200),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
