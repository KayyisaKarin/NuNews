/**
 * NuNews - Reading Customization Modal ("Customize your view")
 */

import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Check, Sun, SunMedium } from 'lucide-react';
import { useReaderSettings } from '../../../../providers/reader_settings_provider';
import { ReaderThemeColor } from '../../../../core/theme/app_theme';

export const ReaderCustomizationModal: React.FC = () => {
  const {
    isOpen,
    closeReaderModal,
    settings,
    setFontStyle,
    setFontSize,
    setBrightness,
    setThemeColor,
  } = useReaderSettings();

  if (!isOpen) return null;

  const THEME_OPTIONS: { id: ReaderThemeColor; label: string; bgClass: string; borderClass: string }[] = [
    { id: 'white', label: 'Putih Terang', bgClass: 'bg-white', borderClass: 'border-slate-300' },
    { id: 'sepia', label: 'Kuning Pastel Hangat', bgClass: 'bg-[#FEF9C3]', borderClass: 'border-[#FDE047]' },
    { id: 'slate', label: 'Abu Slate', bgClass: 'bg-[#64748B]', borderClass: 'border-slate-600' },
    { id: 'oled', label: 'Hitam OLED', bgClass: 'bg-black', borderClass: 'border-neutral-800' },
  ];

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={closeReaderModal}
          className="absolute inset-0 bg-black/60 backdrop-blur-xs"
        />

        <motion.div
          initial={{ y: '100%', opacity: 0.8 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: '100%', opacity: 0 }}
          transition={{ type: 'spring', damping: 28, stiffness: 300 }}
          className="relative z-10 w-full max-w-sm sm:max-w-md rounded-t-3xl sm:rounded-3xl bg-white p-6 shadow-2xl dark:bg-slate-900 border border-slate-200 dark:border-slate-800"
        >
          <div className="mx-auto mb-3 h-1.5 w-12 rounded-full bg-slate-200 dark:bg-slate-700 sm:hidden" />

          <div className="relative text-center pb-2">
            <h3 className="text-lg font-bold text-slate-900 dark:text-white">
              Customize your view
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
              Sesuaikan preferensi membaca artikel Anda
            </p>
          </div>

          <div className="mt-5 space-y-6">
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-2">
                Font Style
              </label>
              <div className="grid grid-cols-2 gap-2 rounded-xl bg-slate-100 p-1 dark:bg-slate-800">
                <button
                  type="button"
                  onClick={() => setFontStyle('sans')}
                  className={`py-2 text-sm font-semibold rounded-lg transition-all ${
                    settings.fontStyle === 'sans'
                      ? 'bg-white dark:bg-slate-900 text-rose-500 dark:text-rose-400 shadow-xs'
                      : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
                  }`}
                >
                  Sans
                </button>
                <button
                  type="button"
                  onClick={() => setFontStyle('serif')}
                  className={`py-2 text-sm font-serif font-semibold rounded-lg transition-all ${
                    settings.fontStyle === 'serif'
                      ? 'bg-white dark:bg-slate-900 text-rose-500 dark:text-rose-400 shadow-xs'
                      : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
                  }`}
                >
                  Serif
                </button>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                  Font Size
                </label>
                <span className="text-xs font-mono text-slate-500 dark:text-slate-400">
                  {settings.fontSize}px
                </span>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-xs font-medium text-slate-400 dark:text-slate-500">A</span>
                <input
                  type="range"
                  min="13"
                  max="22"
                  step="1"
                  value={settings.fontSize}
                  onChange={(e) => setFontSize(Number(e.target.value))}
                  aria-label="Ukuran font bacaan"
                  className="h-1.5 w-full cursor-pointer appearance-none rounded-lg bg-slate-200 dark:bg-slate-700 accent-slate-900 dark:accent-white"
                />
                <span className="text-base font-bold text-slate-900 dark:text-white">A</span>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                  Brightness
                </label>
                <span className="text-xs font-mono text-slate-500 dark:text-slate-400">
                  {Math.round(settings.brightness * 100)}%
                </span>
              </div>
              <div className="flex items-center gap-3">
                <Sun className="h-4 w-4 text-slate-400 dark:text-slate-500" />
                <input
                  type="range"
                  min="0.5"
                  max="1.0"
                  step="0.05"
                  value={settings.brightness}
                  onChange={(e) => setBrightness(Number(e.target.value))}
                  aria-label="Tingkat kecerahan bacaan"
                  className="h-1.5 w-full cursor-pointer appearance-none rounded-lg bg-slate-200 dark:bg-slate-700 accent-slate-900 dark:accent-white"
                />
                <SunMedium className="h-5 w-5 text-slate-900 dark:text-white" />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-2.5">
                Theme Color
              </label>
              <div className="flex items-center justify-between px-2">
                {THEME_OPTIONS.map((theme) => {
                  const isSelected = settings.themeColor === theme.id;
                  return (
                    <button
                      key={theme.id}
                      type="button"
                      aria-label={theme.label}
                      onClick={() => setThemeColor(theme.id)}
                      className={`relative flex h-11 w-11 items-center justify-center rounded-full border-2 transition-transform active:scale-95 ${theme.bgClass} ${theme.borderClass} ${
                        isSelected ? 'ring-2 ring-rose-500 ring-offset-2 dark:ring-offset-slate-900 scale-105' : 'hover:opacity-90'
                      }`}
                    >
                      {isSelected && (
                        <Check className="h-5 w-5 text-rose-500 stroke-[2.5]" />
                      )}
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="pt-2">
              <button
                type="button"
                onClick={closeReaderModal}
                className="w-full py-3.5 px-4 rounded-2xl bg-slate-900 dark:bg-white text-white dark:text-slate-900 font-bold text-sm tracking-wide shadow-md transition-all active:scale-[0.98] hover:bg-slate-800 dark:hover:bg-slate-100"
              >
                Done
              </button>
            </div>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};
