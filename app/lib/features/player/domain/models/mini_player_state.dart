import 'package:freezed_annotation/freezed_annotation.dart';

part 'mini_player_state.freezed.dart';

/// State representation for the persistent mini-player bar and active playback shell.
@freezed
abstract class MiniPlayerState with _$MiniPlayerState {
  const factory MiniPlayerState({
    required String title,
    required String artist,
    String? thumbnailUrl,
    @Default(false) bool isPlaying,
    @Default(0.35) double progress,
    @Default(true) bool isVisible,
    @Default('01:12') String currentTimestamp,
    @Default('03:48') String totalDuration,
  }) = _MiniPlayerState;
}
