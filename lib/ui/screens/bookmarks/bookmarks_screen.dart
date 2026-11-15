import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/providers/news_provider.dart';
import 'package:nu_news/ui/widgets/article_tile.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({
    super.key,
    required this.onSelectArticle,
    required this.onExplore,
  });

  final void Function(Article article) onSelectArticle;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarkedArticles =
        ref.watch(newsProvider.select((s) => s.bookmarkedArticles));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artikel Tersimpan',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Koleksi bacaan favorit yang Anda simpan',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                  ),
                ),
              ],
            ),
            if (bookmarkedArticles.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.pastelYellowDarkBg
                      : AppTheme.pastelYellowLightBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.pastelYellowDarkBorder
                        : AppTheme.pastelYellowLightBorder,
                  ),
                ),
                child: Text(
                  '${bookmarkedArticles.length} tersimpan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.pastelYellowDarkText
                        : AppTheme.pastelYellowLightText,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (bookmarkedArticles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.slate800 : AppTheme.slate100,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    size: 32,
                    color: isDark ? AppTheme.slate500 : AppTheme.slate400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada markah tersimpan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.slate200 : AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tekan ikon markah pada kartu berita mana saja untuk menyimpannya ke daftar bacaan pribadi Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppTheme.slate400 : AppTheme.slate500,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onExplore,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : AppTheme.slate900,
                    foregroundColor: isDark ? AppTheme.slate900 : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text(
                    'Mulai Jelajahi Berita',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: bookmarkedArticles
                .map(
                  (article) => ArticleTile(
                    article: article,
                    onTap: () => onSelectArticle(article),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
