/**
 * NuNews - News Provider (State Management)
 * Mengelola state feed berita, kategori, filter tab, markah, suka, pencarian, dan notifikasi toast.
 */

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { Article } from '../data/models/article';
import { NewsApiService } from '../data/services/news_api_service';
import { BookmarkStorage } from '../data/services/bookmark_storage';

export type FeedFilterTab = 'popular' | 'trending' | 'recent';
export type AppNavDestination = 'feed' | 'explore' | 'bookmarks' | 'settings';

interface NewsContextType {
  // Articles Data
  articles: Article[];
  featuredArticle: Article | null;
  filteredArticles: Article[];
  isLoading: boolean;
  isRefreshing: boolean;
  loadError: string | null;
  refreshNews: () => Promise<void>;
  registerArticles: (list: Article[]) => void;

  // Navigation & Screen routing
  activeNav: AppNavDestination;
  setActiveNav: (nav: AppNavDestination) => void;
  selectedArticleId: string | null;
  openArticleDetail: (articleId: string) => void;
  closeArticleDetail: () => void;
  activeArticle: Article | null;

  // Feed Filters
  activeFilterTab: FeedFilterTab;
  setActiveFilterTab: (tab: FeedFilterTab) => void;
  selectedCategory: string;
  setSelectedCategory: (categorySlug: string) => void;

  // Bookmarks
  bookmarkedIds: string[];
  bookmarkedArticles: Article[];
  toggleBookmark: (articleId: string) => void;
  isBookmarked: (articleId: string) => boolean;

  // Likes
  likedIds: string[];
  toggleLike: (articleId: string) => void;
  isLiked: (articleId: string) => boolean;
  getArticleLikes: (article: Article) => number;

  // Search
  searchQuery: string;
  setSearchQuery: (q: string) => void;

  // Toast feedback
  toastMessage: string | null;
  showToast: (msg: string) => void;
}

const NewsContext = createContext<NewsContextType | undefined>(undefined);

