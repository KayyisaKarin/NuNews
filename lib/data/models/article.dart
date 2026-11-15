/// NuNews - Article Data Model
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    required this.category,
    required this.categorySlug,
    required this.authorName,
    required this.imageUrl,
    required this.publishedAt,
    required this.readTimeMinutes,
    required this.likesCount,
    required this.commentsCount,
    this.isFeatured = false,
    this.isPopular = false,
    this.isTrending = false,
    this.sourceUrl,
  });

  final String id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String category;
  final String categorySlug;
  final String authorName;
  final String imageUrl;
  final String publishedAt;
  final int readTimeMinutes;
  final int likesCount;
  final int commentsCount;
  final bool isFeatured;
  final bool isPopular;
  final bool isTrending;
  final String? sourceUrl;

  Article copyWith({
    bool? isFeatured,
  }) {
    return Article(
      id: id,
      title: title,
      slug: slug,
      summary: summary,
      content: content,
      category: category,
      categorySlug: categorySlug,
      authorName: authorName,
      imageUrl: imageUrl,
      publishedAt: publishedAt,
      readTimeMinutes: readTimeMinutes,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular,
      isTrending: isTrending,
      sourceUrl: sourceUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'summary': summary,
        'content': content,
        'category': category,
        'categorySlug': categorySlug,
        'authorName': authorName,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt,
        'readTimeMinutes': readTimeMinutes,
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'isFeatured': isFeatured,
        'isPopular': isPopular,
        'isTrending': isTrending,
        'sourceUrl': sourceUrl,
      };

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'Nasional',
      categorySlug: json['categorySlug'] as String? ?? 'nasional',
      authorName: json['authorName'] as String? ?? 'Redaksi NuNews',
      imageUrl: json['imageUrl'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? 'Baru saja',
      readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt() ?? 3,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 150,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 10,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Article && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
