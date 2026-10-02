import 'dart:async';
import 'package:moments/features/player/domain/models/player_playback_state.dart';
import 'package:moments/features/player/domain/player_controller.dart';

/// In-memory implementation of [PlayerController] used for headless unit/widget tests
/// or environments where native WebView platforms are unavailable.
class FakePlayerController implements PlayerController {
  final StreamController<PlayerPlaybackState> _stateController =
      StreamController<PlayerPlaybackState>.broadcast();

  PlayerPlaybackState _state = const PlayerPlaybackState();

  @override
  PlayerPlaybackState get currentState => _state;

  @override
  Stream<PlayerPlaybackState> get stateStream => _stateController.stream;

  void _emit(PlayerPlaybackState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  @override
  Future<void> loadVideo(
    String videoId, {
    double? startSeconds,
    double? endSeconds,
    String? title,
    String? artist,
    String? thumbnailUrl,
    Duration? duration,
  }) async {
    final isTrimmed = startSeconds != null && endSeconds != null;
    if (isTrimmed) {
      setPreviewRange(startSeconds: startSeconds, endSeconds: endSeconds, loop: true);
    } else {
      clearPreviewRange();
    }

    _emit(
      _state.copyWith(
        videoId: videoId,
        title: title ?? 'Mock Track',
        artist: artist ?? 'Mock Artist',
        thumbnailUrl: thumbnailUrl,
        duration: duration ?? const Duration(seconds: 240),
        position: Duration(seconds: startSeconds?.round() ?? 0),
        status: PlaybackStatus.playing,
        isVisible: true,
        startSeconds: startSeconds,
        endSeconds: endSeconds,
        clearTrimRange: !isTrimmed,
      ),
    );
  }

  @override
  Future<void> play() async {
    _emit(_state.copyWith(status: PlaybackStatus.playing));
  }

  @override
  Future<void> pause() async {
    _emit(_state.copyWith(status: PlaybackStatus.paused));
  }

  @override
  Future<void> seekTo(double seconds) async {
    final pos = Duration(milliseconds: (seconds * 1000).round());
    _emit(_state.copyWith(position: pos));
  }

  double? previewStartSeconds;
  double? previewEndSeconds;
  bool previewLoop = true;

  @override
  void setPreviewRange({
    double? startSeconds,
    double? endSeconds,
    bool loop = true,
  }) {
    previewStartSeconds = startSeconds;
    previewEndSeconds = endSeconds;
    previewLoop = loop;
  }

  @override
  void clearPreviewRange() {
    previewStartSeconds = null;
    previewEndSeconds = null;
  }

  void setExpanded(bool expanded) {
    _emit(_state.copyWith(isExpanded: expanded));
  }

  void setVisibility(bool visible) {
    _emit(_state.copyWith(isVisible: visible));
  }

  @override
  void dispose() {
    _stateController.close();
  }
}
