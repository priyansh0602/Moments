import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moments/core/utils/time_formatter.dart';

part 'moment.freezed.dart';
part 'moment.g.dart';

/// Immutable representation of a saved snippet / Moment in Supabase.
@freezed
abstract class Moment with _$Moment {
  const factory Moment({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'video_id') required String videoId,
    @JsonKey(name: 'song_title') required String title,
    @Default('') String artist,
    @JsonKey(name: 'thumbnail_url') @Default('') String thumbnailUrl,
    @JsonKey(name: 'start_seconds') required double startSeconds,
    @JsonKey(name: 'end_seconds') required double endSeconds,
    @JsonKey(name: 'is_public') @Default(true) bool isPublic,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default(<String>[])
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<String> tags,
  }) = _Moment;

  const Moment._();

  /// Deserializes a [Moment] from Supabase JSON map.
  factory Moment.fromJson(Map<String, dynamic> json) => _$MomentFromJson(json);

  /// Duration of the moment clip in seconds.
  double get clipDurationSeconds =>
      (endSeconds - startSeconds).clamp(0.0, double.infinity);

  /// Formatted start timestamp string (e.g. "01:24").
  String get formattedStart => TimeFormatter.formatSeconds(startSeconds);

  /// Formatted end timestamp string (e.g. "01:52").
  String get formattedEnd => TimeFormatter.formatSeconds(endSeconds);

  /// Formatted duration string for the clip (e.g. "28s" or "28.5s").
  String get formattedClipDuration =>
      TimeFormatter.formatClipDuration(clipDurationSeconds);

  /// Formatted time-range string (e.g. "01:24–01:52").
  String get formattedTimeRange =>
      TimeFormatter.formatRange(startSeconds, endSeconds);
}
