/**
 * NuNews - Bookmark & Like Storage Service
 */

const BOOKMARK_KEY = 'nunews_saved_bookmarks_v1';
const LIKED_ARTICLES_KEY = 'nunews_liked_articles_v1';

export class BookmarkStorage {
  static getBookmarks(): string[] {
    try {
      const data = localStorage.getItem(BOOKMARK_KEY);
      if (!data) return [];
      const parsed = JSON.parse(data);
      if (Array.isArray(parsed)) {
        return parsed.filter((id) => id !== 'dumplings-art-1' && id !== 'skincare-serum-2');
      }
      return [];
    } catch {
      return [];
    }
  }

  static toggleBookmark(articleId: string): string[] {
    const current = this.getBookmarks();
    const index = current.indexOf(articleId);
    const updated =
      index >= 0 ? current.filter((id) => id !== articleId) : [articleId, ...current];
    try {
      localStorage.setItem(BOOKMARK_KEY, JSON.stringify(updated));
    } catch (e) {
      console.warn('Gagal menyimpan markah:', e);
    }
    return updated;
  }

  static getLikedArticles(): string[] {
    try {
      const data = localStorage.getItem(LIKED_ARTICLES_KEY);
      return data ? JSON.parse(data) : [];
    } catch {
      return [];
    }
  }

  static toggleLike(articleId: string): { liked: boolean; list: string[] } {
    const current = this.getLikedArticles();
    const isLiked = current.includes(articleId);
    const updated = isLiked
      ? current.filter((id) => id !== articleId)
      : [...current, articleId];
    try {
      localStorage.setItem(LIKED_ARTICLES_KEY, JSON.stringify(updated));
    } catch (e) {
      console.warn('Gagal menyimpan suka:', e);
    }
    return { liked: !isLiked, list: updated };
  }
}
