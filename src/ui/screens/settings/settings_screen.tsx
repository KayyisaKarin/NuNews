/**
 * NuNews - Settings Screen
 * Halaman pengaturan aplikasi: tema gelap/terang, preferensi bacaan, informasi lisensi
 */

import React from 'react';
import { Moon, Sun, Type, RotateCcw, Globe, ShieldCheck } from 'lucide-react';
import { useTheme } from '../../../providers/theme_provider';
import { useReaderSettings } from '../../../providers/reader_settings_provider';
import { useNews } from '../../../providers/news_provider';

export const SettingsScreen: React.FC = () => {
  const { theme, setTheme } = useTheme();
  const { resetSettings, settings } = useReaderSettings();
  const { showToast } = useNews();

  const handleReset = () => {
    resetSettings();
    showToast('Pengaturan pembaca dikembalikan ke default');
  };

  return (
    <div className="px-4 py-4 space-y-6">
      <div>
        <h2 className="text-xl font-bold text-slate-900 dark:text-white">Pengaturan</h2>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
          Kelola tema aplikasi, preferensi membaca, dan data
        </p>
      </div>

      <div className="rounded-3xl bg-white p-5 shadow-xs border border-slate-200/80 dark:bg-slate-900 dark:border-slate-800">
        <h3 className="text-sm font-bold text-slate-900 dark:text-white mb-3">
          Tampilan & Tema
        </h3>
        <div className="grid grid-cols-2 gap-3">
          <button
            type="button"
            onClick={() => setTheme('light')}
            className={`flex items-center justify-center gap-2 py-3 px-4 rounded-2xl border text-xs font-bold transition-all ${
              theme === 'light'
                ? 'border-slate-900 bg-slate-900 text-white shadow-xs'
                : 'border-slate-200 bg-slate-50 text-slate-700 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-800/70 dark:text-slate-300 dark:hover:bg-slate-800/40'
            }`}
          >
            <Sun className="h-4 w-4" />
            <span>Mode Terang</span>
          </button>

          <button
            type="button"
            onClick={() => setTheme('dark')}
            className={`flex items-center justify-center gap-2 py-3 px-4 rounded-2xl border text-xs font-bold transition-all ${
              theme === 'dark'
                ? 'border-white bg-white text-slate-900 shadow-xs'
                : 'border-slate-200 bg-slate-50 text-slate-700 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-800/70 dark:text-slate-300 dark:hover:bg-slate-800/40'
            }`}
          >
            <Moon className="h-4 w-4" />
            <span>Mode Gelap</span>
          </button>
        </div>
      </div>

      <div className="rounded-3xl bg-white p-5 shadow-xs border border-slate-200/80 dark:bg-slate-900 dark:border-slate-800">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Type className="h-4 w-4 text-slate-500" />
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">
              Status Pembaca (Customize View)
            </h3>
          </div>
          <button
            type="button"
            onClick={handleReset}
            className="flex items-center gap-1 text-[11px] font-semibold text-rose-500 hover:text-rose-600"
          >
            <RotateCcw className="h-3 w-3" />
            Reset
          </button>
        </div>

        <div className="grid grid-cols-2 gap-2 text-xs text-slate-600 dark:text-slate-400">
          <div className="rounded-xl bg-slate-50 dark:bg-slate-800/60 p-2.5">
            <span className="text-[10px] uppercase text-slate-400">Font</span>
            <p className="font-bold text-slate-900 dark:text-white capitalize">
              {settings.fontStyle} ({settings.fontSize}px)
            </p>
          </div>
          <div className="rounded-xl bg-slate-50 dark:bg-slate-800/60 p-2.5">
            <span className="text-[10px] uppercase text-slate-400">Tema Bacaan</span>
            <p className="font-bold text-slate-900 dark:text-white capitalize">
              {settings.themeColor}
            </p>
          </div>
        </div>
      </div>

      <div className="rounded-3xl bg-white p-5 shadow-xs border border-slate-200/80 dark:bg-slate-900 dark:border-slate-800 space-y-3.5">
        <div className="flex items-center justify-between text-xs">
          <div className="flex items-center gap-2 text-slate-700 dark:text-slate-300">
            <Globe className="h-4 w-4 text-slate-400" />
            <span className="font-medium">Bahasa Aplikasi</span>
          </div>
          <span className="font-bold text-slate-900 dark:text-white">
            Bahasa Indonesia (ID)
          </span>
        </div>

        <div className="border-t border-slate-100 dark:border-slate-800 pt-3 flex items-center justify-between text-xs">
          <div className="flex items-center gap-2 text-slate-700 dark:text-slate-300">
            <ShieldCheck className="h-4 w-4 text-slate-400" />
            <span className="font-medium">Versi Aplikasi</span>
          </div>
          <span className="font-mono text-slate-500 dark:text-slate-400">
            NuNews v2.4 (Modernized)
          </span>
        </div>
      </div>
    </div>
  );
};
