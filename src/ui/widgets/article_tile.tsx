/**
 * NuNews - Shared Article Tile Widget
 * Komponen kartu baris berita (Latest News / Berita Terkini) sesuai mockup
 */

import React from 'react';
import { Bookmark, Clock } from 'lucide-react';
import { Article } from '../../data/models/article';
import { useNews } from '../../providers/news_provider';
import fallbackNewsImg from '../../assets/images/nusantara_modern_city_1794402739036.jpg';

interface ArticleTileProps {
  article: Article;
  onSelect: (articleId: string) => void;
}

export const ArticleTile: React.FC<ArticleTileProps> = ({ article, onSelect }) => {
  const { isBookmarked, toggleBookmark } = useNews();
  const bookmarked = isBookmarked(article.id);

  return (
    <div
      onClick={() => onSelect(article.id)}
      className="group flex cursor-pointer items-center justify-between gap-4 rounded-2xl p-2.5 transition-colors hover:bg-slate-50 dark:hover:bg-slate-800/60"
    >
      {/* Left Rounded Thumbnail (matching mockup rounded image) */}
      <div className="relative h-20 w-20 sm:h-22 sm:w-22 shrink-0 overflow-hidden rounded-2xl bg-slate-200 dark:bg-slate-800">
        <img
          src={article.imageUrl}
          alt={article.title}
          referrerPolicy="no-referrer"
          className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
          onError={(e) => {
            (e.target as HTMLImageElement).src = fallbackNewsImg;
          }}
        />
      </div>

      {/* Center Details */}
      <div className="flex flex-1 flex-col justify-center min-w-0">
        <span className="text-xs font-semibold text-slate-500 dark:text-slate-400">
          {article.category}
        </span>

        <h3 className="mt-1 text-sm sm:text-base font-bold text-slate-900 dark:text-white line-clamp-2 leading-snug group-hover:text-rose-600 dark:group-hover:text-rose-400 transition-colors">
          {article.title}
        </h3>

        <div className="mt-1.5 flex items-center gap-2 text-xs text-slate-400 dark:text-slate-500">
          <span>{article.publishedAt}</span>
          <span>·</span>
          <div className="flex items-center gap-1">
            <Clock className="h-3 w-3" />
            <span>{article.readTimeMinutes} min read</span>
          </div>
        </div>
      </div>

      {/* Right Bookmark Action */}
      <button
        type="button"
        aria-label={bookmarked ? 'Hapus dari markah' : 'Simpan ke markah'}
        onClick={(e) => {
          e.stopPropagation();
          toggleBookmark(article.id);
        }}
        className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl text-slate-400 hover:text-slate-900 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
      >
        <Bookmark
          className={`h-5 w-5 transition-transform active:scale-75 ${
            bookmarked ? 'fill-rose-500 text-rose-500' : 'stroke-[1.75]'
          }`}
        />
      </button>
    </div>
  );
};
