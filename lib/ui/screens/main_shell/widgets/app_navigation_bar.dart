import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/providers/news_provider.dart';

class AppNavigationBar extends ConsumerWidget {
  const AppNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeNav = ref.watch(newsProvider.select((s) => s.activeNav));
    final bookmarkCount = ref.watch(
      newsProvider.select((s) => s.bookmarkedArticles.length),
    );

    const items = [
      (
        dest: AppNavDestination.feed,
        label: 'Beranda',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      (
        dest: AppNavDestination.explore,
        label: 'Jelajahi',
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
      ),
      (
        dest: AppNavDestination.bookmarks,
        label: 'Markah',
        icon: Icons.bookmark_border_rounded,
        activeIcon: Icons.bookmark_rounded,
      ),
      (
        dest: AppNavDestination.settings,
        label: 'Pengaturan',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.slate900.withAlpha(242)
            : Colors.white.withAlpha(242),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.slate800 : AppTheme.slate200,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.map((item) {
              final isActive = activeNav == item.dest;
              final color = isActive
                  ? (isDark ? Colors.white : AppTheme.slate900)
                  : (isDark ? AppTheme.slate500 : AppTheme.slate400);

              return Expanded(
                child: InkWell(
                  onTap: () {
                    ref.read(newsProvider.notifier).setActiveNav(item.dest);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 22,
                            color: color,
                          ),
                          if (item.dest == AppNavDestination.bookmarks &&
                              bookmarkCount > 0)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppTheme.rose500,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$bookmarkCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
