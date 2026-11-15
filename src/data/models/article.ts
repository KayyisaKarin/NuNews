/**
 * NuNews - Article Model
 */

export interface Article {
  id: string;
  title: string;
  slug: string;
  summary: string;
  content: string;
  category: string;
  categorySlug: string;
  author: {
    name: string;
    avatar: string;
    role?: string;
  };
  imageUrl: string;
  publishedAt: string;
  readTimeMinutes: number;
  likesCount: number;
  commentsCount: number;
  isFeatured?: boolean;
  isPopular?: boolean;
  isTrending?: boolean;
  tags?: string[];
  sourceUrl?: string;
}
