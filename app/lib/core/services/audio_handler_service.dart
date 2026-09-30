import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

/// A proxy [AudioHandler] that mirrors the YouTube WebView player's state into the
/// OS media session (Android Notification / iOS Control Center & Lock Screen).
///
/// **Important Architectural Invariant**:
/// This handler does NOT play any audio itself. It acts purely as a two-way state mirror:
/// 1. Outward: It accepts state updates from [PlayerController] and publishes [MediaItem]
///    and [PlaybackState] to the operating system.
/// 2. Inward: It captures OS notification button taps (play, pause, seek) and forwards
///    them directly to the active [PlayerController].
class MomentsAudioHandler extends BaseAudioHandler with SeekHandler {
  VoidCallback? onPlayCallback;
  VoidCallback? onPauseCallback;
  ValueChanged<Duration>? onSeekCallback;

  /// Initializes the audio handler with default empty state.
  MomentsAudioHandler() {
    playbackState.add(
      PlaybackState(
        controls: const [
          MediaControl.rewind,
          MediaControl.play,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [1],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> play() async {
    debugPrint('[MomentsAudioHandler] Forwarding play() from OS notification');
    onPlayCallback?.call();
  }

  @override
  Future<void> pause() async {
    debugPrint('[MomentsAudioHandler] Forwarding pause() from OS notification');
    onPauseCallback?.call();
  }

  @override
  Future<void> seek(Duration position) async {
    debugPrint('[MomentsAudioHandler] Forwarding seek(${position.inSeconds}s) from OS notification');
    onSeekCallback?.call(position);
  }

  @override
  Future<void> stop() async {
    debugPrint('[MomentsAudioHandler] stop() called');
    onPauseCallback?.call();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    await super.stop();
  }

  /// Updates the active media metadata shown on the notification and lock screen.
  void setTrackMetadata({
    required String id,
    required String title,
    required String artist,
    String? thumbnailUrl,
    Duration? duration,
  }) {
    final item = MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: thumbnailUrl != null ? Uri.tryParse(thumbnailUrl) : null,
      duration: duration,
    );
    mediaItem.add(item);
  }

  /// Synchronizes playback state (playing/paused, position, duration) to the OS.
  void syncPlaybackState({
    required bool isPlaying,
    required bool isBuffering,
    required Duration position,
    required Duration bufferedPosition,
  }) {
    final controls = [
      MediaControl.rewind,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.fastForward,
    ];

    final processingState = isBuffering
        ? AudioProcessingState.buffering
        : AudioProcessingState.ready;

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [1],
        processingState: processingState,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: bufferedPosition,
        speed: isPlaying ? 1.0 : 0.0,
      ),
    );
  }
}
