/**
 * NuNews - News Categories
 */

export interface Category {
  id: string;
  name: string;
  slug: string;
  iconName: string;
  articleCount?: number;
}

export const NEWS_CATEGORIES: Category[] = [
  { id: 'semua', name: 'Semua', slug: 'semua', iconName: 'Sparkles' },
  { id: 'nasional', name: 'Nasional', slug: 'nasional', iconName: 'Flag' },
  { id: 'internasional', name: 'Internasional', slug: 'internasional', iconName: 'Globe' },
  { id: 'ekonomi', name: 'Ekonomi', slug: 'ekonomi', iconName: 'TrendingUp' },
  { id: 'olahraga', name: 'Olahraga', slug: 'olahraga', iconName: 'Trophy' },
  { id: 'teknologi', name: 'Teknologi', slug: 'teknologi', iconName: 'Cpu' },
  { id: 'hiburan', name: 'Hiburan', slug: 'hiburan', iconName: 'Film' },
  { id: 'gaya-hidup', name: 'Gaya Hidup', slug: 'gaya-hidup', iconName: 'Coffee' },
];
