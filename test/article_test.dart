import 'package:flutter_test/flutter_test.dart';
import 'package:nu_news/core/theme/app_theme.dart';
import 'package:nu_news/core/utils/date_formatter.dart';
import 'package:nu_news/data/services/news_api_service.dart';

void main() {
  group('NewsApiService RSS parsing', () {
    test('parses RSS items with CDATA, enclosure images, and category', () {
      const sampleXml = '''
<rss version="2.0">
  <channel>
    <item>
      <title><![CDATA[Ekonomi Digital Indonesia Tumbuh Pesat]]></title>
      <link>https://www.cnnindonesia.com/ekonomi/20261112-100/ekonomi-digital</link>
      <pubDate>Thu, 12 Nov 2026 12:00:00 +0700</pubDate>
      <description><![CDATA[<p>Pertumbuhan transaksi digital meningkat signifikan.</p>]]></description>
      <enclosure url="https://cdn.example.com/photo.jpg?w=300&amp;q=80" type="image/jpeg" />
    </item>
  </channel>
</rss>
''';

      final articles = NewsApiService.parseRssXml(
        xml: sampleXml,
        defaultCategoryName: 'Nasional',
        defaultCategorySlug: 'nasional',
        sourceName: 'CNN Indonesia',
        inferCategoryFromLink: true,
      );

      expect(articles, hasLength(1));
      final item = articles.first;
      expect(item.title, 'Ekonomi Digital Indonesia Tumbuh Pesat');
      expect(item.category, 'Ekonomi');
      expect(item.categorySlug, 'ekonomi');
      expect(item.isFeatured, isTrue);
      expect(item.imageUrl, 'https://cdn.example.com/photo.jpg?w=900&q=95');
    });
  });

  group('ReaderSettings serialization', () {
    test('round-trips toJson and fromJson cleanly', () {
      const settings = ReaderSettings(
        fontStyle: ReaderFontStyle.serif,
        fontSize: 19,
        brightness: 0.85,
        themeColor: ReaderThemeColor.sepia,
      );

      final restored = ReaderSettings.fromJson(settings.toJson());
      expect(restored.fontStyle, ReaderFontStyle.serif);
      expect(restored.fontSize, 19);
      expect(restored.brightness, 0.85);
      expect(restored.themeColor, ReaderThemeColor.sepia);
    });
  });

  group('DateFormatter', () {
    test('formats recent timestamps in Indonesian', () {
      final tenMinsAgo = DateTime.now().subtract(const Duration(minutes: 10));
      expect(DateFormatter.formatTimeAgo(tenMinsAgo), '10 menit yang lalu');
    });

    test('parses RFC 822 +0700 RSS dates accurately', () {
      final parsed = DateFormatter.tryParseRssDate(
        'Sat, 14 Nov 2026 20:52:21 +0700',
      );
      expect(parsed, isNotNull);
      expect(parsed!.toUtc(), DateTime.utc(2026, 11, 14, 13, 52, 21));
    });

    test('parses ISO 8601 dates accurately', () {
      final parsed = DateFormatter.tryParseRssDate('2026-11-15T00:31:04+07:00');
      expect(parsed, isNotNull);
      expect(parsed!.toUtc(), DateTime.utc(2026, 11, 14, 17, 31, 4));
    });
  });
}
