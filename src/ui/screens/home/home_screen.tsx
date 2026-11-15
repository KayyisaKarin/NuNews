/**
 * NuNews - Home Screen
 * Tampilan utama beranda berita dengan dukungan Pull-to-Refresh manual (touch & mouse drag)
 */

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Newspaper, Search, Bookmark, X, Sparkles, RefreshCw } from 'lucide-react';
import { useNews } from '../../../providers/news_provider';
import { FeedFilterTabs } from './widgets/feed_filter_tabs';
import { FeaturedArticleCard } from './widgets/featured_article_card';
import { CategoryChips } from './widgets/category_chips';
import { ArticleTile } from '../../widgets/article_tile';

interface HomeScreenProps {
  onOpenBookmarks: () => void;
  onSelectArticle: (id: string) => void;
  onViewAllLatest: () => void;
}

const PULL_THRESHOLD = 64;
const MAX_PULL_DISTANCE = 104;

export const HomeScreen: React.FC<HomeScreenProps> = ({
  onOpenBookmarks,
  onSelectArticle,
  onViewAllLatest,
}) => {
  const {
    featuredArticle,
    filteredArticles,
    bookmarkedArticles,
    isLoading,
    isRefreshing,
    loadError,
    refreshNews,
    searchQuery,
    setSearchQuery,
  } = useNews();

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const searchInputRef = useRef<HTMLInputElement>(null);

  // Pull-to-refresh state & gesture tracking
  const containerRef = useRef<HTMLDivElement>(null);
  const [pullDistance, setPullDistance] = useState(0);
  const [isPulling, setIsPulling] = useState(false);
  const startYRef = useRef<number | null>(null);
  const startXRef = useRef<number | null>(null);
  const dragLockedAxisRef = useRef<'y' | 'x' | null>(null);

  useEffect(() => {
    if (isSearchOpen) {
      searchInputRef.current?.focus();
    }
  }, [isSearchOpen]);

  const isScrollAtTop = useCallback(() => {
    const scrollParent = containerRef.current?.closest('.overflow-y-auto') as HTMLElement | null;
    return !scrollParent || scrollParent.scrollTop <= 1;
  }, []);

  const isInteractiveTarget = (target: EventTarget | null) => {
    if (!(target instanceof HTMLElement)) return false;
    return Boolean(target.closest('button, a, input, textarea, [data-no-pull="true"]'));
  };

  const finishPull = useCallback(
    async (currentPull: number) => {
      startYRef.current = null;
      startXRef.current = null;
      dragLockedAxisRef.current = null;
      setIsPulling(false);

      if (currentPull >= PULL_THRESHOLD && !isRefreshing) {
        setPullDistance(56);
        await refreshNews();
      }
      setPullDistance(0);
    },
    [isRefreshing, refreshNews]
  );

  // Touch handlers (Mobile / Touch Emulation)
  const handleTouchStart = (e: React.TouchEvent<HTMLDivElement>) => {
    if (isRefreshing || isInteractiveTarget(e.target) || !isScrollAtTop()) return;
    startYRef.current = e.touches[0].clientY;
    startXRef.current = e.touches[0].clientX;
    dragLockedAxisRef.current = null;
  };

  const handleTouchMove = (e: React.TouchEvent<HTMLDivElement>) => {
    if (startYRef.current === null || startXRef.current === null || isRefreshing) return;

    const dy = e.touches[0].clientY - startYRef.current;
    const dx = e.touches[0].clientX - startXRef.current;

    if (!dragLockedAxisRef.current && (Math.abs(dy) > 6 || Math.abs(dx) > 6)) {
      dragLockedAxisRef.current = Math.abs(dy) > Math.abs(dx) ? 'y' : 'x';
    }

    if (dragLockedAxisRef.current === 'x') return;

    if (dy > 8 && isScrollAtTop()) {
      setIsPulling(true);
      const damped = Math.min(MAX_PULL_DISTANCE, (dy - 8) * 0.48);
      setPullDistance(damped);
    } else if (dy <= 0) {
      setIsPulling(false);
      setPullDistance(0);
    }
  };

  const handleTouchEnd = () => {
    if (startYRef.current === null) return;
    void finishPull(pullDistance);
  };

  // Mouse drag handlers (Desktop preview ergonomics)
  const handleMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.button !== 0 || isRefreshing || isInteractiveTarget(e.target) || !isScrollAtTop()) {
      return;
    }
    startYRef.current = e.clientY;
    startXRef.current = e.clientX;
    dragLockedAxisRef.current = null;

    const onMouseMove = (moveEvent: MouseEvent) => {
      if (startYRef.current === null || startXRef.current === null) return;
      const dy = moveEvent.clientY - startYRef.current;
      const dx = moveEvent.clientX - startXRef.current;

      if (!dragLockedAxisRef.current && (Math.abs(dy) > 6 || Math.abs(dx) > 6)) {
        dragLockedAxisRef.current = Math.abs(dy) > Math.abs(dx) ? 'y' : 'x';
      }

      if (dragLockedAxisRef.current !== 'y') return;

      if (dy > 8 && isScrollAtTop()) {
        setIsPulling(true);
        const damped = Math.min(MAX_PULL_DISTANCE, (dy - 8) * 0.48);
        setPullDistance(damped);
      } else {
        setIsPulling(false);
        setPullDistance(0);
      }
    };

    const onMouseUp = (upEvent: MouseEvent) => {
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
      if (startYRef.current === null) return;
      const dy = upEvent.clientY - startYRef.current;
      const finalPull =
        dragLockedAxisRef.current === 'y' && dy > 8 && isScrollAtTop()
          ? Math.min(MAX_PULL_DISTANCE, (dy - 8) * 0.48)
          : 0;
      void finishPull(finalPull);
    };

    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);
  };

  const searchTrimmed = searchQuery.trim().toLowerCase();
  const activeList = searchTrimmed
    ? filteredArticles.filter(
        (a) =>
          a.title.toLowerCase().includes(searchTrimmed) ||
          a.summary.toLowerCase().includes(searchTrimmed) ||
          a.category.toLowerCase().includes(searchTrimmed) ||
          a.author.name.toLowerCase().includes(searchTrimmed)
      )
    : filteredArticles;

  const latestArticles = searchTrimmed
    ? activeList
    : activeList.filter((a) => a.id !== featuredArticle?.id);

  const handleClearSearch = () => {
    setSearchQuery('');
    setIsSearchOpen(false);
  };

  const indicatorHeight = isRefreshing ? 56 : pullDistance;
  const pullProgress = Math.min(1, pullDistance / PULL_THRESHOLD);
  const readyToRefresh = pullDistance >= PULL_THRESHOLD;

  return (
    <div
      ref={containerRef}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
      onTouchCancel={handleTouchEnd}
      onMouseDown={handleMouseDown}
      className="flex-1 pb-4 select-none sm:select-auto touch-pan-y"
    >
      {/* Pull-to-Refresh Animated Header Indicator */}
      <motion.div
        animate={{ height: indicatorHeight, opacity: indicatorHeight > 4 ? 1 : 0 }}
        transition={
          isPulling
            ? { duration: 0 }
            : { type: 'spring', stiffness: 360, damping: 32 }
        }
        className="overflow-hidden flex items-center justify-center px-5"
      >
        <div
          className={`flex items-center gap-2 rounded-full px-3.5 py-1.5 text-[11px] font-semibold border shadow-2xs transition-colors ${
            isRefreshing || readyToRefresh
              ? 'bg-amber-50 dark:bg-amber-950/60 border-amber-200/80 dark:border-amber-800/60 text-amber-900 dark:text-amber-200'
              : 'bg-slate-100 dark:bg-slate-800/80 border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300'
          }`}
        >
          <RefreshCw
            className={`h-3.5 w-3.5 transition-transform ${
              isRefreshing ? 'animate-spin' : ''
            }`}
            style={
              isRefreshing
                ? undefined
                : { transform: `rotate(${Math.round(pullProgress * 270)}deg)` }
            }
          />
          <span>
            {isRefreshing
              ? 'Memperbarui berita terkini...'
              : readyToRefresh
                ? 'Lepaskan untuk memperbarui'
                : 'Tarik ke bawah untuk segarkan'}
          </span>
        </div>
      </motion.div>

      {/* 1. Header (Brand with Newspaper logo + Search Toggle + Bookmark) */}
      <div className="flex items-center justify-between px-5 pt-3 pb-2">
        <div className="flex items-center gap-2 select-none">
          <Newspaper className="h-6 w-6 text-slate-900 dark:text-white stroke-[2.2]" />
          <span className="text-xl font-extrabold tracking-tight text-slate-900 dark:text-white">
            NuNews
          </span>
        </div>

        <div className="flex items-center gap-1">
          <button
            type="button"
            aria-label="Cari Berita di Beranda"
            onClick={() => {
              if (isSearchOpen && searchQuery) {
                setSearchQuery('');
              }
              setIsSearchOpen(!isSearchOpen);
            }}
            className={`flex h-10 w-10 items-center justify-center rounded-xl transition-colors ${
              isSearchOpen
                ? 'bg-amber-100 text-amber-900 dark:bg-amber-950/60 dark:text-amber-300'
                : 'text-slate-800 hover:bg-slate-100 dark:text-white dark:hover:bg-slate-800'
            }`}
          >
            {isSearchOpen ? <X className="h-5 w-5 stroke-[2]" /> : <Search className="h-5 w-5 stroke-[1.8]" />}
          </button>

          <button
            type="button"
            aria-label="Buka Markah Tersimpan"
            onClick={onOpenBookmarks}
            className="relative flex h-10 w-10 items-center justify-center rounded-xl text-slate-800 hover:bg-slate-100 dark:text-white dark:hover:bg-slate-800 transition-colors"
          >
            <Bookmark className="h-5 w-5 stroke-[1.8]" />
            {bookmarkedArticles.length > 0 && (
              <span className="absolute top-2 right-2 h-2 w-2 rounded-full bg-rose-500 ring-2 ring-white dark:ring-slate-900" />
            )}
          </button>
        </div>
      </div>

      {/* 2. Inline Home Screen Search Field */}
      <AnimatePresence>
        {isSearchOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.2 }}
            className="overflow-hidden px-5 pt-1 pb-3"
          >
            <div className="relative flex items-center">
              <Search className="absolute left-3.5 h-4 w-4 text-slate-400 dark:text-slate-400 pointer-events-none" />
              <input
                ref={searchInputRef}
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Cari berita terkini di sini..."
                className="w-full rounded-2xl bg-slate-100 dark:bg-slate-800 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-400 py-2.5 pl-10 pr-9 text-xs sm:text-sm border border-slate-200 dark:border-slate-700 focus:bg-white dark:focus:bg-slate-800 focus:border-slate-900 dark:focus:border-amber-300 focus:outline-none transition-colors"
              />
              {searchQuery && (
                <button
                  type="button"
                  aria-label="Hapus kata kunci"
                  onClick={() => setSearchQuery('')}
                  className="absolute right-3 rounded-full p-0.5 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
                >
                  <X className="h-4 w-4" />
                </button>
              )}
            </div>

            {searchTrimmed && (
              <div className="mt-2 flex items-center justify-between rounded-xl bg-amber-50 dark:bg-amber-950/40 border border-amber-200/80 dark:border-amber-800/60 px-3 py-1.5 text-xs text-amber-900 dark:text-amber-200">
                <div className="flex items-center gap-1.5">
                  <Sparkles className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
                  <span>
                    Hasil pencarian: <strong>&ldquo;{searchQuery}&rdquo;</strong> ({activeList.length} artikel)
                  </span>
                </div>
                <button
                  type="button"
                  onClick={handleClearSearch}
                  className="text-[11px] font-semibold underline text-amber-800 dark:text-amber-300 hover:opacity-80"
                >
                  Tutup
                </button>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      {/* 3. Filter Tabs (Popular, Trending, Recent) */}
      <div className="px-5 pt-1 pb-3">
        <FeedFilterTabs />
      </div>

      {/* 4. Category Scrolling Chips */}
      <div className="px-4 pb-4" data-no-pull="true">
        <CategoryChips />
      </div>

      {/* Loading / Error / Content */}
      {isLoading && filteredArticles.length === 0 ? (
        <div className="px-5 space-y-4">
          <div className="h-64 w-full rounded-3xl bg-slate-200/70 dark:bg-slate-800/70 animate-pulse" />
          <div className="space-y-3 pt-2">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center gap-4">
                <div className="h-20 w-20 rounded-2xl bg-slate-200/70 dark:bg-slate-800/70 animate-pulse shrink-0" />
                <div className="flex-1 space-y-2">
                  <div className="h-3 w-16 rounded bg-slate-200/70 dark:bg-slate-800/70 animate-pulse" />
                  <div className="h-4 w-full rounded bg-slate-200/70 dark:bg-slate-800/70 animate-pulse" />
                  <div className="h-3 w-24 rounded bg-slate-200/70 dark:bg-slate-800/70 animate-pulse" />
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : loadError && filteredArticles.length === 0 ? (
        <div className="px-5 py-14 text-center space-y-3">
          <p className="text-sm font-medium text-slate-600 dark:text-slate-400">{loadError}</p>
          <button
            type="button"
            onClick={() => {
              void refreshNews();
            }}
            className="rounded-xl bg-slate-900 dark:bg-white text-white dark:text-slate-900 px-4 py-2 text-xs font-bold hover:opacity-90 active:scale-95 transition-all"
          >
            Muat Ulang Berita
          </button>
        </div>
      ) : (
        <>
          {!searchTrimmed && filteredArticles.length > 0 && (
            <div className="px-5 pb-6">
              <FeaturedArticleCard
                articles={filteredArticles}
                onSelect={onSelectArticle}
              />
            </div>
          )}

          <div className="px-5">
            <div className="flex items-center justify-between pb-3">
              <h2 className="text-lg font-bold text-slate-900 dark:text-white">
                {searchTrimmed ? 'Hasil Pencarian' : 'Latest News'}
              </h2>
              {!searchTrimmed && (
                <button
                  type="button"
                  onClick={onViewAllLatest}
                  className="text-xs font-semibold text-rose-500 hover:text-rose-600 dark:text-rose-400 dark:hover:text-rose-300 transition-colors"
                >
                  See more
                </button>
              )}
            </div>

            {latestArticles.length === 0 ? (
              <div className="py-12 text-center text-slate-400 dark:text-slate-500 text-xs">
                {searchTrimmed
                  ? `Tidak ada berita yang sesuai dengan kata kunci "${searchQuery}".`
                  : 'Belum ada berita lain pada kategori ini.'}
              </div>
            ) : (
              <div className="space-y-1">
                {latestArticles.map((article) => (
                  <ArticleTile
                    key={article.id}
                    article={article}
                    onSelect={onSelectArticle}
                  />
                ))}
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
};
