import 'package:freezed_annotation/freezed_annotation.dart';

part 'moment.freezed.dart';

/// Immutable representation of a saved snippet / Moment.
@freezed
abstract class Moment with _$Moment {
  const factory Moment({
    required String id,
    required String title,
    required String artist,
    required String thumbnailUrl,
    required double startSeconds,
    required double endSeconds,
    required String songId,
    @Default(<String>[]) List<String> tags,
  }) = _Moment;
}
