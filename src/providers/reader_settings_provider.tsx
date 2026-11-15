/**
 * NuNews - Reader Settings Provider (State Management)
 * Mengelola state kustomisasi tampilan pembaca ("Customize your view"):
 * Font Style (Sans / Serif), Font Size slider, Brightness slider, Theme Color palette.
 */

import React, { createContext, useContext, useState, useEffect, useMemo } from 'react';
import {
  ReaderSettings,
  ReaderFontStyle,
  ReaderThemeColor,
  DEFAULT_READER_SETTINGS,
} from '../core/theme/app_theme';
import { ThemeStorage } from '../data/services/theme_storage';

interface ReaderSettingsContextType {
  settings: ReaderSettings;
  isOpen: boolean;
  openReaderModal: () => void;
  closeReaderModal: () => void;
  setFontStyle: (style: ReaderFontStyle) => void;
  setFontSize: (size: number) => void;
  setBrightness: (brightness: number) => void;
  setThemeColor: (color: ReaderThemeColor) => void;
  resetSettings: () => void;
  // Computed CSS classes for the reader canvas and typography
  canvasClasses: string;
  textClasses: string;
  brightnessOverlayOpacity: number;
}

const ReaderSettingsContext = createContext<ReaderSettingsContextType | undefined>(undefined);

export const ReaderSettingsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [settings, setSettings] = useState<ReaderSettings>(() => ThemeStorage.getReaderSettings());
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    ThemeStorage.saveReaderSettings(settings);
  }, [settings]);

  const openReaderModal = () => setIsOpen(true);
  const closeReaderModal = () => setIsOpen(false);

  const setFontStyle = (fontStyle: ReaderFontStyle) => {
    setSettings((prev) => ({ ...prev, fontStyle }));
  };

  const setFontSize = (fontSize: number) => {
    setSettings((prev) => ({ ...prev, fontSize }));
  };

  const setBrightness = (brightness: number) => {
    setSettings((prev) => ({ ...prev, brightness }));
  };

  const setThemeColor = (themeColor: ReaderThemeColor) => {
    setSettings((prev) => ({ ...prev, themeColor }));
  };

  const resetSettings = () => {
    setSettings(DEFAULT_READER_SETTINGS);
  };

  // Compute theme styles
  const { canvasClasses, textClasses } = useMemo(() => {
    switch (settings.themeColor) {
      case 'sepia':
        return {
          canvasClasses: 'bg-[#FEFCE8] text-[#713F12] border-[#FEF08A] dark:bg-[#1C180E] dark:text-[#FEF08A] dark:border-[#42361C]',
          textClasses: 'text-[#713F12] dark:text-[#FEF08A]',
        };
      case 'slate':
        return {
          canvasClasses: 'bg-[#1E293B] text-[#E2E8F0] border-slate-700',
          textClasses: 'text-[#E2E8F0]',
        };
      case 'oled':
        return {
          canvasClasses: 'bg-black text-[#EDEDED] border-neutral-900',
          textClasses: 'text-[#EDEDED]',
        };
      case 'white':
      default:
        return {
          canvasClasses: 'bg-white text-slate-900 border-slate-200 dark:bg-slate-900 dark:text-slate-100 dark:border-slate-800',
          textClasses: 'text-slate-800 dark:text-slate-200',
        };
    }
  }, [settings.themeColor]);

  // Opacity of dimming layer if brightness < 1.0
  const brightnessOverlayOpacity = useMemo(() => {
    return Math.max(0, Math.min(0.5, (1.0 - settings.brightness) * 0.8));
  }, [settings.brightness]);

  return (
    <ReaderSettingsContext.Provider
      value={{
        settings,
        isOpen,
        openReaderModal,
        closeReaderModal,
        setFontStyle,
        setFontSize,
        setBrightness,
        setThemeColor,
        resetSettings,
        canvasClasses,
        textClasses,
        brightnessOverlayOpacity,
      }}
    >
      {children}
    </ReaderSettingsContext.Provider>
  );
};

export const useReaderSettings = (): ReaderSettingsContextType => {
  const context = useContext(ReaderSettingsContext);
  if (!context) {
    throw new Error('useReaderSettings harus digunakan di dalam ReaderSettingsProvider');
  }
  return context;
};
