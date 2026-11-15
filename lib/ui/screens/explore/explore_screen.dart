import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/constants/news_category.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/providers/dependency_provider.dart';
import 'package:nu_news/providers/news_provider.dart';
import 'package:nu_news/ui/widgets/article_tile.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({
    super.key,
    required this.onSelectArticle,
  });

  final void Function(Article article) onSelectArticle;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  bool _isKanalTab = false;
  String _selectedChannel = 'cnn';
  String _searchFilter = '';
  bool _loading = false;
  bool _hasLoadedOnce = false;
  String? _lastLoadedSlug;
  List<Article> _channelArticles = const [];

  static const _mediaChannels = [
    (id: 'cnn', name: 'CNN Indonesia', desc: 'Berita terpercaya & tajam'),
    (id: 'cnbc', name: 'CNBC Indonesia', desc: 'Pasar, ekonomi & investasi'),
    (id: 'antara', name: 'Antara News', desc: 'Kantor berita resmi nasional'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          ref.read(newsProvider).activeNav == AppNavDestination.explore) {
        _loadExploreData();
      }
    });
  }

  Future<void> _loadExploreData() async {
    if (!mounted) return;
    final selectedCategory = ref.read(newsProvider).selectedCategory;
    final targetSlug = _isKanalTab ? _selectedChannel : selectedCategory;

    setState(() {
      _loading = true;
      _hasLoadedOnce = true;
      _lastLoadedSlug = targetSlug;
    });

    try {
      final list =
          await ref.read(newsApiServiceProvider).fetchCategoryNews(targetSlug);
      if (!mounted) return;
      ref.read(newsProvider.notifier).registerArticles(list);
      setState(() {
        _channelArticles = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory =
        ref.watch(newsProvider.select((s) => s.selectedCategory));

    ref.listen<AppNavDestination>(
      newsProvider.select((s) => s.activeNav),
      (_, next) {
        if (next == AppNavDestination.explore) {
          final currentTarget =
              _isKanalTab ? _selectedChannel : ref.read(newsProvider).selectedCategory;
          if (!_hasLoadedOnce || _lastLoadedSlug != currentTarget) {
            _loadExploreData();
          }
        }
      },
    );

    final query = _searchFilter.trim().toLowerCase();
    final displayed = query.isEmpty
        ? _channelArticles
        : _channelArticles.where((a) {
            return a.title.toLowerCase().contains(query) ||
                a.summary.toLowerCase().contains(query) ||
                a.category.toLowerCase().contains(query);
          }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text(
          'Jelajahi Berita',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.slate900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Telusuri ratusan liputan terkini berdasarkan topik atau portal media',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.slate400 : AppTheme.slate500,
          ),
        ),
        const SizedBox(height: 14),

        // Search input (high dark-mode contrast)
        TextField(
          onChanged: (value) => setState(() => _searchFilter = value),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppTheme.slate100 : AppTheme.slate900,
          ),
          decoration: InputDecoration(
            hintText: 'Cari topik dalam jelajahi...',
            hintStyle: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.slate400,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppTheme.slate400,
            ),
            filled: true,
            fillColor: isDark ? AppTheme.slate800 : AppTheme.slate50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppTheme.slate700 : AppTheme.slate200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color:
                    isDark ? AppTheme.pastelYellowDarkText : AppTheme.slate900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Segmented switch: Kategori Topik vs Kanal Media
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.slate800 : AppTheme.slate100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  icon: Icons.layers_rounded,
                  label: 'Kategori Topik',
                  isSelected: !_isKanalTab,
                  onTap: () {
                    setState(() => _isKanalTab = false);
                    _loadExploreData();
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _SegmentButton(
                  icon: Icons.radio_rounded,
                  label: 'Kanal Media',
                  isSelected: _isKanalTab,
                  onTap: () {
                    setState(() => _isKanalTab = true);
                    _loadExploreData();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Grid with low-opacity dark-mode hover
        if (!_isKanalTab)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 66,
            ),
            itemCount: kNewsCategories.length,
            itemBuilder: (context, index) {
              final cat = kNewsCategories[index];
              final isSelected = selectedCategory == cat.slug;

              final bgColor = isSelected
                  ? (isDark ? Colors.white : AppTheme.slate900)
                  : (isDark
                      ? AppTheme.slate800.withAlpha(180)
                      : Colors.white);
              final textColor = isSelected
                  ? (isDark ? AppTheme.slate950 : Colors.white)
                  : (isDark ? AppTheme.slate200 : AppTheme.slate800);
              final borderColor = isSelected
                  ? (isDark ? Colors.white : AppTheme.slate900)
                  : (isDark ? AppTheme.slate800 : AppTheme.slate200);

              return Material(
                color: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderColor),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  hoverColor: isDark
                      ? (isSelected
                          ? Colors.white.withAlpha(215)
                          : AppTheme.slate800.withAlpha(102))
                      : (isSelected ? AppTheme.slate800 : AppTheme.slate50),
                  onTap: () {
                    ref.read(newsProvider.notifier).setCategory(cat.slug);
                    _loadExploreData();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppTheme.slate900.withAlpha(25)
                                    : Colors.white.withAlpha(45))
                                : (isDark
                                    ? AppTheme.slate700
                                    : AppTheme.slate100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cat.icon, size: 16, color: textColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Kategori',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? textColor.withAlpha(190)
                                      : AppTheme.slate400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _mediaChannels.map((ch) {
                final isSelected = _selectedChannel == ch.id;
                final bgColor = isSelected
                    ? (isDark ? Colors.white : AppTheme.slate900)
                    : (isDark
                        ? AppTheme.slate800.withAlpha(180)
                        : Colors.white);
                final textColor = isSelected
                    ? (isDark ? AppTheme.slate950 : Colors.white)
                    : (isDark ? AppTheme.slate200 : AppTheme.slate800);
                final borderColor = isSelected
                    ? (isDark ? Colors.white : AppTheme.slate900)
                    : (isDark ? AppTheme.slate800 : AppTheme.slate200);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: borderColor),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        hoverColor: isDark
                            ? (isSelected
                                ? Colors.white.withAlpha(215)
                                : AppTheme.slate800.withAlpha(102))
                            : (isSelected ? AppTheme.slate800 : AppTheme.slate50),
                        onTap: () {
                          setState(() => _selectedChannel = ch.id);
                          _loadExploreData();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ch.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ch.desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? textColor.withAlpha(190)
                                      : AppTheme.slate400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 18),

        // Articles Header + Pastel Yellow Count Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isKanalTab
                    ? 'Kanal: ${_mediaChannels.firstWhere((c) => c.id == _selectedChannel).name}'
                    : 'Berita Kategori: $selectedCategory',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.slate900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                '${displayed.length} artikel',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.pastelYellowDarkText
                      : AppTheme.pastelYellowLightText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 42),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (displayed.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 38),
            child: Center(
              child: Text(
                'Tidak ada berita yang ditemukan untuk kriteria ini.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.slate400),
              ),
            ),
          )
        else
          Column(
            children: displayed
                .map(
                  (article) => ArticleTile(
                    article: article,
                    onTap: () => widget.onSelectArticle(article),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isSelected
        ? (isDark ? Colors.white : AppTheme.slate900)
        : (isDark ? AppTheme.slate400 : AppTheme.slate700);

    return Material(
      color: isSelected
          ? (isDark ? AppTheme.slate900 : Colors.white)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
