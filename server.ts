import express from 'express';
import path from 'node:path';

interface RssNewsItem {
  title: string;
  link: string;
  contentSnippet: string;
  isoDate: string;
  image: {
    small: string;
    large: string;
  };
}

interface CacheEntry {
  timestamp: number;
  data: RssNewsItem[];
}

const CACHE_TTL_MS = 3 * 60 * 1000;
const rssCache = new Map<string, CacheEntry>();

const CNN_ALLOWED_CATEGORIES = new Set([
  'nasional',
  'internasional',
  'ekonomi',
  'olahraga',
  'teknologi',
  'hiburan',
  'gaya-hidup',
]);

const ANTARA_ALLOWED_TYPES = new Set([
  'terkini',
  'top-news',
  'politik',
  'hukum',
  'ekonomi',
  'metro',
  'sepakbola',
  'olahraga',
  'humaniora',
  'lifestyle',
  'hiburan',
  'dunia',
  'tekno',
]);

function decodeHtmlEntities(input: string): string {
  return input
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&#x27;/g, "'")
    .replace(/&nbsp;/g, ' ')
    .trim();
}

function stripTags(input: string): string {
  return decodeHtmlEntities(input)
    .replace(/<[^>]*>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function extractTag(block: string, tagName: string): string {
  const regex = new RegExp(`<${tagName}[^>]*>([\\s\\S]*?)<\\/${tagName}>`, 'i');
  const match = block.match(regex);
  return match ? match[1] : '';
}

function extractImageUrl(block: string, descriptionRaw: string): string {
  const enclosureMatch = block.match(/<enclosure[^>]+url=["']([^"']+)["']/i);
  if (enclosureMatch?.[1]) {
    return decodeHtmlEntities(enclosureMatch[1]);
  }

  const mediaMatch = block.match(/<media:content[^>]+url=["']([^"']+)["']/i);
  if (mediaMatch?.[1]) {
    return decodeHtmlEntities(mediaMatch[1]);
  }

  const imgMatch = decodeHtmlEntities(descriptionRaw).match(/<img[^>]+src=["']([^"']+)["']/i);
  if (imgMatch?.[1]) {
    return decodeHtmlEntities(imgMatch[1]);
  }

  return '';
}

function toLargeImageUrl(url: string): string {
  if (!url) return '';
  return url.replace(/([?&])w=\d+/i, '$1w=900').replace(/([?&])q=\d+/i, '$1q=95');
}

function parseRssXml(xml: string): RssNewsItem[] {
  const items: RssNewsItem[] = [];
  const itemMatches = xml.match(/<item>[\s\S]*?<\/item>/gi) || [];

  for (const block of itemMatches) {
    const title = stripTags(extractTag(block, 'title'));
    const link = stripTags(extractTag(block, 'link') || extractTag(block, 'guid'));
    const pubDateRaw = stripTags(extractTag(block, 'pubDate'));
    const descriptionRaw = extractTag(block, 'description');
    const contentEncodedRaw = extractTag(block, 'content:encoded');

    const contentSnippet = stripTags(contentEncodedRaw || descriptionRaw || title);
    const smallImg = extractImageUrl(block, descriptionRaw);
    const largeImg = toLargeImageUrl(smallImg);

    let isoDate = new Date().toISOString();
    if (pubDateRaw) {
      const parsed = new Date(pubDateRaw);
      if (!Number.isNaN(parsed.getTime())) {
        isoDate = parsed.toISOString();
      }
    }

    if (title && link) {
      items.push({
        title,
        link,
        contentSnippet,
        isoDate,
        image: {
          small: smallImg,
          large: largeImg || smallImg,
        },
      });
    }
  }

  return items;
}

async function fetchRssFeed(rssUrl: string, bypassCache = false): Promise<RssNewsItem[]> {
  const cached = rssCache.get(rssUrl);
  if (!bypassCache && cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
    return cached.data;
  }

  const response = await fetch(rssUrl, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; NuNewsApp/1.0)',
      Accept: 'application/rss+xml, application/xml, text/xml, */*',
    },
  });

  if (!response.ok) {
    throw new Error(`RSS upstream error ${response.status} for ${rssUrl}`);
  }

  const xml = await response.text();
  const parsed = parseRssXml(xml);

  if (parsed.length > 0) {
    rssCache.set(rssUrl, { timestamp: Date.now(), data: parsed });
  }

  return parsed;
}

async function startServer() {
  const app = express();
  const PORT = Number(process.env.PORT) || 3000;

  // Health check
  app.get('/api/health', (_req, res) => {
    res.json({ status: 'ok', app: 'NuNews' });
  });

  // CNN Indonesia - All latest news
  app.get('/api/news/cnn-news', async (req, res) => {
    try {
      const bypass = req.query.refresh === '1';
      const data = await fetchRssFeed('https://www.cnnindonesia.com/rss', bypass);
      res.json({ messages: 'Result of all news in CNN News', total: data.length, data });
    } catch (err) {
      console.error('CNN RSS error:', err);
      res.status(502).json({ error: 'Gagal memuat berita CNN Indonesia', data: [] });
    }
  });

  // CNN Indonesia - By category
  app.get('/api/news/cnn-news/:category', async (req, res) => {
    const category = String(req.params.category || '').toLowerCase();
    if (!CNN_ALLOWED_CATEGORIES.has(category)) {
      res.status(400).json({ error: 'Kategori tidak dikenali', data: [] });
      return;
    }

    try {
      const bypass = req.query.refresh === '1';
      const data = await fetchRssFeed(`https://www.cnnindonesia.com/${category}/rss`, bypass);
      res.json({ messages: `Result of ${category} news in CNN News`, total: data.length, data });
    } catch (err) {
      console.error(`CNN ${category} RSS error:`, err);
      res.status(502).json({ error: `Gagal memuat berita CNN kategori ${category}`, data: [] });
    }
  });

  // CNBC Indonesia - Business & Market news
  app.get('/api/news/cnbc-news', async (req, res) => {
    try {
      const bypass = req.query.refresh === '1';
      const data = await fetchRssFeed('https://www.cnbcindonesia.com/news/rss', bypass);
      res.json({ messages: 'Result of all news in CNBC News', total: data.length, data });
    } catch (err) {
      console.error('CNBC RSS error:', err);
      res.status(502).json({ error: 'Gagal memuat berita CNBC Indonesia', data: [] });
    }
  });

  // Antara News - By type
  app.get('/api/news/antara-news/:type', async (req, res) => {
    const type = String(req.params.type || 'terkini').toLowerCase();
    const safeType = ANTARA_ALLOWED_TYPES.has(type) ? type : 'terkini';

    try {
      const bypass = req.query.refresh === '1';
      const data = await fetchRssFeed(`https://www.antaranews.com/rss/${safeType}.xml`, bypass);
      res.json({ messages: `Result of ${safeType} news in Antara News`, total: data.length, data });
    } catch (err) {
      console.error('Antara RSS error:', err);
      res.status(502).json({ error: 'Gagal memuat berita Antara News', data: [] });
    }
  });

  const isProd = process.env.NODE_ENV === 'production' || process.argv.includes('--prod');

  if (isProd) {
    const distPath = path.resolve(import.meta.dirname, 'dist');
    app.use(express.static(distPath));
    app.get('*', (_req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  } else {
    const { createServer: createViteServer } = await import('vite');
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`NuNews server running on http://localhost:${PORT}`);
  });
}

startServer().catch((err) => {
  console.error('Failed to start NuNews server:', err);
  process.exit(1);
});
