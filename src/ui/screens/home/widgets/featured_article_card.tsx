/**
 * NuNews - Featured News Carousel Card
 * Menampilkan berita utama dengan sistem carousel 3 titik interaktif & fungsional
 */

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Bookmark, Clock, ChevronLeft, ChevronRight } from 'lucide-react';
import { Article } from '../../../../data/models/article';
import { useNews } from '../../../../providers/news_provider';
import fallbackNewsImg from '../../../../assets/images/nusantara_modern_city_1794402739036.jpg';

interface FeaturedArticleCardProps {
  articles: Article[];
  onSelect: (articleId: string) => void;
}

export const FeaturedArticleCard: React.FC<FeaturedArticleCardProps> = ({ articles, onSelect }) => {
  const { isBookmarked, toggleBookmark } = useNews();
  const [activeSlide, setActiveSlide] = useState(0);

  const carouselItems = articles.slice(0, 3);
  const currentArticle = carouselItems[activeSlide] || carouselItems[0];
  const bookmarked = currentArticle ? isBookmarked(currentArticle.id) : false;

  useEffect(() => {
    if (carouselItems.length <= 1) return;
    const interval = setInterval(() => {
      setActiveSlide((prev) => (prev + 1) % carouselItems.length);
    }, 6000);
    return () => clearInterval(interval);
  }, [carouselItems.length]);

  if (!currentArticle) return null;

  const handlePrev = (e: React.MouseEvent) => {
    e.stopPropagation();
    setActiveSlide((prev) => (prev - 1 + carouselItems.length) % carouselItems.length);
  };

  const handleNext = (e: React.MouseEvent) => {
    e.stopPropagation();
    setActiveSlide((prev) => (prev + 1) % carouselItems.length);
  };

  return (
    <div className="w-full">
      <div
        onClick={() => onSelect(currentArticle.id)}
        className="group relative cursor-pointer overflow-hidden rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm transition-all duration-300 hover:shadow-md"
      >
        <div className="relative aspect-4/3 w-full overflow-hidden bg-slate-200 dark:bg-slate-800">
          <AnimatePresence mode="wait">
            <motion.img
              key={currentArticle.id}
              src={currentArticle.imageUrl}
              alt={currentArticle.title}
              referrerPolicy="no-referrer"
              initial={{ opacity: 0, scale: 1.05 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.35 }}
              className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
              onError={(e) => {
                (e.target as HTMLImageElement).src = fallbackNewsImg;
              }}
            />
          </AnimatePresence>

          <div className="absolute top-4 left-4 z-10 flex items-center gap-1.5 rounded-full bg-amber-100/90 dark:bg-amber-950/80 border border-amber-200/90 dark:border-amber-700/60 text-amber-900 dark:text-amber-200 px-3 py-1 text-[11px] font-bold tracking-tight backdrop-blur-md shadow-xs">
            <span className="h-1.5 w-1.5 rounded-full bg-amber-500 animate-pulse" />
            <span>Berita Utama #{activeSlide + 1}</span>
          </div>

          <button
            type="button"
            aria-label={bookmarked ? 'Hapus dari markah' : 'Simpan ke markah'}
            onClick={(e) => {
              e.stopPropagation();
              toggleBookmark(currentArticle.id);
            }}
            className="absolute top-4 right-4 z-10 flex h-10 w-10 items-center justify-center rounded-2xl bg-slate-900/90 text-white backdrop-blur-md shadow-lg transition-transform active:scale-90 hover:bg-slate-900"
          >
            <Bookmark
              className={`h-5 w-5 transition-colors ${
                bookmarked ? 'fill-rose-500 text-rose-500' : 'text-white'
              }`}
            />
          </button>

          {carouselItems.length > 1 && (
            <div className="absolute inset-y-0 left-0 right-0 flex items-center justify-between px-2 opacity-0 group-hover:opacity-100 transition-opacity">
              <button
                type="button"
                onClick={handlePrev}
                aria-label="Berita Utama Sebelumnya"
                className="h-8 w-8 rounded-full bg-black/40 text-white flex items-center justify-center hover:bg-black/70 backdrop-blur-xs transition-transform active:scale-90"
              >
                <ChevronLeft className="h-4 w-4" />
              </button>
              <button
                type="button"
                onClick={handleNext}
                aria-label="Berita Utama Selanjutnya"
                className="h-8 w-8 rounded-full bg-black/40 text-white flex items-center justify-center hover:bg-black/70 backdrop-blur-xs transition-transform active:scale-90"
              >
                <ChevronRight className="h-4 w-4" />
              </button>
            </div>
          )}

          <div className="absolute inset-0 bg-gradient-to-t from-slate-950/40 via-transparent to-transparent opacity-60 pointer-events-none" />
        </div>

        <div className="p-5 sm:p-6">
          <AnimatePresence mode="wait">
            <motion.h2
              key={currentArticle.id}
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -6 }}
              transition={{ duration: 0.25 }}
              className="text-xl sm:text-2xl font-bold tracking-tight text-slate-900 dark:text-white line-clamp-2 leading-snug group-hover:text-rose-600 dark:group-hover:text-rose-400 transition-colors"
            >
              {currentArticle.title}
            </motion.h2>
          </AnimatePresence>

          <div className="mt-4 flex items-center gap-3 text-xs sm:text-sm text-slate-600 dark:text-slate-400">
            <div className="flex items-center gap-2">
              {currentArticle.author.avatar ? (
                <img
                  src={currentArticle.author.avatar}
                  alt={currentArticle.author.name}
                  referrerPolicy="no-referrer"
                  className="h-6 w-6 rounded-full object-cover border border-slate-200 dark:border-slate-700"
                  onError={(e) => {
                    (e.target as HTMLElement).style.display = 'none';
                  }}
                />
              ) : (
                <div className="h-6 w-6 rounded-full bg-slate-900 dark:bg-white text-white dark:text-slate-900 flex items-center justify-center text-[10px] font-bold">
                  {currentArticle.author.name.charAt(0).toUpperCase()}
                </div>
              )}
              <span className="font-medium text-slate-900 dark:text-slate-200 truncate max-w-[120px]">
                {currentArticle.author.name}
              </span>
            </div>

            <span className="text-slate-400 dark:text-slate-600">·</span>

            <div className="flex items-center gap-1">
              <Clock className="h-3.5 w-3.5 text-slate-400" />
              <span>{currentArticle.readTimeMinutes} min read</span>
            </div>

            <span className="text-slate-400 dark:text-slate-600">·</span>

            <span className="font-semibold text-rose-500 dark:text-rose-400">
              {currentArticle.category}
            </span>
          </div>
        </div>
      </div>

      {carouselItems.length > 1 && (
        <div className="mt-3 flex items-center justify-center gap-2 py-1 select-none">
          {carouselItems.map((item, idx) => {
            const isActive = activeSlide === idx;
            return (
              <button
                key={item.id}
                type="button"
                aria-label={`Pilih Berita Utama ${idx + 1}`}
                onClick={(e) => {
                  e.stopPropagation();
                  setActiveSlide(idx);
                }}
                className={`transition-all duration-300 rounded-full cursor-pointer h-2 ${
                  isActive
                    ? 'w-7 bg-slate-900 dark:bg-white shadow-xs'
                    : 'w-2 bg-slate-300 hover:bg-slate-400 dark:bg-slate-700 dark:hover:bg-slate-600'
                }`}
              />
            );
          })}
        </div>
      )}
    </div>
  );
};
