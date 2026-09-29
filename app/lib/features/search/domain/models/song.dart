import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';

/// Immutable representation of a YouTube song search result or track.
@freezed
abstract class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String artist,
    required String thumbnailUrl,
    required int durationSeconds,
  }) = _Song;
}
