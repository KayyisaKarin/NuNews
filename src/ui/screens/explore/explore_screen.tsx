/**
 * NuNews - Explore Screen (Jelajahi)
 * Jelajahi per Kategori & Kanal Media (CNN Indonesia, CNBC Indonesia, Antara News)
 */

import React, { useState, useEffect } from 'react';
import {
  Globe,
  Flag,
  TrendingUp,
  Trophy,
  Cpu,
  Film,
  Coffee,
  Search,
  Radio,
  Layers,
  Sparkles,
  Loader2,
} from 'lucide-react';
import { NEWS_CATEGORIES } from '../../../core/constants/news_category';
import { useNews } from '../../../providers/news_provider';
import { NewsApiService } from '../../../data/services/news_api_service';
import { Article } from '../../../data/models/article';
import { ArticleTile } from '../../widgets/article_tile';

interface ExploreScreenProps {
  onSelectArticle: (id: string) => void;
}

const CATEGORY_ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  semua: Sparkles,
  nasional: Flag,
  internasional: Globe,
  ekonomi: TrendingUp,
  olahraga: Trophy,
  teknologi: Cpu,
  hiburan: Film,
  'gaya-hidup': Coffee,
};

const MEDIA_CHANNELS = [
  { id: 'cnn', name: 'CNN Indonesia', slug: 'nasional', desc: 'Berita terpercaya & tajam' },
  { id: 'cnbc', name: 'CNBC Indonesia', slug: 'cnbc', desc: 'Pasar, ekonomi & investasi' },
  { id: 'antara', name: 'Antara News', slug: 'antara', desc: 'Kantor berita resmi nasional' },
];

