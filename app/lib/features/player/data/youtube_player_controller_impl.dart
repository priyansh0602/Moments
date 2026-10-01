import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:moments/core/services/audio_handler_service.dart';
import 'package:moments/features/player/domain/models/player_playback_state.dart';
import 'package:moments/features/player/domain/player_controller.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Concrete implementation of [PlayerController] driving playback through
/// [YoutubePlayerController] (HTML5 IFrame API inside a WebView) and proxying
/// state to [MomentsAudioHandler].
class YoutubePlayerControllerImpl implements PlayerController {
  YoutubePlayerControllerImpl({
    MomentsAudioHandler? audioHandler,
  }) : _audioHandler = audioHandler {
    _initController();
    _bindAudioHandler();
  }

  final MomentsAudioHandler? _audioHandler;
  late final YoutubePlayerController _youtubeController;

  final StreamController<PlayerPlaybackState> _stateController =
      StreamController<PlayerPlaybackState>.broadcast();

  PlayerPlaybackState _state = const PlayerPlaybackState();
  StreamSubscription<YoutubePlayerValue>? _playerSub;
  StreamSubscription<YoutubeVideoState>? _videoStateSub;
  Timer? _positionPollTimer;

  /// Underlying raw [YoutubePlayerController] used strictly to render the single
  /// persistent [YoutubePlayer] widget in the UI host.
  YoutubePlayerController get rawController => _youtubeController;

  @override
  PlayerPlaybackState get currentState => _state;

  @override
  Stream<PlayerPlaybackState> get stateStream => _stateController.stream;

