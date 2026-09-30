import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/services/audio_handler_provider.dart';
import 'package:moments/features/player/data/fake_player_controller.dart';
import 'package:moments/features/player/data/youtube_player_controller_impl.dart';
import 'package:moments/features/player/domain/models/player_playback_state.dart';
import 'package:moments/features/player/domain/player_controller.dart';
import 'package:moments/features/search/domain/models/song.dart';
/// Provider exposing the singleton [PlayerController] for the application.
///
/// Falls back to [FakePlayerController] if [YoutubePlayerControllerImpl] fails to initialize.
final playerControllerProvider = Provider<PlayerController>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);

  try {
    final controller = YoutubePlayerControllerImpl(audioHandler: audioHandler);
    ref.onDispose(() => controller.dispose());
    return controller;
  } catch (e) {
    debugPrint('[PlayerController] Native init failed, falling back to Fake: $e');
    final fakeController = FakePlayerController();
    ref.onDispose(() => fakeController.dispose());
    return fakeController;
  }
});

/// Riverpod provider managing reactive playback state across the app.
final playerPlaybackStateProvider =
    NotifierProvider<PlayerPlaybackNotifier, PlayerPlaybackState>(
  PlayerPlaybackNotifier.new,
);

/// Notifier driving the player state transitions.
class PlayerPlaybackNotifier extends Notifier<PlayerPlaybackState> {
  StreamSubscription<PlayerPlaybackState>? _sub;

  @override
  PlayerPlaybackState build() {
    final controller = ref.watch(playerControllerProvider);
    _sub?.cancel();
    _sub = controller.stateStream.listen((newState) {
      state = newState;
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return controller.currentState;
  }

  /// Loads and starts playing a [Song] fetched from search or saved moments.
  Future<void> playSong(Song song) async {
    final controller = ref.read(playerControllerProvider);
    final duration = song.durationSeconds != null
        ? Duration(seconds: song.durationSeconds!)
        : null;

    await controller.loadVideo(
      song.videoId,
      title: song.title,
      artist: song.artist,
      thumbnailUrl: song.thumbnailUrl,
      duration: duration,
    );
  }

  /// Toggles play/pause on the active track.
  Future<void> togglePlayPause() async {
    final controller = ref.read(playerControllerProvider);
    if (state.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  /// Seeks to a specific timestamp in [seconds].
  Future<void> seekTo(double seconds) async {
    final controller = ref.read(playerControllerProvider);
    await controller.seekTo(seconds);
  }

  /// Sets whether the full player screen is open.
  void setExpanded(bool expanded) {
    state = state.copyWith(isExpanded: expanded);
    final controller = ref.read(playerControllerProvider);
    if (controller is YoutubePlayerControllerImpl) {
      controller.setExpanded(expanded);
    } else if (controller is FakePlayerController) {
      controller.setExpanded(expanded);
    }
  }

  /// Sets visibility of the mini-player bar.
  void setVisibility(bool visible) {
    state = state.copyWith(isVisible: visible);
    final controller = ref.read(playerControllerProvider);
    if (controller is YoutubePlayerControllerImpl) {
      controller.setVisibility(visible);
    } else if (controller is FakePlayerController) {
      controller.setVisibility(visible);
    }
  }
}
