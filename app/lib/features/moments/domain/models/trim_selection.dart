import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moments/core/utils/time_formatter.dart';

part 'trim_selection.freezed.dart';
part 'trim_selection.g.dart';

/// Immutable representation of a Moment trim selection.
///
/// Holds the active YouTube track metadata, the chosen [startSeconds] and [endSeconds]
/// boundaries, and playback preview state.
@freezed
abstract class TrimSelection with _$TrimSelection {
  /// Minimum allowed duration for a Moment in seconds.
  ///
  /// Clips shorter than 3 seconds lack musical phrasing and can produce audio clicking
  /// artifacts during rapid loop iterations.
  static const double minClipSeconds = 3.0;

  /// Maximum allowed duration for a Moment in seconds.
  ///
  /// Moments are meant to be concise, punchy highlights (hooks, drops, memorable riffs),
  /// not full-length song re-hosts.
  static const double maxClipSeconds = 60.0;

  const factory TrimSelection({
    required String videoId,
    required String title,
    required String artist,
    @Default('') String thumbnailUrl,
    required double totalDurationSeconds,
    required double startSeconds,
    required double endSeconds,
    @Default(false) bool isPreviewing,
  }) = _TrimSelection;

  const TrimSelection._();

  /// Deserializes a [TrimSelection] from JSON.
  factory TrimSelection.fromJson(Map<String, dynamic> json) =>
      _$TrimSelectionFromJson(json);

  /// Duration of the currently trimmed clip in seconds.
  double get clipDurationSeconds =>
      (endSeconds - startSeconds).clamp(0.0, totalDurationSeconds);

  /// Formatted start timestamp string (e.g. "01:24").
  String get formattedStart => TimeFormatter.formatSeconds(startSeconds);

  /// Formatted end timestamp string (e.g. "01:52").
  String get formattedEnd => TimeFormatter.formatSeconds(endSeconds);

  /// Formatted total song duration string (e.g. "03:45").
  String get formattedTotalDuration => TimeFormatter.formatSeconds(totalDurationSeconds);

  /// Formatted duration string for the clip (e.g. "28s" or "28.5s").
  String get formattedClipDuration => TimeFormatter.formatClipDuration(clipDurationSeconds);

  /// Whether the current trim range satisfies all validation constraints.
  bool get isValid =>
      validateTrim(
        start: startSeconds,
        end: endSeconds,
        totalDuration: totalDurationSeconds,
      ) ==
      null;

  /// Human-readable validation error message, or `null` if valid.
  String? get validationError => validateTrim(
    start: startSeconds,
    end: endSeconds,
    totalDuration: totalDurationSeconds,
  );

  /// Helper to format seconds as `MM:SS`.
  static String formatSeconds(double totalSecs) => TimeFormatter.formatSeconds(totalSecs);
}

/// Pure validation function verifying start and end boundaries for a Moment clip.
///
/// Returns an error message string if invalid, or `null` if valid.
String? validateTrim({
  required double start,
  required double end,
  required double totalDuration,
  double minLength = TrimSelection.minClipSeconds,
  double maxLength = TrimSelection.maxClipSeconds,
}) {
  if (start < 0.0) {
    return 'Start time cannot be negative.';
  }

  if (totalDuration > 0.0 && end > (totalDuration + 0.5)) {
    return 'End time cannot exceed song duration (${TrimSelection.formatSeconds(totalDuration)}).';
  }

  if (end <= start) {
    return 'End time must be after start time.';
  }

  final clipLength = end - start;

  if (clipLength < minLength) {
    return 'Clips must be at least ${minLength.round()} seconds (current: ${clipLength.toStringAsFixed(1)}s).';
  }

  if (clipLength > maxLength) {
    return 'Clips can be at most ${maxLength.round()} seconds — trim it down a bit (current: ${clipLength.toStringAsFixed(1)}s).';
  }

  return null;
}
