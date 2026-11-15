/**
 * NuNews - Bookmarks Screen
 * Menampilkan daftar artikel yang disimpan oleh pengguna
 */

import React from 'react';
import { Bookmark, Sparkles } from 'lucide-react';
import { useNews } from '../../../providers/news_provider';
import { ArticleTile } from '../../widgets/article_tile';

interface BookmarksScreenProps {
  onSelectArticle: (id: string) => void;
  onExplore: () => void;
}

export const BookmarksScreen: React.FC<BookmarksScreenProps> = ({
  onSelectArticle,
  onExplore,
}) => {
  const { bookmarkedArticles } = useNews();

  return (
    <div className="px-4 py-3">
      <div className="mb-4 flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-slate-900 dark:text-white">
            Artikel Tersimpan
          </h2>
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
            Koleksi bacaan favorit yang Anda simpan
          </p>
        </div>
        {bookmarkedArticles.length > 0 && (
          <span className="text-xs font-semibold bg-amber-50 dark:bg-amber-950/50 text-amber-900 dark:text-amber-200 border border-amber-200/80 dark:border-amber-800/60 px-3 py-1 rounded-full">
            {bookmarkedArticles.length} tersimpan
          </span>
        )}
      </div>

      {bookmarkedArticles.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-3xl bg-slate-100 text-slate-400 dark:bg-slate-800 dark:text-slate-500">
            <Bookmark className="h-8 w-8 stroke-[1.5]" />
          </div>
          <h3 className="mt-4 text-base font-bold text-slate-800 dark:text-slate-200">
            Belum ada markah tersimpan
          </h3>
          <p className="mt-1 text-xs text-slate-500 max-w-xs">
            Tekan ikon markah pada kartu berita mana saja untuk menyimpannya ke daftar bacaan pribadi Anda.
          </p>
          <button
            type="button"
            onClick={onExplore}
            className="mt-5 flex items-center gap-2 rounded-2xl bg-slate-900 px-5 py-2.5 text-xs font-bold text-white shadow-sm dark:bg-white dark:text-slate-900 hover:opacity-90 active:scale-95 transition-all"
          >
            <Sparkles className="h-4 w-4" />
            <span>Mulai Jelajahi Berita</span>
          </button>
        </div>
      ) : (
        <div className="space-y-1">
          {bookmarkedArticles.map((article) => (
            <ArticleTile
              key={article.id}
              article={article}
              onSelect={onSelectArticle}
            />
          ))}
        </div>
      )}
    </div>
  );
};