export const ExploreScreen: React.FC<ExploreScreenProps> = ({ onSelectArticle }) => {
  const { selectedCategory, setSelectedCategory, registerArticles } = useNews();
  const [activeTab, setActiveTab] = useState<'kategori' | 'kanal'>('kategori');
  const [searchFilter, setSearchFilter] = useState('');
  const [channelArticles, setChannelArticles] = useState<Article[]>([]);
  const [selectedChannel, setSelectedChannel] = useState<string>('cnn');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let mounted = true;
    async function loadData() {
      setLoading(true);
      const targetSlug = activeTab === 'kategori' ? selectedCategory : selectedChannel;
      const list = await NewsApiService.fetchCategoryNews(targetSlug);
      if (mounted) {
        setChannelArticles(list);
        registerArticles(list);
        setLoading(false);
      }
    }
    loadData();
    return () => {
      mounted = false;
    };
  }, [activeTab, selectedCategory, selectedChannel, registerArticles]);

  const displayedArticles = channelArticles.filter((a) => {
    if (!searchFilter.trim()) return true;
    const q = searchFilter.toLowerCase();
    return (
      a.title.toLowerCase().includes(q) ||
      a.summary.toLowerCase().includes(q) ||
      a.category.toLowerCase().includes(q)
    );
  });

  return (
    <div className="flex-1 pb-6 px-4 pt-3 space-y-4">
      <div>
        <h2 className="text-xl font-extrabold text-slate-900 dark:text-white tracking-tight">
          Jelajahi Berita
        </h2>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
          Telusuri ratusan liputan terkini berdasarkan topik atau portal media
        </p>
      </div>

      <div className="relative">
        <Search className="absolute left-3.5 top-3 h-4 w-4 text-slate-400 dark:text-slate-400 pointer-events-none" />
        <input
          type="text"
          value={searchFilter}
          onChange={(e) => setSearchFilter(e.target.value)}
          placeholder="Cari topik dalam jelajahi..."
          className="w-full rounded-2xl border border-slate-200 bg-slate-50 py-2.5 pl-10 pr-4 text-xs text-slate-900 placeholder-slate-400 focus:border-slate-900 focus:bg-white dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100 dark:placeholder-slate-400 dark:focus:bg-slate-800 dark:focus:border-amber-300 dark:focus:text-white focus:outline-none transition-colors"
        />
      </div>

      <div className="grid grid-cols-2 gap-1 rounded-2xl bg-slate-100 p-1 dark:bg-slate-800">
        <button
          type="button"
          onClick={() => setActiveTab('kategori')}
          className={`flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'kategori'
              ? 'bg-white text-slate-900 shadow-xs dark:bg-slate-900 dark:text-white'
              : 'text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white'
          }`}
        >
          <Layers className="h-3.5 w-3.5" />
          <span>Kategori Topik</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab('kanal')}
          className={`flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'kanal'
              ? 'bg-white text-slate-900 shadow-xs dark:bg-slate-900 dark:text-white'
              : 'text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white'
          }`}
        >
          <Radio className="h-3.5 w-3.5" />
          <span>Kanal Media</span>
        </button>
      </div>

      {activeTab === 'kategori' ? (
        <div className="grid grid-cols-2 gap-2">
          {NEWS_CATEGORIES.map((cat) => {
            const isSelected = selectedCategory === cat.slug;
            const Icon = CATEGORY_ICONS[cat.slug] || Sparkles;
            return (
              <button
                key={cat.id}
                type="button"
                onClick={() => setSelectedCategory(cat.slug)}
                className={`flex items-center gap-2.5 p-3 rounded-2xl border text-left transition-all active:scale-95 ${
                  isSelected
                    ? 'border-slate-900 bg-slate-900 text-white hover:bg-slate-800 dark:border-white dark:bg-white dark:text-slate-950 dark:hover:bg-white/85 shadow-xs'
                    : 'border-slate-200 bg-white text-slate-800 hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-800/70 dark:text-slate-200 dark:hover:bg-slate-800/40'
                }`}
              >
                <div
                  className={`p-2 rounded-xl shrink-0 ${
                    isSelected
                      ? 'bg-white/20 text-white dark:bg-slate-900/10 dark:text-slate-900'
                      : 'bg-slate-100 dark:bg-slate-700 text-slate-700 dark:text-slate-300'
                  }`}
                >
                  <Icon className="h-4 w-4" />
                </div>
                <div className="min-w-0">
                  <span className="block text-xs font-bold truncate">{cat.name}</span>
                  <span
                    className={`block text-[10px] ${
                      isSelected ? 'opacity-80' : 'text-slate-400'
                    }`}
                  >
                    Kategori
                  </span>
                </div>
              </button>
            );
          })}
        </div>
      ) : (
        <div className="grid grid-cols-3 gap-2">
          {MEDIA_CHANNELS.map((ch) => {
            const isSelected = selectedChannel === ch.id;
            return (
              <button
                key={ch.id}
                type="button"
                onClick={() => setSelectedChannel(ch.id)}
                className={`flex flex-col p-3 rounded-2xl border text-left transition-all active:scale-95 ${
                  isSelected
                    ? 'border-slate-900 bg-slate-900 text-white hover:bg-slate-800 dark:border-white dark:bg-white dark:text-slate-950 dark:hover:bg-white/85 shadow-xs'
                    : 'border-slate-200 bg-white text-slate-800 hover:bg-slate-50 dark:border-slate-800 dark:bg-slate-800/70 dark:text-slate-200 dark:hover:bg-slate-800/40'
                }`}
              >
                <span className="text-xs font-bold truncate">{ch.name}</span>
                <span
                  className={`mt-1 text-[10px] line-clamp-2 leading-tight ${
                    isSelected ? 'opacity-80' : 'text-slate-400'
                  }`}
                >
                  {ch.desc}
                </span>
              </button>
            );
          })}
        </div>
      )}

      <div className="pt-2">
        <div className="flex items-center justify-between pb-3">
          <h3 className="text-sm font-bold text-slate-900 dark:text-white capitalize">
            {activeTab === 'kategori'
              ? `Berita Kategori: ${selectedCategory}`
              : `Kanal: ${
                  MEDIA_CHANNELS.find((c) => c.id === selectedChannel)?.name || selectedChannel
                }`}
          </h3>
          <span className="text-[11px] font-semibold bg-amber-50 dark:bg-amber-950/50 text-amber-900 dark:text-amber-200 border border-amber-200/80 dark:border-amber-800/60 px-2.5 py-0.5 rounded-full">
            {displayedArticles.length} artikel
          </span>
        </div>

        {loading ? (
          <div className="flex flex-col items-center justify-center py-12 text-slate-400 gap-2">
            <Loader2 className="h-6 w-6 animate-spin text-slate-700 dark:text-slate-300" />
            <span className="text-xs">Memuat berita dari API...</span>
          </div>
        ) : displayedArticles.length === 0 ? (
          <div className="py-10 text-center text-xs text-slate-400">
            Tidak ada berita yang ditemukan untuk kriteria ini.
          </div>
        ) : (
          <div className="space-y-1">
            {displayedArticles.map((article) => (
              <ArticleTile
                key={article.id}
                article={article}
                onSelect={onSelectArticle}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
