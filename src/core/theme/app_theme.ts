/**
 * NuNews - App & Reader Theme Types
 * Digunakan untuk mode tema aplikasi & modal "Customize your view"
 */

export type ThemeMode = 'light' | 'dark';
export type ReaderFontStyle = 'sans' | 'serif';
export type ReaderThemeColor = 'white' | 'sepia' | 'slate' | 'oled';

export interface ReaderSettings {
  fontStyle: ReaderFontStyle;
  fontSize: number;
  brightness: number;
  themeColor: ReaderThemeColor;
}

export const DEFAULT_READER_SETTINGS: ReaderSettings = {
  fontStyle: 'sans',
  fontSize: 16,
  brightness: 1.0,
  themeColor: 'white',
};
