/**
 * NuNews - News API Service
 * Mengambil berita aktual secara real-time melalui backend proxy lokal (/api/news)
 * yang mem-parsing RSS feed resmi CNN Indonesia, CNBC Indonesia, dan Antara News.
 */

import { Article } from '../models/article';
import { API_CONSTANTS } from '../../core/constants/api_constants';
import { formatTimeAgo } from '../../core/utils/date_formatter';
import fallbackNewsImg from '../../assets/images/nusantara_modern_city_1794402739036.jpg';

interface RawApiPost {
  title: string;
  link: string;
  contentSnippet?: string;
  isoDate?: string;
  image?: {
    small?: string;
    large?: string;
  };
}

interface RawApiResponse {
  total?: number;
  data?: RawApiPost[];
  messages?: string;
  error?: string;
}

export class NewsApiService {
  private static cacheByCategory: Map<string, Article[]> = new Map();
  private static allArticlesCache: Article[] = [];

  private static generateId(str: string): string {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = (hash << 5) - hash + str.charCodeAt(i);
      hash |= 0;
    }
    return `art_${Math.abs(hash).toString(36)}`;
  }

  private static mapRawToArticle(
    raw: RawApiPost,
    categoryName: string,
    categorySlug: string,
    sourceName = 'CNN Indonesia'
  ): Article {
    const id = this.generateId(raw.link || raw.title);
    const publishedAt = formatTimeAgo(raw.isoDate);
    const summary = raw.contentSnippet || raw.title;
    const imageUrl = raw.image?.large || raw.image?.small || fallbackNewsImg;

    const wordCount = (raw.contentSnippet || '').split(/\s+/).filter(Boolean).length;
    const readTimeMinutes = Math.max(2, Math.min(7, Math.ceil(wordCount / 30) + 2));
    const hash = Math.abs(id.split('').reduce((acc, c) => acc + c.charCodeAt(0), 0));
    const likesCount = 150 + (hash % 650);
    const commentsCount = 8 + (hash % 45);

    const paragraph1 = summary;
    const paragraph2 = `Berita ini dilaporkan oleh tim redaksi ${sourceName} dengan mengedepankan akurasi fakta dan verifikasi menyeluruh di lapangan. Perkembangan informasi akan terus diperbarui seiring konfirmasi resmi dari pihak terkait.`;
    const paragraph3 = `Untuk membaca liputan selengkapnya beserta pembaruan terkini dari sumber asli, silakan buka tautan resmi ${sourceName} atau jelajahi berita terkait di NuNews.`;

    const fullContent = `${paragraph1}\n\n${paragraph2}\n\n${paragraph3}`;

    return {
      id,
      title: raw.title,
      slug: raw.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').slice(0, 80),
      summary,
      content: fullContent,
      category: categoryName,
      categorySlug,
      author: {
        name: `Redaksi ${sourceName}`,
        avatar: '',
        role: `Jurnalis ${categoryName}`,
      },
      imageUrl,
      publishedAt,
      readTimeMinutes,
      likesCount,
      commentsCount,
      isFeatured: false,
      isPopular: likesCount > 400,
      isTrending: commentsCount > 25,
      tags: [categoryName, sourceName, 'NuNews', 'Indonesia'],
      sourceUrl: raw.link,
    };
  }

  static async fetchCategoryNews(categorySlug: string, forceRefresh = false): Promise<Article[]> {
    if (!forceRefresh && this.cacheByCategory.has(categorySlug)) {
      return this.cacheByCategory.get(categorySlug)!;
    }

    let url: string = API_CONSTANTS.CNN_ALL;
    let catName = 'Nasional';
    let sourceName = 'CNN Indonesia';

    switch (categorySlug) {
      case 'nasional':
        url = API_CONSTANTS.CNN_CATEGORY('nasional');
        catName = 'Nasional';
        break;
      case 'internasional':
        url = API_CONSTANTS.CNN_CATEGORY('internasional');
        catName = 'Internasional';
        break;
      case 'ekonomi':
        url = API_CONSTANTS.CNN_CATEGORY('ekonomi');
        catName = 'Ekonomi';
        break;
      case 'olahraga':
        url = API_CONSTANTS.CNN_CATEGORY('olahraga');
        catName = 'Olahraga';
        break;
      case 'teknologi':
        url = API_CONSTANTS.CNN_CATEGORY('teknologi');
        catName = 'Teknologi';
        break;
      case 'hiburan':
        url = API_CONSTANTS.CNN_CATEGORY('hiburan');
        catName = 'Hiburan';
        break;
      case 'gaya-hidup':
        url = API_CONSTANTS.CNN_CATEGORY('gaya-hidup');
        catName = 'Gaya Hidup';
        break;
      case 'antara':
        url = API_CONSTANTS.ANTARA_TYPE('terkini');
        catName = 'Antara News';
        sourceName = 'Antara News';
        break;
      case 'cnbc':
        url = API_CONSTANTS.CNBC_ALL;
        catName = 'CNBC Indonesia';
        sourceName = 'CNBC Indonesia';
        break;
      default:
        url = API_CONSTANTS.CNN_ALL;
        catName = 'Terkini';
        break;
    }

    try {
      const fetchUrl = forceRefresh ? `${url}?refresh=1` : url;
      const res = await fetch(fetchUrl);
      if (!res.ok) {
        throw new Error(`API HTTP Error: ${res.status}`);
      }

      const json: RawApiResponse = await res.json();
      const rawPosts = json.data || [];

      const mapped = rawPosts.slice(0, 30).map((p, idx) => {
        const item = this.mapRawToArticle(p, catName, categorySlug, sourceName);
        if (idx === 0) item.isFeatured = true;
        return item;
      });

      if (mapped.length > 0) {
        this.cacheByCategory.set(categorySlug, mapped);
      }
      return mapped;
    } catch (err) {
      console.warn(`Gagal mengambil berita kategori ${categorySlug}:`, err);
      return this.allArticlesCache.filter((a) => a.categorySlug === categorySlug);
    }
  }

  static async getAllArticles(forceRefresh = false): Promise<Article[]> {
    if (!forceRefresh && this.allArticlesCache.length > 0) {
      return this.allArticlesCache;
    }

    try {
      const fetchUrl = forceRefresh ? `${API_CONSTANTS.CNN_ALL}?refresh=1` : API_CONSTANTS.CNN_ALL;
      const res = await fetch(fetchUrl);
      if (!res.ok) {
        throw new Error(`Failed to load cnn-news: ${res.status}`);
      }

      const json: RawApiResponse = await res.json();
      const rawPosts = json.data || [];

      const articles: Article[] = rawPosts.map((p, idx) => {
        let cat = 'Nasional';
        let slug = 'nasional';
        if (p.link.includes('/ekonomi/')) {
          cat = 'Ekonomi';
          slug = 'ekonomi';
        } else if (p.link.includes('/olahraga/')) {
          cat = 'Olahraga';
          slug = 'olahraga';
        } else if (p.link.includes('/teknologi/')) {
          cat = 'Teknologi';
          slug = 'teknologi';
        } else if (p.link.includes('/hiburan/')) {
          cat = 'Hiburan';
          slug = 'hiburan';
        } else if (p.link.includes('/gaya-hidup/')) {
          cat = 'Gaya Hidup';
          slug = 'gaya-hidup';
        } else if (p.link.includes('/internasional/')) {
          cat = 'Internasional';
          slug = 'internasional';
        }

        const article = this.mapRawToArticle(p, cat, slug, 'CNN Indonesia');
        if (idx === 0) article.isFeatured = true;
        return article;
      });

      if (articles.length > 0) {
        this.allArticlesCache = articles;
      }
      return articles;
    } catch (err) {
      console.warn('Gagal memuat berita terkini dari API:', err);
      return this.allArticlesCache;
    }
  }

  static async getFeaturedArticle(): Promise<Article | null> {
    const all = await this.getAllArticles();
    return all.find((a) => a.isFeatured) || all[0] || null;
  }

  static async getArticleById(id: string): Promise<Article | null> {
    const all = await this.getAllArticles();
    const found = all.find((a) => a.id === id);
    if (found) return found;

    for (const list of this.cacheByCategory.values()) {
      const match = list.find((a) => a.id === id);
      if (match) return match;
    }
    return null;
  }
}
