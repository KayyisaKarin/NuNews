/// NuNews - Relative Indonesian Date Formatter (platform-agnostic)
class DateFormatter {
  DateFormatter._();

  static const Map<String, int> _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static final RegExp _rfc822Regex = RegExp(
    r'^(?:[A-Za-z]{3},\s*)?(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})\s+(\d{2}):(\d{2})(?::(\d{2}))?(?:\s*([+-]\d{4}|GMT|UTC|WIB|WITA|WIT))?$',
    caseSensitive: false,
  );

  static DateTime? tryParseRssDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso;

    final match = _rfc822Regex.firstMatch(trimmed);
    if (match == null) return null;

    final day = int.tryParse(match.group(1) ?? '');
    final monthStr = (match.group(2) ?? '').toLowerCase();
    final month = _months[monthStr];
    final year = int.tryParse(match.group(3) ?? '');
    final hour = int.tryParse(match.group(4) ?? '');
    final minute = int.tryParse(match.group(5) ?? '');
    final second = int.tryParse(match.group(6) ?? '0') ?? 0;
    final tzRaw = (match.group(7) ?? 'GMT').toUpperCase();

    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null) {
      return null;
    }

    var offsetMinutes = 0;
    if (tzRaw == 'WIB') {
      offsetMinutes = 7 * 60;
    } else if (tzRaw == 'WITA') {
      offsetMinutes = 8 * 60;
    } else if (tzRaw == 'WIT') {
      offsetMinutes = 9 * 60;
    } else if (tzRaw.startsWith('+') || tzRaw.startsWith('-')) {
      final sign = tzRaw.startsWith('-') ? -1 : 1;
      final oh = int.tryParse(tzRaw.substring(1, 3)) ?? 0;
      final om = int.tryParse(tzRaw.substring(3, 5)) ?? 0;
      offsetMinutes = sign * (oh * 60 + om);
    }

    final utcMillis =
        DateTime.utc(year, month, day, hour, minute, second).millisecondsSinceEpoch -
            offsetMinutes * 60 * 1000;
    return DateTime.fromMillisecondsSinceEpoch(utcMillis, isUtc: true).toLocal();
  }

  static String formatTimeAgo(DateTime? date) {
    if (date == null) return 'Baru saja';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }
}