  void _initController() {
    _youtubeController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        enableCaption: false,
        strictRelatedVideos: true,
      ),
    );

    // Listen to YouTube player status changes (playing, paused, buffering, ended)
    _playerSub = _youtubeController.stream.listen(_handlePlayerValueChange);

    // Listen to video position / buffering updates from the IFrame
    _videoStateSub =
        _youtubeController.videoStateStream.listen(_handleVideoStateChange);
  }

  void _bindAudioHandler() {
    if (_audioHandler == null) return;
    _audioHandler.onPlayCallback = () => play();
    _audioHandler.onPauseCallback = () => pause();
    _audioHandler.onSeekCallback = (pos) => seekTo(pos.inSeconds.toDouble());
  }

  void _handlePlayerValueChange(YoutubePlayerValue value) {
    PlaybackStatus newStatus = _state.status;

    switch (value.playerState) {
      case PlayerState.playing:
        newStatus = PlaybackStatus.playing;
        _startPositionPolling();
        break;
      case PlayerState.paused:
        newStatus = PlaybackStatus.paused;
        _stopPositionPolling();
        break;
      case PlayerState.buffering:
        newStatus = PlaybackStatus.buffering;
        break;
      case PlayerState.ended:
        newStatus = PlaybackStatus.ended;
        _stopPositionPolling();
        break;
      case PlayerState.unStarted:
      case PlayerState.cued:
        newStatus = PlaybackStatus.buffering;
        break;
      case PlayerState.unknown:
        break;
    }

    if (value.hasError) {
      newStatus = PlaybackStatus.error;
    }

    _updateState(
      _state.copyWith(
        status: newStatus,
        errorMessage: value.hasError ? 'Playback error (${value.error})' : null,
      ),
    );
  }

  double? _previewStartSeconds;
  double? _previewEndSeconds;
  bool _previewLoop = true;

  void _handleVideoStateChange(YoutubeVideoState videoState) {
    if (_state.duration == Duration.zero) {
      _fetchDuration();
    }

    _updateState(
      _state.copyWith(
        position: videoState.position,
        bufferedPosition: Duration(
          milliseconds: (_state.duration.inMilliseconds * videoState.loadedFraction).round(),
        ),
      ),
    );

    _checkPreviewBoundary(videoState.position);
  }

  void _startPositionPolling() {
    _positionPollTimer?.cancel();
    _positionPollTimer = Timer.periodic(const Duration(milliseconds: 250), (_) async {
      try {
        final seconds = await _youtubeController.currentTime;
        if (seconds > 0) {
          final pos = Duration(milliseconds: (seconds * 1000).round());
          if (pos != _state.position) {
            _updateState(_state.copyWith(position: pos));
            _checkPreviewBoundary(pos);
          }
        }
      } catch (_) {
        // Ignored during transitions
      }
    });
  }

  void _checkPreviewBoundary(Duration pos) {
    if (_previewEndSeconds != null && _previewStartSeconds != null) {
      final currentSeconds = pos.inMilliseconds / 1000.0;
      if (currentSeconds >= _previewEndSeconds!) {
        if (_previewLoop) {
          seekTo(_previewStartSeconds!);
          play();
        } else {
          pause();
          clearPreviewRange();
        }
      }
    }
  }

  void _stopPositionPolling() {
    _positionPollTimer?.cancel();
    _positionPollTimer = null;
  }

  Future<void> _fetchDuration() async {
    try {
      final totalSeconds = await _youtubeController.duration;
      if (totalSeconds > 0) {
        final dur = Duration(seconds: totalSeconds.round());
        _updateState(_state.copyWith(duration: dur));
      }
    } catch (_) {}
  }

  void _updateState(PlayerPlaybackState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
    _syncWithAudioHandler();
  }

  void _syncWithAudioHandler() {
    if (_audioHandler == null || _state.videoId == null) return;

    _audioHandler.syncPlaybackState(
      isPlaying: _state.isPlaying,
      isBuffering: _state.isBuffering,
      position: _state.position,
      bufferedPosition: _state.bufferedPosition,
    );
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
    debugPrint('[PlayerController] Loading video $videoId ("$title" by "$artist")');

    _updateState(
      _state.copyWith(
        videoId: videoId,
        title: title ?? _state.title,
        artist: artist ?? _state.artist,
        thumbnailUrl: thumbnailUrl ?? _state.thumbnailUrl,
        duration: duration ?? _state.duration,
        position: Duration.zero,
        status: PlaybackStatus.buffering,
        isVisible: true,
      ),
    );

    // Update OS notification metadata immediately
    _audioHandler?.setTrackMetadata(
      id: videoId,
      title: title ?? 'Playing Track',
      artist: artist ?? 'YouTube',
      thumbnailUrl: thumbnailUrl,
      duration: duration,
    );

    await _youtubeController.loadVideoById(
      videoId: videoId,
      startSeconds: startSeconds,
      endSeconds: endSeconds,
    );

    // Attempt to play immediately
    await _youtubeController.playVideo();
  }

  @override
  Future<void> play() async {
    await _youtubeController.playVideo();
  }

  @override
  Future<void> pause() async {
    await _youtubeController.pauseVideo();
  }

  @override
  Future<void> seekTo(double seconds) async {
    final newPos = Duration(milliseconds: (seconds * 1000).round());
    _updateState(_state.copyWith(position: newPos));
    await _youtubeController.seekTo(seconds: seconds, allowSeekAhead: true);
  }

  @override
  void setPreviewRange({
    double? startSeconds,
    double? endSeconds,
    bool loop = true,
  }) {
    _previewStartSeconds = startSeconds;
    _previewEndSeconds = endSeconds;
    _previewLoop = loop;
  }

  @override
  void clearPreviewRange() {
    _previewStartSeconds = null;
    _previewEndSeconds = null;
  }

  /// Sets whether the full-screen player is expanded.
  void setExpanded(bool expanded) {
    _updateState(_state.copyWith(isExpanded: expanded));
  }

  /// Sets visibility of the mini-player bar.
  void setVisibility(bool visible) {
    _updateState(_state.copyWith(isVisible: visible));
  }

  @override
  void dispose() {
    _stopPositionPolling();
    _playerSub?.cancel();
    _videoStateSub?.cancel();
    _youtubeController.close();
    _stateController.close();
  }
}
