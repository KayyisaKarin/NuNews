import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nu_news/core/constants/api_constants.dart';
import 'package:nu_news/core/utils/date_formatter.dart';
import 'package:nu_news/data/models/article.dart';
import 'package:nu_news/data/services/news_api_exception.dart';

class _RssCacheEntry {
  const _RssCacheEntry({required this.timestamp, required this.articles});

  final DateTime timestamp;
  final List<Article> articles;
}

/// Fetches and parses live Indonesian news directly from official CNN Indonesia,
/// CNBC Indonesia, and Antara News RSS feeds.
class NewsApiService {
  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, _RssCacheEntry> _cache = {};

  Future<List<Article>> getAllArticles({bool forceRefresh = false}) async {
    try {
      final items = await _fetchRssFeed(
        rssUrl: ApiConstants.cnnAllRss,
        categoryName: 'Nasional',
        categorySlug: 'nasional',
        sourceName: 'CNN Indonesia',
        inferCategoryFromLink: true,
        forceRefresh: forceRefresh,
      );
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback to CNN Nasional feed below if main feed temporarily fails
    }

    return _fetchRssFeed(
      rssUrl: ApiConstants.cnnCategoryRss('nasional'),
      categoryName: 'Nasional',
      categorySlug: 'nasional',
      sourceName: 'CNN Indonesia',
      inferCategoryFromLink: true,
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Article>> fetchCategoryNews(
    String categorySlug, {
    bool forceRefresh = false,
  }) async {
    String rssUrl = ApiConstants.cnnAllRss;
    String catName = 'Terkini';
    String sourceName = 'CNN Indonesia';

    switch (categorySlug) {
      case 'nasional':
        rssUrl = ApiConstants.cnnCategoryRss('nasional');
        catName = 'Nasional';
      case 'internasional':
        rssUrl = ApiConstants.cnnCategoryRss('internasional');
        catName = 'Internasional';
      case 'ekonomi':
        rssUrl = ApiConstants.cnnCategoryRss('ekonomi');
        catName = 'Ekonomi';
      case 'olahraga':
        rssUrl = ApiConstants.cnnCategoryRss('olahraga');
        catName = 'Olahraga';
      case 'teknologi':
        rssUrl = ApiConstants.cnnCategoryRss('teknologi');
        catName = 'Teknologi';
      case 'hiburan':
        rssUrl = ApiConstants.cnnCategoryRss('hiburan');
        catName = 'Hiburan';
      case 'gaya-hidup':
        rssUrl = ApiConstants.cnnCategoryRss('gaya-hidup');
        catName = 'Gaya Hidup';
      case 'antara':
        rssUrl = ApiConstants.antaraRss('terkini');
        catName = 'Antara News';
        sourceName = 'Antara News';
      case 'cnbc':
        rssUrl = ApiConstants.cnbcAllRss;
        catName = 'CNBC Indonesia';
        sourceName = 'CNBC Indonesia';
      default:
        rssUrl = ApiConstants.cnnAllRss;
        catName = 'Terkini';
    }

    final list = await _fetchRssFeed(
      rssUrl: rssUrl,
      categoryName: catName,
      categorySlug: categorySlug,
      sourceName: sourceName,
      inferCategoryFromLink: categorySlug == 'semua' || categorySlug == 'cnn',
      forceRefresh: forceRefresh,
    );
    return list.take(30).toList();
  }

  Future<String> _getXmlString(String rssUrl) async {
    if (!kIsWeb) {
      final response = await _client
          .get(Uri.parse(rssUrl), headers: ApiConstants.defaultHeaders)
          .timeout(ApiConstants.timeout);
      if (response.statusCode != 200) {
        throw NewsApiException.serverError;
      }
      return utf8.decode(response.bodyBytes, allowMalformed: true);
    }

    // On Flutter Web (Chrome), try direct first, then CORS-safe raw proxy if blocked
    try {
      final direct = await _client
          .get(Uri.parse(rssUrl))
          .timeout(ApiConstants.timeout);
      if (direct.statusCode == 200 && direct.body.contains('<item>')) {
        return utf8.decode(direct.bodyBytes, allowMalformed: true);
      }
    } catch (_) {
      // Browser CORS blocked direct RSS fetch; fallback to allorigins below
    }

    final proxiedUri = Uri.parse(
      'https://api.allorigins.win/raw?url=${Uri.encodeComponent(rssUrl)}',
    );
    final proxied = await _client.get(proxiedUri).timeout(ApiConstants.timeout);
    if (proxied.statusCode != 200) {
      throw NewsApiException.serverError;
    }
    return utf8.decode(proxied.bodyBytes, allowMalformed: true);
  }

  Future<List<Article>> _fetchRssFeed({
    required String rssUrl,
    required String categoryName,
    required String categorySlug,
    required String sourceName,
    required bool inferCategoryFromLink,
    required bool forceRefresh,
  }) async {
    final cached = _cache[rssUrl];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.timestamp) < ApiConstants.cacheTtl) {
      return cached.articles;
    }

    try {
      final xml = await _getXmlString(rssUrl);

      final parsed = parseRssXml(
        xml: xml,
        defaultCategoryName: categoryName,
        defaultCategorySlug: categorySlug,
        sourceName: sourceName,
        inferCategoryFromLink: inferCategoryFromLink,
      );

      if (parsed.isNotEmpty) {
        _cache[rssUrl] = _RssCacheEntry(
          timestamp: DateTime.now(),
          articles: parsed,
        );
      }

      return parsed;
    } on NewsApiException {
      rethrow;
    } on http.ClientException {
      throw NewsApiException.offline;
    } on TimeoutException {
      throw NewsApiException.slowConnection;
    } catch (_) {
      throw NewsApiException.serverError;
    }
  }

