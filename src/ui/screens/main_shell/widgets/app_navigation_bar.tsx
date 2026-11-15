/**
 * NuNews - Bottom Navigation Bar
 * Bar navigasi bawah mobile dengan haptic feedback visual dan badge markah
 */

import React from 'react';
import { Home, Compass, Bookmark, Settings } from 'lucide-react';
import { AppNavDestination, useNews } from '../../../../providers/news_provider';

interface NavItem {
  key: AppNavDestination;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
}

const NAV_ITEMS: NavItem[] = [
  { key: 'feed', label: 'Beranda', icon: Home },
  { key: 'explore', label: 'Jelajahi', icon: Compass },
  { key: 'bookmarks', label: 'Markah', icon: Bookmark },
  { key: 'settings', label: 'Pengaturan', icon: Settings },
];

export const AppNavigationBar: React.FC = () => {
  const { activeNav, setActiveNav, bookmarkedArticles } = useNews();

  return (
    <nav className="sticky bottom-0 z-30 w-full border-t border-slate-200/80 bg-white/95 backdrop-blur-md dark:border-slate-800 dark:bg-slate-900/95 pb-safe">
      <div className="grid grid-cols-4 items-center h-16 max-w-lg mx-auto">
        {NAV_ITEMS.map((item) => {
          const isActive = activeNav === item.key;
          const Icon = item.icon;
          return (
            <button
              key={item.key}
              type="button"
              onClick={() => setActiveNav(item.key)}
              className={`relative flex flex-col items-center justify-center py-1 transition-all duration-200 active:scale-90 ${
                isActive
                  ? 'text-slate-900 dark:text-white font-bold'
                  : 'text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-slate-300 font-medium'
              }`}
            >
              <div className="relative">
                <Icon
                  className={`h-5 w-5 transition-transform ${
                    isActive ? 'scale-110 stroke-[2.2]' : 'stroke-[1.6]'
                  }`}
                />
                {item.key === 'bookmarks' && bookmarkedArticles.length > 0 && (
                  <span className="absolute -top-1 -right-2 flex h-4 min-w-[16px] items-center justify-center rounded-full bg-rose-500 px-1 text-[9px] font-bold text-white shadow-xs">
                    {bookmarkedArticles.length}
                  </span>
                )}
              </div>
              <span className="mt-1 text-[10px] tracking-tight">{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
