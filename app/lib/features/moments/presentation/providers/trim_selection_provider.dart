import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/moments/domain/models/trim_selection.dart';
import 'package:moments/features/player/domain/models/player_playback_state.dart';
import 'package:moments/features/player/domain/player_controller.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// State notifier managing Moment trimming boundaries, range validation, and preview playback.
class TrimSelectionNotifier extends Notifier<TrimSelection> {
  @override
  TrimSelection build() {
    final playerState = ref.read(playerPlaybackStateProvider);
    final totalSecs = max(1.0, playerState.duration.inSeconds.toDouble());
    final currentPos = playerState.position.inSeconds.toDouble();

    final start = currentPos.clamp(0.0, max(0.0, totalSecs - 15.0)).toDouble();
    final end = min(totalSecs, start + 15.0);

    // Re-initialize only if the active video changes, preventing position ticks from wiping user edits
    ref.listen<PlayerPlaybackState>(
      playerPlaybackStateProvider,
      (previous, next) {
        if (previous?.videoId != next.videoId && next.videoId != null && next.videoId!.isNotEmpty) {
          initFromPlayer(next);
        }
      },
    );

    return TrimSelection(
      videoId: playerState.videoId ?? '',
      title: playerState.title.isNotEmpty ? playerState.title : 'Selected Track',
      artist: playerState.artist.isNotEmpty ? playerState.artist : 'YouTube Artist',
      thumbnailUrl: playerState.thumbnailUrl ?? '',
      totalDurationSeconds: totalSecs,
      startSeconds: start,
      endSeconds: end,
      isPreviewing: false,
    );
  }

  /// Re-initializes trim state explicitly from a [PlayerPlaybackState].
  void initFromPlayer(PlayerPlaybackState playerState) {
    final totalSecs = max(1.0, playerState.duration.inSeconds.toDouble());
    final currentPos = playerState.position.inSeconds.toDouble();

    final start = currentPos.clamp(0.0, max(0.0, totalSecs - 15.0)).toDouble();
    final end = min(totalSecs, start + 15.0);

    state = TrimSelection(
      videoId: playerState.videoId ?? '',
      title: playerState.title.isNotEmpty ? playerState.title : 'Selected Track',
      artist: playerState.artist.isNotEmpty ? playerState.artist : 'YouTube Artist',
      thumbnailUrl: playerState.thumbnailUrl ?? '',
      totalDurationSeconds: totalSecs,
      startSeconds: start,
      endSeconds: end,
      isPreviewing: false,
    );
  }

  /// Sets the start boundary in seconds, clamping within bounds.
  void setStart(double newStart) {
    final clampedStart = newStart.clamp(0.0, state.totalDurationSeconds).toDouble();
    double adjustedEnd = state.endSeconds;

    if (clampedStart >= adjustedEnd) {
      adjustedEnd = min(
        state.totalDurationSeconds,
        clampedStart + TrimSelection.minClipSeconds,
      );
    }

    state = state.copyWith(
      startSeconds: clampedStart,
      endSeconds: adjustedEnd,
    );

    _syncPreviewRangeIfActive();
  }

  /// Sets the end boundary in seconds, clamping within bounds.
  void setEnd(double newEnd) {
    final clampedEnd = newEnd.clamp(0.0, state.totalDurationSeconds).toDouble();
    double adjustedStart = state.startSeconds;

    if (clampedEnd <= adjustedStart) {
      adjustedStart = max(0.0, clampedEnd - TrimSelection.minClipSeconds);
    }

    state = state.copyWith(
      startSeconds: adjustedStart,
      endSeconds: clampedEnd,
    );

    _syncPreviewRangeIfActive();
  }

  /// Sets both start and end simultaneously (e.g. from a dual-handle range slider).
  void setRange(double start, double end) {
    final clampedStart = start.clamp(0.0, state.totalDurationSeconds).toDouble();
    final clampedEnd = end.clamp(0.0, state.totalDurationSeconds).toDouble();

    state = state.copyWith(
      startSeconds: min(clampedStart, clampedEnd),
      endSeconds: max(clampedStart, clampedEnd),
    );

    _syncPreviewRangeIfActive();
  }

  /// Captures the current player playback position as the clip's start boundary.
  void captureStartFromCurrent(double currentSeconds) {
    setStart(currentSeconds);
  }

  /// Captures the current player playback position as the clip's end boundary.
  void captureEndFromCurrent(double currentSeconds) {
    setEnd(currentSeconds);
  }

  /// Micro-adjusts the start boundary by [deltaSeconds] (e.g. -1s or +1s).
  void adjustStart(double deltaSeconds) {
    setStart(state.startSeconds + deltaSeconds);
  }

  /// Micro-adjusts the end boundary by [deltaSeconds] (e.g. -1s or +1s).
  void adjustEnd(double deltaSeconds) {
    setEnd(state.endSeconds + deltaSeconds);
  }

  /// Toggles trim section preview playback.
  Future<void> togglePreview() async {
    final controller = ref.read(playerControllerProvider);
    if (state.isPreviewing) {
      await stopPreview();
    } else {
      await startPreview(controller);
    }
  }

  /// Starts previewing the trimmed section in a loop.
  Future<void> startPreview(PlayerController controller) async {
    state = state.copyWith(isPreviewing: true);
    controller.setPreviewRange(
      startSeconds: state.startSeconds,
      endSeconds: state.endSeconds,
      loop: true,
    );
    await controller.seekTo(state.startSeconds);
    await controller.play();
  }

  /// Halts range previewing and restores normal playback behavior.
  Future<void> stopPreview() async {
    final controller = ref.read(playerControllerProvider);
    state = state.copyWith(isPreviewing: false);
    controller.clearPreviewRange();
  }

  void _syncPreviewRangeIfActive() {
    if (state.isPreviewing) {
      final controller = ref.read(playerControllerProvider);
      controller.setPreviewRange(
        startSeconds: state.startSeconds,
        endSeconds: state.endSeconds,
        loop: true,
      );
    }
  }
}

/// Riverpod provider exposing the [TrimSelection] state and notifier.
final trimSelectionProvider =
    NotifierProvider<TrimSelectionNotifier, TrimSelection>(
  TrimSelectionNotifier.new,
);