  /// Parses standard RSS 2.0 XML into [Article] objects.
  static List<Article> parseRssXml({
    required String xml,
    required String defaultCategoryName,
    required String defaultCategorySlug,
    required String sourceName,
    bool inferCategoryFromLink = false,
  }) {
    final itemPattern = RegExp(r'<item>[\s\S]*?</item>', caseSensitive: false);
    final matches = itemPattern.allMatches(xml).toList();
    final List<Article> results = [];

    for (var i = 0; i < matches.length; i++) {
      final block = matches[i].group(0) ?? '';
      final title = _stripTags(_extractTag(block, 'title'));
      final rawLink = _extractTag(block, 'link');
      final link = _stripTags(
        rawLink.isNotEmpty ? rawLink : _extractTag(block, 'guid'),
      );

      if (title.isEmpty || link.isEmpty) continue;

      final pubDateRaw = _stripTags(_extractTag(block, 'pubDate'));
      final descriptionRaw = _extractTag(block, 'description');
      final contentEncodedRaw = _extractTag(block, 'content:encoded');

      final snippet = _stripTags(
        contentEncodedRaw.isNotEmpty
            ? contentEncodedRaw
            : (descriptionRaw.isNotEmpty ? descriptionRaw : title),
      );
      final rawImage = _extractImageUrl(block, descriptionRaw);
      final largeImage = _toHighResImageUrl(rawImage);

      String catName = defaultCategoryName;
      String catSlug = defaultCategorySlug;

      if (inferCategoryFromLink) {
        if (link.contains('/ekonomi/')) {
          catName = 'Ekonomi';
          catSlug = 'ekonomi';
        } else if (link.contains('/olahraga/')) {
          catName = 'Olahraga';
          catSlug = 'olahraga';
        } else if (link.contains('/teknologi/')) {
          catName = 'Teknologi';
          catSlug = 'teknologi';
        } else if (link.contains('/hiburan/')) {
          catName = 'Hiburan';
          catSlug = 'hiburan';
        } else if (link.contains('/gaya-hidup/')) {
          catName = 'Gaya Hidup';
          catSlug = 'gaya-hidup';
        } else if (link.contains('/internasional/')) {
          catName = 'Internasional';
          catSlug = 'internasional';
        } else {
          catName = 'Nasional';
          catSlug = 'nasional';
        }
      }

      final id = _generateId(link.isNotEmpty ? link : title);
      final hash = id.codeUnits.fold<int>(0, (acc, code) => acc + code).abs();
      final wordCount =
          snippet.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final readTimeMinutes = ((wordCount / 30).ceil() + 2).clamp(2, 7);
      final likesCount = 150 + (hash % 650);
      final commentsCount = 8 + (hash % 45);
      final parsedDate = DateFormatter.tryParseRssDate(pubDateRaw);

      final paragraph1 = snippet;
      final paragraph2 =
          'Berita ini dilaporkan oleh tim redaksi $sourceName dengan mengedepankan akurasi fakta dan verifikasi menyeluruh di lapangan. Perkembangan informasi akan terus diperbarui seiring konfirmasi resmi dari pihak terkait.';
      final paragraph3 =
          'Untuk membaca liputan selengkapnya beserta pembaruan terkini dari sumber asli, silakan buka tautan resmi $sourceName atau jelajahi berita terkait di NuNews.';

      final rawSlug =
          title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      final slug = rawSlug.length > 80 ? rawSlug.substring(0, 80) : rawSlug;

      results.add(
        Article(
          id: id,
          title: title,
          slug: slug,
          summary: snippet,
          content: '$paragraph1\n\n$paragraph2\n\n$paragraph3',
          category: catName,
          categorySlug: catSlug,
          authorName: 'Redaksi $sourceName',
          imageUrl: largeImage,
          publishedAt: DateFormatter.formatTimeAgo(parsedDate),
          readTimeMinutes: readTimeMinutes,
          likesCount: likesCount,
          commentsCount: commentsCount,
          isFeatured: i == 0,
          isPopular: likesCount > 400,
          isTrending: commentsCount > 25,
          sourceUrl: link,
        ),
      );
    }

    return results;
  }

