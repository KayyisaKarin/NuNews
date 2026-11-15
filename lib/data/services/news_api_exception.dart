/// NuNews - Typed Network Exception
class NewsApiException implements Exception {
  const NewsApiException(this.message);

  final String message;

  static const NewsApiException offline = NewsApiException(
    'Tidak ada koneksi internet. Periksa jaringan Anda.',
  );

  static const NewsApiException slowConnection = NewsApiException(
    'Koneksi terlalu lambat. Coba tarik untuk menyegarkan lagi.',
  );

  static const NewsApiException serverError = NewsApiException(
    'Gagal memuat berita dari sumber RSS. Coba lagi nanti.',
  );

  @override
  String toString() => message;
}
