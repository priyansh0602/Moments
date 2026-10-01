import 'dart:async';
import 'package:moments/features/player/domain/models/player_playback_state.dart';

/// Abstract contract governing playback of YouTube tracks in Moments.
///
/// Isolates the rest of the application from the underlying WebView/IFrame implementation.
abstract class PlayerController {
  /// Loads and plays a video by its YouTube [videoId].
  ///
  /// [startSeconds] and [endSeconds] are defined to prepare for future Moment trimming (Phase 8+).
  /// In this phase, the full video is played.
  Future<void> loadVideo(
    String videoId, {
    double? startSeconds,
    double? endSeconds,
    String? title,
    String? artist,
    String? thumbnailUrl,
    Duration? duration,
  });

  /// Starts or resumes playback.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Seeks to a specific timestamp in [seconds].
  Future<void> seekTo(double seconds);

  /// Sets boundaries for previewing a trimmed section.
  ///
  /// When playback reaches or crosses [endSeconds], the controller will automatically
  /// seek back to [startSeconds] if [loop] is true, or pause.
  void setPreviewRange({
    double? startSeconds,
    double? endSeconds,
    bool loop = true,
  });

  /// Clears any active preview range boundary restrictions.
  void clearPreviewRange();

  /// Synchronous snapshot of the current playback state.
  PlayerPlaybackState get currentState;

  /// Broadcast stream emitting playback state transitions (play, pause, seek, buffer, etc.).
  Stream<PlayerPlaybackState> get stateStream;

  /// Releases resources, event listeners, and timers.
  void dispose();
}
