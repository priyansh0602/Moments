import 'package:equatable/equatable.dart';

/// Current playback lifecycle status of the YouTube player engine.
enum PlaybackStatus {
  /// No video loaded yet.
  initial,

  /// Video is loading or buffering from YouTube.
  buffering,

  /// Video is actively playing.
  playing,

  /// Video is paused.
  paused,

  /// Video playback has reached the end.
  ended,

  /// An error occurred during playback.
  error,
}

/// Immutable state model capturing the current YouTube playback snapshot.
class PlayerPlaybackState extends Equatable {
  const PlayerPlaybackState({
    this.videoId,
    this.title = '',
    this.artist = '',
    this.thumbnailUrl,
    this.status = PlaybackStatus.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.isVisible = false,
    this.isExpanded = false,
    this.errorMessage,
    this.startSeconds,
    this.endSeconds,
  });

  /// The active YouTube video identifier.
  final String? videoId;

  /// Song or video title.
  final String title;

  /// Channel title or artist name.
  final String artist;

  /// High-resolution thumbnail image URL.
  final String? thumbnailUrl;

  /// Optional start boundary if playing a trimmed Moment.
  final double? startSeconds;

  /// Optional end boundary if playing a trimmed Moment.
  final double? endSeconds;

  /// Whether the currently playing item is a trimmed Moment rather than a full track.
  bool get isMoment => startSeconds != null && endSeconds != null;

  /// Current playback status (playing, paused, buffering, etc.).
  final PlaybackStatus status;

  /// Current playback elapsed position.
  final Duration position;

  /// Total video duration.
  final Duration duration;

  /// Buffered duration fraction.
  final Duration bufferedPosition;

  /// Whether the player bar should be visible to the user.
  final bool isVisible;

  /// Whether the full-screen player view is currently expanded.
  final bool isExpanded;

  /// Error message if status is [PlaybackStatus.error].
  final String? errorMessage;

  /// True if the video is currently playing.
  bool get isPlaying => status == PlaybackStatus.playing;

  /// True if the video is currently buffering.
  bool get isBuffering => status == PlaybackStatus.buffering;

  /// Playback progress fraction between 0.0 and 1.0.
  double get progress {
    if (duration.inMilliseconds <= 0) return 0.0;
    final value = position.inMilliseconds / duration.inMilliseconds;
    return value.clamp(0.0, 1.0);
  }

  /// Formatted current position (e.g. "01:23").
  String get formattedPosition => _formatDuration(position);

  /// Formatted total duration (e.g. "03:45").
  String get formattedDuration => _formatDuration(duration);

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    final minsStr = minutes.toString().padLeft(2, '0');
    final secsStr = seconds.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  PlayerPlaybackState copyWith({
    String? videoId,
    String? title,
    String? artist,
    String? thumbnailUrl,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    bool? isVisible,
    bool? isExpanded,
    String? errorMessage,
    double? startSeconds,
    double? endSeconds,
    bool clearTrimRange = false,
  }) {
    return PlayerPlaybackState(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isVisible: isVisible ?? this.isVisible,
      isExpanded: isExpanded ?? this.isExpanded,
      errorMessage: errorMessage ?? this.errorMessage,
      startSeconds: clearTrimRange ? null : (startSeconds ?? this.startSeconds),
      endSeconds: clearTrimRange ? null : (endSeconds ?? this.endSeconds),
    );
  }

  @override
  List<Object?> get props => [
        videoId,
        title,
        artist,
        thumbnailUrl,
        status,
        position,
        duration,
        bufferedPosition,
        isVisible,
        isExpanded,
        errorMessage,
        startSeconds,
        endSeconds,
      ];
}
