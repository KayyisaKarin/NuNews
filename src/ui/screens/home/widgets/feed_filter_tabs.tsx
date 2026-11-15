/**
 * NuNews - Feed Filter Tabs
 * Header filter tabs (Popular, Trending, Recent)
 */

import React from 'react';
import { motion } from 'motion/react';
import { FeedFilterTab, useNews } from '../../../../providers/news_provider';

interface FilterOption {
  key: FeedFilterTab;
  label: string;
  sublabel: string;
}

const TABS: FilterOption[] = [
  { key: 'popular', label: 'Populer', sublabel: 'Popular' },
  { key: 'trending', label: 'Tren', sublabel: 'Trending' },
  { key: 'recent', label: 'Terkini', sublabel: 'Recent' },
];

export const FeedFilterTabs: React.FC = () => {
  const { activeFilterTab, setActiveFilterTab } = useNews();

  return (
    <div className="flex items-center gap-6 border-b border-transparent pt-1 pb-2">
      {TABS.map((tab) => {
        const isActive = activeFilterTab === tab.key;
        return (
          <button
            key={tab.key}
            type="button"
            onClick={() => setActiveFilterTab(tab.key)}
            className={`relative py-1 text-base sm:text-lg font-bold transition-colors whitespace-nowrap ${
              isActive
                ? 'text-slate-900 dark:text-white'
                : 'text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-slate-300 font-medium'
            }`}
          >
            <span>{tab.label}</span>
            <span className="ml-1 text-xs opacity-60 font-normal hidden xs:inline">
              ({tab.sublabel})
            </span>

            {isActive && (
              <motion.div
                layoutId="activeFilterIndicator"
                className="absolute -bottom-1 left-0 right-0 h-0.5 rounded-full bg-slate-900 dark:bg-white"
                transition={{ type: 'spring', stiffness: 500, damping: 35 }}
              />
            )}
          </button>
        );
      })}
    </div>
  );
};
