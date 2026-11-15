/**
 * NuNews - Category Chips
 * Kategori: Semua, Nasional, Internasional, Ekonomi, Olahraga, Teknologi, Hiburan, Gaya Hidup
 */

import React from 'react';
import { Check } from 'lucide-react';
import { NEWS_CATEGORIES } from '../../../../core/constants/news_category';
import { useNews } from '../../../../providers/news_provider';

export const CategoryChips: React.FC = () => {
  const { selectedCategory, setSelectedCategory } = useNews();

  return (
    <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-1 px-1 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
      {NEWS_CATEGORIES.map((cat) => {
        const isSelected = selectedCategory === cat.slug;
        return (
          <button
            key={cat.id}
            type="button"
            onClick={() => setSelectedCategory(cat.slug)}
            className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all duration-200 active:scale-95 border ${
              isSelected
                ? 'bg-slate-900 border-slate-900 text-white dark:bg-white dark:border-white dark:text-slate-900 shadow-xs'
                : 'bg-white border-slate-200/90 text-slate-700 hover:bg-slate-50 dark:bg-slate-800/80 dark:border-slate-700 dark:text-slate-200 dark:hover:bg-slate-800'
            }`}
          >
            {isSelected && <Check className="h-3 w-3 stroke-[3]" />}
            <span>{cat.name}</span>
          </button>
        );
      })}
    </div>
  );
};
