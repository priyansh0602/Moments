import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/player/domain/models/mini_player_state.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// Legacy compatibility provider mapping real [playerPlaybackStateProvider] into [MiniPlayerState].
final miniPlayerProvider =
    NotifierProvider<MiniPlayerNotifier, MiniPlayerState>(
  MiniPlayerNotifier.new,
);

/// State notifier that bridges [playerPlaybackStateProvider] into [MiniPlayerState].
class MiniPlayerNotifier extends Notifier<MiniPlayerState> {
  @override
  MiniPlayerState build() {
    final realState = ref.watch(playerPlaybackStateProvider);

    return MiniPlayerState(
      title: realState.title.isNotEmpty ? realState.title : 'No Song Playing',
      artist: realState.artist.isNotEmpty ? realState.artist : 'YouTube',
      thumbnailUrl: realState.thumbnailUrl,
      isPlaying: realState.isPlaying,
      progress: realState.progress,
      isVisible: realState.isVisible,
      currentTimestamp: realState.formattedPosition,
      totalDuration: realState.formattedDuration,
    );
  }

  /// Toggles playback on the active YouTube player.
  void togglePlayPause() {
    ref.read(playerPlaybackStateProvider.notifier).togglePlayPause();
  }

  /// Updates seek/playback progress.
  void setProgress(double value) {
    final realState = ref.read(playerPlaybackStateProvider);
    final targetSecs = (value * realState.duration.inSeconds).clamp(0.0, realState.duration.inSeconds.toDouble());
    ref.read(playerPlaybackStateProvider.notifier).seekTo(targetSecs);
  }

  /// Sets mini-player visibility across the app shell.
  void setVisibility(bool visible) {
    ref.read(playerPlaybackStateProvider.notifier).setVisibility(visible);
  }

  /// Updates currently loaded snippet / track metadata.
  void loadTrack({
    required String title,
    required String artist,
    String? thumbnailUrl,
    String totalDuration = '03:45',
  }) {
    // Kept for backward-compatibility in mock testing
  }
}
