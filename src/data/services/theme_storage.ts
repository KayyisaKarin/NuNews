/**
 * NuNews - Theme & Reader Settings Storage Service
 */

import { ReaderSettings, DEFAULT_READER_SETTINGS } from '../../core/theme/app_theme';

const READER_SETTINGS_KEY = 'nunews_reader_settings_v1';
const THEME_KEY = 'nunews_theme_mode_v1';

export class ThemeStorage {
  static getTheme(): 'light' | 'dark' | 'system' {
    try {
      const data = localStorage.getItem(THEME_KEY);
      return (data as 'light' | 'dark' | 'system') || 'light';
    } catch {
      return 'light';
    }
  }

  static saveTheme(theme: 'light' | 'dark' | 'system'): void {
    try {
      localStorage.setItem(THEME_KEY, theme);
    } catch (e) {
      console.warn('Gagal menyimpan tema:', e);
    }
  }

  static getReaderSettings(): ReaderSettings {
    try {
      const data = localStorage.getItem(READER_SETTINGS_KEY);
      return data ? { ...DEFAULT_READER_SETTINGS, ...JSON.parse(data) } : DEFAULT_READER_SETTINGS;
    } catch {
      return DEFAULT_READER_SETTINGS;
    }
  }

  static saveReaderSettings(settings: ReaderSettings): void {
    try {
      localStorage.setItem(READER_SETTINGS_KEY, JSON.stringify(settings));
    } catch (e) {
      console.warn('Gagal menyimpan pengaturan bacaan:', e);
    }
  }
}
