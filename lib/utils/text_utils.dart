// Calculate reading time based on content (200 words per minute)
int calculateReadingTime(String htmlContent) {
  // Remove HTML tags
  final plainText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');

  // Count words (split by whitespace)
  final words = plainText
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;

  // Calculate reading time (200 words per minute)
  final readingTime = (words / 200).ceil();

  // Minimum 1 minute
  return readingTime > 0 ? readingTime : 1;
}
