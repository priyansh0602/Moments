import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/player/domain/models/mini_player_state.dart';

/// Provider for managing mini-player state.
///
/// Designed to be a drop-in integration point for Phase 5 real audio services.
final miniPlayerProvider =
    NotifierProvider<MiniPlayerNotifier, MiniPlayerState>(
  MiniPlayerNotifier.new,
);

/// State notifier that manages playback presentation for the mini-player.
class MiniPlayerNotifier extends Notifier<MiniPlayerState> {
  @override
  MiniPlayerState build() {
    return const MiniPlayerState(
      title: 'After Dark',
      artist: 'Mr.Kitty',
      isPlaying: false,
      progress: 0.35,
      isVisible: true,
      currentTimestamp: '01:24',
      totalDuration: '04:18',
    );
  }

  /// Toggles the mock play/pause state.
  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  /// Updates seek/playback progress (0.0 to 1.0).
  void setProgress(double value) {
    state = state.copyWith(progress: value.clamp(0.0, 1.0));
  }

  /// Sets mini-player visibility across the app shell.
  void setVisibility(bool visible) {
    state = state.copyWith(isVisible: visible);
  }

  /// Updates currently loaded snippet / track metadata.
  void loadTrack({
    required String title,
    required String artist,
    String? thumbnailUrl,
    String totalDuration = '03:45',
  }) {
    state = state.copyWith(
      title: title,
      artist: artist,
      thumbnailUrl: thumbnailUrl,
      totalDuration: totalDuration,
      progress: 0.0,
      currentTimestamp: '00:00',
    );
  }
}
