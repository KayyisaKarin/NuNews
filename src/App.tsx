/**
 * NuNews - Modern Indonesian News Application
 */

import React from 'react';
import { ThemeProvider } from './providers/theme_provider';
import { ReaderSettingsProvider } from './providers/reader_settings_provider';
import { NewsProvider, useNews } from './providers/news_provider';
import { MainShellScreen } from './ui/screens/main_shell/main_shell_screen';
import { HomeScreen } from './ui/screens/home/home_screen';
import { ArticleDetailScreen } from './ui/screens/detail/article_detail_screen';
import { ExploreScreen } from './ui/screens/explore/explore_screen';
import { BookmarksScreen } from './ui/screens/bookmarks/bookmarks_screen';
import { SettingsScreen } from './ui/screens/settings/settings_screen';
import { AppNavigationBar } from './ui/screens/main_shell/widgets/app_navigation_bar';

const NuNewsMain: React.FC = () => {
  const {
    activeNav,
    setActiveNav,
    selectedArticleId,
    openArticleDetail,
    closeArticleDetail,
    activeArticle,
  } = useNews();

  return (
    <MainShellScreen>
      {selectedArticleId && activeArticle ? (
        <ArticleDetailScreen
          article={activeArticle}
          onBack={closeArticleDetail}
        />
      ) : (
        <div className="flex flex-col flex-1">
          <main className="flex-1">
            {activeNav === 'feed' && (
              <HomeScreen
                onOpenBookmarks={() => setActiveNav('bookmarks')}
                onSelectArticle={openArticleDetail}
                onViewAllLatest={() => setActiveNav('explore')}
              />
            )}

            {activeNav === 'explore' && (
              <ExploreScreen onSelectArticle={openArticleDetail} />
            )}

            {activeNav === 'bookmarks' && (
              <BookmarksScreen
                onSelectArticle={openArticleDetail}
                onExplore={() => setActiveNav('feed')}
              />
            )}

            {activeNav === 'settings' && <SettingsScreen />}
          </main>

          <AppNavigationBar />
        </div>
      )}
    </MainShellScreen>
  );
};

export default function App() {
  return (
    <ThemeProvider>
      <ReaderSettingsProvider>
        <NewsProvider>
          <NuNewsMain />
        </NewsProvider>
      </ReaderSettingsProvider>
    </ThemeProvider>
  );
}
