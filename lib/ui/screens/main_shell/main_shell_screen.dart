import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/providers/news_provider.dart';
import 'package:nu_news/ui/screens/bookmarks/bookmarks_screen.dart';
import 'package:nu_news/ui/screens/detail/article_detail_screen.dart';
import 'package:nu_news/ui/screens/explore/explore_screen.dart';
import 'package:nu_news/ui/screens/home/home_screen.dart';
import 'package:nu_news/ui/screens/main_shell/widgets/app_navigation_bar.dart';
import 'package:nu_news/ui/screens/settings/settings_screen.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  void _openDetail(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNav = ref.watch(newsProvider.select((s) => s.activeNav));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: activeNav.index,
          children: [
            HomeScreen(
              onOpenBookmarks: () => ref
                  .read(newsProvider.notifier)
                  .setActiveNav(AppNavDestination.bookmarks),
              onSelectArticle: (article) => _openDetail(context, article),
              onViewAllLatest: () => ref
                  .read(newsProvider.notifier)
                  .setActiveNav(AppNavDestination.explore),
            ),
            ExploreScreen(
              onSelectArticle: (article) => _openDetail(context, article),
            ),
            BookmarksScreen(
              onSelectArticle: (article) => _openDetail(context, article),
              onExplore: () => ref
                  .read(newsProvider.notifier)
                  .setActiveNav(AppNavDestination.feed),
            ),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(),
    );
  }
}
