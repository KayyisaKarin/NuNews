/**
 * NuNews - API Constants
 * Endpoint proxy lokal (/api/news) ke RSS feed resmi CNN Indonesia, CNBC Indonesia, dan Antara News.
 */

export const API_CONSTANTS = {
  BASE_URL: '/api/news',
  CNN_ALL: '/api/news/cnn-news',
  CNN_CATEGORY: (category: string) => `/api/news/cnn-news/${category}`,
  CNBC_ALL: '/api/news/cnbc-news',
  ANTARA_TYPE: (type = 'terkini') => `/api/news/antara-news/${type}`,
} as const;
