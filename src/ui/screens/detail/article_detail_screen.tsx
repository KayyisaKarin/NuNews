/**
 * NuNews - Article Detail Screen
 * Hero image, top bar (Back, Bookmark, "Aa", Share), author pill, like button, Drop Cap, dan tautan sumber asli.
 */

import React from 'react';
import { ArrowLeft, Bookmark, Share2, ThumbsUp, ExternalLink } from 'lucide-react';
import { Article } from '../../../data/models/article';
import { useNews } from '../../../providers/news_provider';
import { useReaderSettings } from '../../../providers/reader_settings_provider';
import fallbackNewsImg from '../../../assets/images/nusantara_modern_city_1794402739036.jpg';

interface ArticleDetailScreenProps {
  article: Article;
  onBack: () => void;
}

export const ArticleDetailScreen: React.FC<ArticleDetailScreenProps> = ({ article, onBack }) => {
  const { isBookmarked, toggleBookmark, isLiked, toggleLike, getArticleLikes, showToast } = useNews();
  const { openReaderModal, settings, canvasClasses, textClasses, brightnessOverlayOpacity } = useReaderSettings();

  const bookmarked = isBookmarked(article.id);
  const liked = isLiked(article.id);
  const likesCount = getArticleLikes(article);

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: article.title,
          text: article.summary,
          url: window.location.href,
        });
      } catch {
        // User cancelled share
      }
    } else {
      navigator.clipboard.writeText(window.location.href);
      showToast('Tautan artikel disalin ke papan klip');
    }
  };

  const firstLetter = article.content.charAt(0);
  const restOfContent = article.content.slice(1);

  return (
    <div className={`relative min-h-full pb-16 transition-colors duration-200 ${canvasClasses}`}>
      {brightnessOverlayOpacity > 0 && (
        <div
          className="pointer-events-none fixed inset-0 z-40 bg-black transition-opacity duration-300"
          style={{ opacity: brightnessOverlayOpacity }}
        />
      )}

      <div className="sticky top-0 z-30 flex items-center justify-between px-4 py-3 bg-gradient-to-b from-black/70 via-black/30 to-transparent">
        <button
          type="button"
          onClick={onBack}
          aria-label="Kembali ke Beranda"
          className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-900/60 text-white backdrop-blur-md transition-transform active:scale-90 hover:bg-slate-900/90"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>

        <div className="flex items-center gap-2">
          <button
            type="button"
            aria-label={bookmarked ? 'Hapus Markah' : 'Simpan Markah'}
            onClick={() => toggleBookmark(article.id)}
            className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-900/60 text-white backdrop-blur-md transition-transform active:scale-90 hover:bg-slate-900/90"
          >
            <Bookmark
              className={`h-5 w-5 ${bookmarked ? 'fill-rose-500 text-rose-500' : 'text-white'}`}
            />
          </button>

          <button
            type="button"
            aria-label="Atur Tampilan Membaca"
            onClick={openReaderModal}
            className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-900/60 text-white font-serif font-bold text-base backdrop-blur-md transition-transform active:scale-90 hover:bg-slate-900/90"
          >
            Aa
          </button>

          <button
            type="button"
            aria-label="Bagikan Berita"
            onClick={handleShare}
            className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-900/60 text-white backdrop-blur-md transition-transform active:scale-90 hover:bg-slate-900/90"
          >
            <Share2 className="h-5 w-5" />
          </button>
        </div>
      </div>

      <div className="-mt-16 relative aspect-16/11 w-full overflow-hidden bg-slate-200 dark:bg-slate-800">
        <img
          src={article.imageUrl}
          alt={article.title}
          referrerPolicy="no-referrer"
          className="h-full w-full object-cover"
          onError={(e) => {
            (e.target as HTMLImageElement).src = fallbackNewsImg;
          }}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
      </div>

      <div className="relative -mt-6 rounded-t-3xl bg-inherit px-5 pt-6 pb-12 shadow-lg">
        <div className="flex items-center gap-2 text-xs text-slate-500 dark:text-slate-400">
          <span className="rounded-full bg-amber-50 dark:bg-amber-950/50 text-amber-900 dark:text-amber-200 border border-amber-200/80 dark:border-amber-800/60 px-3 py-1 font-semibold shadow-2xs">
            {article.category}
          </span>
          <span>·</span>
          <span>{article.readTimeMinutes} min read</span>
          <span>·</span>
          <span>{article.publishedAt}</span>
        </div>

        <h1
          className={`mt-4 font-bold tracking-tight leading-snug ${
            settings.fontStyle === 'serif' ? 'font-serif' : 'font-sans'
          }`}
          style={{ fontSize: `${settings.fontSize * 1.5}px` }}
        >
          {article.title}
        </h1>

        <div className="mt-5 flex items-center justify-between gap-3 pb-5 border-b border-slate-200/60 dark:border-slate-800">
          <div className="flex items-center gap-2 rounded-full bg-slate-900 dark:bg-slate-800 text-white px-3.5 py-1.5 shadow-xs">
            {article.author.avatar ? (
              <img
                src={article.author.avatar}
                alt={article.author.name}
                referrerPolicy="no-referrer"
                className="h-5 w-5 rounded-full object-cover border border-slate-600"
                onError={(e) => {
                  (e.target as HTMLElement).style.display = 'none';
                }}
              />
            ) : (
              <div className="h-5 w-5 rounded-full bg-amber-300 text-slate-900 flex items-center justify-center text-[10px] font-bold">
                {article.author.name.charAt(0).toUpperCase()}
              </div>
            )}
            <span className="text-xs font-semibold">{article.author.name}</span>
          </div>

          <button
            type="button"
            onClick={() => toggleLike(article.id)}
            className={`flex items-center gap-1.5 rounded-full px-4 py-1.5 text-xs font-semibold transition-all active:scale-95 ${
              liked
                ? 'bg-rose-50 text-rose-600 hover:bg-rose-100 dark:bg-rose-950/50 dark:text-rose-400 dark:hover:bg-rose-950/30 border border-rose-200 dark:border-rose-800 shadow-xs'
                : 'bg-slate-100 text-slate-700 hover:bg-slate-200 dark:bg-slate-800/70 dark:text-slate-300 dark:hover:bg-slate-800/40'
            }`}
          >
            <ThumbsUp
              className={`h-4 w-4 ${liked ? 'fill-rose-500 text-rose-500' : ''}`}
            />
            <span>{likesCount}</span>
          </button>
        </div>

        <div
          className={`mt-6 leading-relaxed ${textClasses} ${
            settings.fontStyle === 'serif' ? 'font-serif' : 'font-sans'
          }`}
          style={{ fontSize: `${settings.fontSize}px`, lineHeight: 1.7 }}
        >
          <p className="mb-4">
            <span className="float-left mr-3 text-4xl sm:text-5xl font-extrabold leading-none select-none text-slate-900 dark:text-white">
              {firstLetter}
            </span>
            {restOfContent.split('\n\n')[0]}
          </p>

          {restOfContent
            .split('\n\n')
            .slice(1)
            .map((para, i) => (
              <p key={i} className="mb-4">
                {para}
              </p>
            ))}

          {article.sourceUrl && (
            <div className="mt-6 pt-4 border-t border-slate-200/60 dark:border-slate-800">
              <a
                href={article.sourceUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-2xl bg-amber-50 dark:bg-amber-950/50 border border-amber-200/80 dark:border-amber-800/60 px-4 py-2.5 text-xs font-bold text-amber-900 dark:text-amber-200 hover:opacity-90 transition-opacity"
              >
                <span>Baca Artikel Lengkap di Portal Asli</span>
                <ExternalLink className="h-3.5 w-3.5" />
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
