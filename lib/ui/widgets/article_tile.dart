import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/providers/news_provider.dart';

/// Shared horizontal news list tile used in Home, Explore, and Bookmarks.
class ArticleTile extends ConsumerWidget {
  const ArticleTile({
    super.key,
    required this.article,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarked = ref.watch(
      newsProvider.select((state) => state.isBookmarked(article.id)),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: isDark
            ? AppTheme.slate800.withAlpha(120)
            : AppTheme.slate100.withAlpha(160),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: article.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: article.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark ? AppTheme.slate800 : AppTheme.slate200,
                          ),
                          errorWidget: (_, __, ___) => Image.asset(
                            'assets/images/fallback_news.jpg',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/fallback_news.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.slate900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            article.publishedAt,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppTheme.slate500
                                  : AppTheme.slate400,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.slate500
                                  : AppTheme.slate400,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: isDark ? AppTheme.slate500 : AppTheme.slate400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readTimeMinutes} min read',
                          style: TextStyle(
                            fontSize: 11.5,
                            color:
                                isDark ? AppTheme.slate500 : AppTheme.slate400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: bookmarked ? 'Hapus dari markah' : 'Simpan ke markah',
                onPressed: () {
                  final saved =
                      ref.read(newsProvider.notifier).toggleBookmark(article);
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
                icon: Icon(
                  bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: bookmarked
                      ? AppTheme.rose500
                      : (isDark ? AppTheme.slate400 : AppTheme.slate500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
