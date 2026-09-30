import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';
part 'song.g.dart';

/// Immutable representation of a YouTube song search result.
@freezed
abstract class Song with _$Song {
  /// Creates a [Song].
  const factory Song({
    required String videoId,
    required String title,
    @JsonKey(name: 'channelTitle') required String channelTitle,
    @Default('') String thumbnailUrl,
    int? durationSeconds,
  }) = _Song;

  const Song._();

  /// Alias for backward compatibility with widgets and earlier phases.
  String get id => videoId;

  /// Alias for backward compatibility with widgets expecting artist.
  String get artist => channelTitle;

  /// Formatted duration string (e.g. "03:45", or "--:--" when null).
  String get formattedDuration {
    if (durationSeconds == null) return '--:--';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Deserializes a [Song] from JSON.
  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}