  static String _generateId(String input) {
    var hash = 0;
    for (final code in input.codeUnits) {
      hash = ((hash << 5) - hash + code) & 0x7FFFFFFF;
    }
    return 'art_${hash.toRadixString(36)}';
  }

  static String _decodeHtmlEntities(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'<!\[CDATA\[([\s\S]*?)\]\]>'),
          (m) => m.group(1) ?? '',
        )
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  static String _stripTags(String input) {
    return _decodeHtmlEntities(input)
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _extractTag(String block, String tagName) {
    final regex = RegExp(
      '<$tagName[^>]*>([\\s\\S]*?)<\\/$tagName>',
      caseSensitive: false,
    );
    final match = regex.firstMatch(block);
    return match?.group(1) ?? '';
  }

  static String _extractImageUrl(String block, String descriptionRaw) {
    final enclosure = RegExp(
      r'''<enclosure[^>]+url=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(block);
    if (enclosure?.group(1) != null) {
      return _decodeHtmlEntities(enclosure!.group(1)!);
    }

    final media = RegExp(
      r'''<media:content[^>]+url=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(block);
    if (media?.group(1) != null) {
      return _decodeHtmlEntities(media!.group(1)!);
    }

    final img = RegExp(
      r'''<img[^>]+src=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(_decodeHtmlEntities(descriptionRaw));
    if (img?.group(1) != null) {
      return _decodeHtmlEntities(img!.group(1)!);
    }

    return '';
  }

  static String _toHighResImageUrl(String url) {
    if (url.isEmpty) return '';
    return url
        .replaceAllMapped(RegExp(r'([?&])w=\d+', caseSensitive: false),
            (m) => '${m.group(1)}w=900')
        .replaceAllMapped(RegExp(r'([?&])q=\d+', caseSensitive: false),
            (m) => '${m.group(1)}q=95');
  }
}
