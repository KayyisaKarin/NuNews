import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/providers/news_provider.dart';
import 'package:nu_news/providers/reader_settings_provider.dart';
import 'package:nu_news/ui/screens/detail/widgets/reader_customization_modal.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  final Article article;

  Future<void> _openSourceUrl(BuildContext context) async {
    final url = article.sourceUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan sumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reader = ref.watch(readerSettingsProvider);
    final bookmarked = ref.watch(
      newsProvider.select((s) => s.isBookmarked(article.id)),
    );
    final liked = ref.watch(
      newsProvider.select((s) => s.isLiked(article.id)),
    );
    final likesCount = ref.watch(
      newsProvider.select((s) => s.likesFor(article)),
    );

    final (Color canvasBg, Color textPrimary, Color textBody, Color borderCol) =
        switch (reader.themeColor) {
      ReaderThemeColor.sepia => (
          isDark ? const Color(0xFF1C180E) : AppTheme.pastelYellowLightBg,
          isDark ? AppTheme.pastelYellowDarkText : AppTheme.pastelYellowLightText,
          isDark ? AppTheme.pastelYellowDarkText : AppTheme.pastelYellowLightText,
          isDark ? const Color(0xFF42361C) : AppTheme.pastelYellowLightBorder,
        ),
      ReaderThemeColor.slate => (
          AppTheme.slate800,
          const Color(0xFFE2E8F0),
          const Color(0xFFE2E8F0),
          AppTheme.slate700,
        ),
      ReaderThemeColor.oled => (
          Colors.black,
          const Color(0xFFEDEDED),
          const Color(0xFFEDEDED),
          const Color(0xFF171717),
        ),
      ReaderThemeColor.white => (
          isDark ? AppTheme.slate900 : Colors.white,
          isDark ? Colors.white : AppTheme.slate900,
          isDark ? AppTheme.slate200 : AppTheme.slate800,
          isDark ? AppTheme.slate800 : AppTheme.slate200,
        ),
    };

    final isDarkCanvas =
        isDark ||
        reader.themeColor == ReaderThemeColor.slate ||
        reader.themeColor == ReaderThemeColor.oled;

    final rawContent = (article.content.trim().isNotEmpty
            ? article.content
            : article.summary)
        .trim();
    final firstLetter =
        rawContent.isNotEmpty ? rawContent.substring(0, 1) : '';
    final rest = rawContent.length > 1 ? rawContent.substring(1) : '';
    final paragraphs = rest.split('\n\n');
    final fontFamily =
        reader.fontStyle == ReaderFontStyle.serif ? 'serif' : null;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final topPadding = MediaQuery.paddingOf(context).top;
    final heroHeight = (screenWidth * 11 / 16).clamp(240.0, 340.0) + topPadding;

    return Scaffold(
      backgroundColor: canvasBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                // Hero Image
                SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      article.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: article.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Image.asset(
                                'assets/images/fallback_news.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/fallback_news.jpg',
                              fit: BoxFit.cover,
                            ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(110),
                              Colors.transparent,
                              Colors.black.withAlpha(155),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Overlapping Rounded Content Sheet
                Padding(
                  padding: EdgeInsets.only(top: heroHeight - 24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: canvasBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category pastel yellow pill + read time + published time
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
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
                                article.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppTheme.pastelYellowDarkText
                                      : AppTheme.pastelYellowLightText,
                                ),
                              ),
                            ),
                            Text(
                              '· ${article.readTimeMinutes} min read · ${article.publishedAt}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkCanvas
                                    ? AppTheme.slate400
                                    : AppTheme.slate500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Article Title
                        Text(
                          article.title,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: reader.fontSize * 1.45,
                            height: 1.32,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Author Pill + Like Button (low-opacity hover in dark screen)
                        Container(
                          padding: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: borderCol),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkCanvas
                                        ? AppTheme.slate800
                                        : AppTheme.slate900,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor:
                                            const Color(0xFFFCD34D),
                                        child: Text(
                                          article.authorName.isNotEmpty
                                              ? article.authorName[0]
                                                  .toUpperCase()
                                              : 'N',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.slate900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          article.authorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Material(
                                color: liked
                                    ? (isDarkCanvas
                                        ? const Color(0xFF4C0519)
                                            .withAlpha(130)
                                        : const Color(0xFFFFF1F2))
                                    : (isDarkCanvas
                                        ? AppTheme.slate800.withAlpha(180)
                                        : AppTheme.slate100),
                                shape: StadiumBorder(
                                  side: liked
                                      ? BorderSide(
                                          color: isDarkCanvas
                                              ? const Color(0xFF9F1239)
                                              : const Color(0xFFFECDD3),
                                        )
                                      : BorderSide.none,
                                ),
                                child: InkWell(
                                  customBorder: const StadiumBorder(),
                                  hoverColor: isDarkCanvas
                                      ? (liked
                                          ? const Color(0xFF4C0519)
                                              .withAlpha(75)
                                          : AppTheme.slate800.withAlpha(102))
                                      : (liked
                                          ? const Color(0xFFFFE4E6)
                                          : AppTheme.slate200),
                                  onTap: () => ref
                                      .read(newsProvider.notifier)
                                      .toggleLike(article.id),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          liked
                                              ? Icons.thumb_up_rounded
                                              : Icons.thumb_up_outlined,
                                          size: 16,
                                          color: liked
                                              ? AppTheme.rose500
                                              : (isDarkCanvas
                                                  ? AppTheme.slate200
                                                  : AppTheme.slate700),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$likesCount',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: liked
                                                ? AppTheme.rose500
                                                : (isDarkCanvas
                                                    ? AppTheme.slate200
                                                    : AppTheme.slate700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Drop Cap First Paragraph
                        if (paragraphs.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10,
                                    top: 2,
                                  ),
                                  child: Text(
                                    firstLetter,
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: 44,
                                      height: 0.9,
                                      fontWeight: FontWeight.w900,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    paragraphs.first,
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: reader.fontSize,
                                      height: 1.7,
                                      color: textBody,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Subsequent Paragraphs
                        for (final para in paragraphs.skip(1))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              para,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: reader.fontSize,
                                height: 1.7,
                                color: textBody,
                              ),
                            ),
                          ),

                        // Source Link CTA
                        if (article.sourceUrl != null &&
                            article.sourceUrl!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: borderCol),
                              ),
                            ),
                            child: Material(
                              color: isDark
                                  ? AppTheme.pastelYellowDarkBg
                                  : AppTheme.pastelYellowLightBg,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _openSourceUrl(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? AppTheme.pastelYellowDarkBorder
                                          : AppTheme.pastelYellowLightBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Baca Artikel Lengkap di Portal Asli',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppTheme.pastelYellowDarkText
                                              : AppTheme.pastelYellowLightText,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.open_in_new_rounded,
                                        size: 15,
                                        color: isDark
                                            ? AppTheme.pastelYellowDarkText
                                            : AppTheme.pastelYellowLightText,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pinned Top Floating Action Bar (Back, Bookmark, Aa, Share)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(175),
                    Colors.black.withAlpha(70),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleTopButton(
                        tooltip: 'Kembali',
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Row(
                        children: [
                          _CircleTopButton(
                            tooltip:
                                bookmarked ? 'Hapus Markah' : 'Simpan Markah',
                            onTap: () {
                              final saved = ref
                                  .read(newsProvider.notifier)
                                  .toggleBookmark(article);
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
                            child: Icon(
                              bookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color:
                                  bookmarked ? AppTheme.rose500 : Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CircleTopButton(
                            tooltip: 'Atur Tampilan Membaca',
                            onTap: () => ReaderCustomizationModal.show(context),
                            child: const Text(
                              'Aa',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CircleTopButton(
                            tooltip: 'Salin Tautan',
                            onTap: () async {
                              final shareTarget =
                                  article.sourceUrl ?? article.title;
                              await Clipboard.setData(
                                ClipboardData(text: shareTarget),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tautan artikel disalin ke papan klip',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                              }
                            },
                            child: const Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Brightness Dimming Overlay controlled by Reader Settings
          if (reader.brightnessOverlayOpacity > 0)
            IgnorePointer(
              child: Container(
                color: Colors.black.withAlpha(
                  (reader.brightnessOverlayOpacity * 255).round(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleTopButton extends StatelessWidget {
  const _CircleTopButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.slate900.withAlpha(160),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 40, height: 40, child: Center(child: child)),
        ),
      ),
    );
  }
}
