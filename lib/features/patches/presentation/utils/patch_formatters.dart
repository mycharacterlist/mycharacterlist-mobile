abstract final class PatchFormatters {
  PatchFormatters._();

  static String formatCreatedAt(DateTime createdAt) {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  static String formatReleaseDate(DateTime releaseDate) {
    final day = releaseDate.day.toString().padLeft(2, '0');
    final month = releaseDate.month.toString().padLeft(2, '0');
    final year = releaseDate.year;

    return '$day.$month.$year';
  }

  static DateTime? parseReleaseDate(String value) {
    final parts = value.split('.');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null ||
        month == null ||
        year == null ||
        day < 1 ||
        month < 1 ||
        month > 12) {
      return null;
    }

    final parsed = DateTime(year, month, day);

    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return null;
    }

    return parsed;
  }
}
