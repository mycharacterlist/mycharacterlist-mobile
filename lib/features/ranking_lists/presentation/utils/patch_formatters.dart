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
}
