/// NuNews - API Constants
/// Endpoint RSS resmi CNN Indonesia, CNBC Indonesia, dan Antara News.
class ApiConstants {
  ApiConstants._();

  static const Duration timeout = Duration(seconds: 15);
  static const Duration cacheTtl = Duration(minutes: 3);

  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'Mozilla/5.0 (compatible; NuNewsApp/1.0)',
    'Accept': 'application/rss+xml, application/xml, text/xml, */*',
  };

  static const String cnnAllRss = 'https://www.cnnindonesia.com/rss';
  static String cnnCategoryRss(String category) =>
      'https://www.cnnindonesia.com/$category/rss';
  static const String cnbcAllRss = 'https://www.cnbcindonesia.com/news/rss';
  static String antaraRss([String type = 'terkini']) =>
      'https://www.antaranews.com/rss/$type.xml';

  static const Set<String> cnnAllowedCategories = {
    'nasional',
    'internasional',
    'ekonomi',
    'olahraga',
    'teknologi',
    'hiburan',
    'gaya-hidup',
  };
}