export const NewsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [articles, setArticles] = useState<Article[]>([]);
  const [extraArticles, setExtraArticles] = useState<Record<string, Article>>({});
  const [featuredArticle, setFeaturedArticle] = useState<Article | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [activeNav, setActiveNav] = useState<AppNavDestination>('feed');
  const [selectedArticleId, setSelectedArticleId] = useState<string | null>(null);

  const [activeFilterTab, setActiveFilterTab] = useState<FeedFilterTab>('popular');
  const [selectedCategory, setSelectedCategory] = useState<string>('semua');

  const [bookmarkedIds, setBookmarkedIds] = useState<string[]>(() => BookmarkStorage.getBookmarks());
  const [likedIds, setLikedIds] = useState<string[]>(() => BookmarkStorage.getLikedArticles());

  const [searchQuery, setSearchQuery] = useState<string>('');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = useCallback((msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage((prev) => (prev === msg ? null : prev));
    }, 2500);
  }, []);

  // Shared loader for initial mount, category switch, and manual pull-to-refresh
  const loadCategoryFeed = useCallback(
    async (category: string, force: boolean, isManualRefresh = false) => {
      if (isManualRefresh) {
        setIsRefreshing(true);
      } else {
        setIsLoading(true);
      }
      setLoadError(null);

      try {
        if (category === 'semua') {
          const all = await NewsApiService.getAllArticles(force);
          setArticles(all);
          setFeaturedArticle(all.find((a) => a.isFeatured) || all[0] || null);
          if (all.length === 0) {
            setLoadError('Tidak dapat memuat berita saat ini.');
          } else if (isManualRefresh) {
            showToast('Berita terbaru berhasil diperbarui');
          }
        } else {
          const catNews = await NewsApiService.fetchCategoryNews(category, force);
          setArticles((prev) => {
            const others = prev.filter((a) => a.categorySlug !== category);
            return [...catNews, ...others];
          });
          if (catNews.length > 0) {
            setFeaturedArticle(catNews[0]);
            if (isManualRefresh) {
              showToast('Berita terbaru berhasil diperbarui');
            }
          } else {
            setLoadError('Berita untuk kategori ini belum tersedia.');
          }
        }
      } catch {
        setLoadError('Gagal terhubung ke server berita.');
        if (isManualRefresh) {
          showToast('Gagal memperbarui berita');
        }
      } finally {
        setIsLoading(false);
        setIsRefreshing(false);
      }
    },
    [showToast]
  );

  const refreshNews = useCallback(async () => {
    const minDelay = new Promise((resolve) => setTimeout(resolve, 450));
    await Promise.all([loadCategoryFeed(selectedCategory, true, true), minDelay]);
  }, [loadCategoryFeed, selectedCategory]);

  const registerArticles = useCallback((list: Article[]) => {
    if (!list.length) return;
    setExtraArticles((prev) => {
      const next = { ...prev };
      let changed = false;
      for (const item of list) {
        if (!next[item.id]) {
          next[item.id] = item;
          changed = true;
        }
      }
      return changed ? next : prev;
    });
  }, []);

  // Load articles when selectedCategory changes
  useEffect(() => {
    void loadCategoryFeed(selectedCategory, false, false);
  }, [selectedCategory, loadCategoryFeed]);

  // Bookmark actions
  const toggleBookmark = useCallback(
    (articleId: string) => {
      const updated = BookmarkStorage.toggleBookmark(articleId);
      setBookmarkedIds(updated);
      const wasBookmarked = updated.includes(articleId);
      showToast(wasBookmarked ? 'Berita disimpan ke markah' : 'Dihapus dari markah');
    },
    [showToast]
  );

  const isBookmarked = useCallback(
    (articleId: string) => bookmarkedIds.includes(articleId),
    [bookmarkedIds]
  );

  // Like actions
  const toggleLike = useCallback((articleId: string) => {
    const res = BookmarkStorage.toggleLike(articleId);
    setLikedIds(res.list);
  }, []);

  const isLiked = useCallback(
    (articleId: string) => likedIds.includes(articleId),
    [likedIds]
  );

  const getArticleLikes = useCallback(
    (article: Article) => {
      const userLiked = likedIds.includes(article.id);
      return userLiked ? article.likesCount + 1 : article.likesCount;
    },
    [likedIds]
  );

  // Article details navigation
  const openArticleDetail = useCallback((articleId: string) => {
    setSelectedArticleId(articleId);
  }, []);

  const closeArticleDetail = useCallback(() => {
    setSelectedArticleId(null);
  }, []);

  const activeArticle =
    articles.find((a) => a.id === selectedArticleId) ||
    (selectedArticleId ? extraArticles[selectedArticleId] || null : null);

  // Filtered articles based on Tab and Category
  const filteredArticles = articles.filter((article) => {
    if (selectedCategory !== 'semua' && article.categorySlug !== selectedCategory) {
      return false;
    }
    if (activeFilterTab === 'popular') {
      return article.isPopular || article.likesCount > 350;
    }
    if (activeFilterTab === 'trending') {
      return article.isTrending || article.commentsCount > 10;
    }
    return true;
  });

  const knownById = new Map<string, Article>();
  for (const item of articles) {
    knownById.set(item.id, item);
  }
  for (const item of Object.values(extraArticles)) {
    if (!knownById.has(item.id)) {
      knownById.set(item.id, item);
    }
  }

  const bookmarkedArticles = bookmarkedIds
    .map((id) => knownById.get(id))
    .filter((a): a is Article => Boolean(a));

  return (
    <NewsContext.Provider
      value={{
        articles,
        featuredArticle,
        filteredArticles,
        isLoading,
        isRefreshing,
        loadError,
        refreshNews,
        registerArticles,
        activeNav,
        setActiveNav,
        selectedArticleId,
        openArticleDetail,
        closeArticleDetail,
        activeArticle,
        activeFilterTab,
        setActiveFilterTab,
        selectedCategory,
        setSelectedCategory,
        bookmarkedIds,
        bookmarkedArticles,
        toggleBookmark,
        isBookmarked,
        likedIds,
        toggleLike,
        isLiked,
        getArticleLikes,
        searchQuery,
        setSearchQuery,
        toastMessage,
        showToast,
      }}
    >
      {children}
    </NewsContext.Provider>
  );
};

export const useNews = (): NewsContextType => {
  const context = useContext(NewsContext);
  if (!context) {
    throw new Error('useNews harus digunakan di dalam NewsProvider');
  }
  return context;
};
