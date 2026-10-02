/// Utility functions for formatting time intervals, timestamps, and clip durations.
abstract class TimeFormatter {
  /// Formats seconds into `MM:SS` display format (e.g. 84.0 -> "01:24").
  static String formatSeconds(double totalSecs) {
    if (totalSecs.isNaN || totalSecs.isInfinite || totalSecs < 0) {
      return '00:00';
    }
    final int rounded = totalSecs.round();
    final int minutes = rounded ~/ 60;
    final int seconds = rounded % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats clip duration in seconds into a concise string (e.g. 28.0 -> "28s", 28.5 -> "28.5s").
  static String formatClipDuration(double secs) {
    if (secs.isNaN || secs.isInfinite || secs < 0) {
      return '0s';
    }
    if (secs == secs.roundToDouble()) {
      return '${secs.toInt()}s';
    }
    return '${secs.toStringAsFixed(1)}s';
  }

  /// Formats a time range (e.g. "01:24–01:52").
  static String formatRange(double startSeconds, double endSeconds) {
    return '${formatSeconds(startSeconds)}–${formatSeconds(endSeconds)}';
  }
}
