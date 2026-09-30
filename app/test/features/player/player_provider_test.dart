import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/core/services/audio_handler_service.dart';
import 'package:moments/features/player/data/fake_player_controller.dart';
import 'package:moments/features/player/domain/models/player_playback_state.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';
import 'package:moments/features/search/domain/models/song.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerPlaybackNotifier & PlayerController Tests', () {
    late FakePlayerController fakeController;
    late ProviderContainer container;

    setUp(() {
      fakeController = FakePlayerController();
      container = ProviderContainer(
        overrides: [
          playerControllerProvider.overrideWithValue(fakeController),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      fakeController.dispose();
    });

    test('Initial player state is empty and hidden before any video is loaded', () {
      final state = container.read(playerPlaybackStateProvider);

      expect(state.status, PlaybackStatus.initial);
      expect(state.videoId, isNull);
      expect(state.title, isEmpty);
      expect(state.isVisible, isFalse);
      expect(state.isPlaying, isFalse);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.progress, 0.0);
    });

    test('playSong loads video, sets metadata, and transitions status to playing', () async {
      const song = Song(
        videoId: 'coldplay_yellow',
        title: 'Yellow',
        channelTitle: 'Coldplay',
        thumbnailUrl: 'https://example.com/yellow.jpg',
        durationSeconds: 270,
      );

      await container.read(playerPlaybackStateProvider.notifier).playSong(song);

      final state = container.read(playerPlaybackStateProvider);
      expect(state.videoId, 'coldplay_yellow');
      expect(state.title, 'Yellow');
      expect(state.artist, 'Coldplay');
      expect(state.thumbnailUrl, 'https://example.com/yellow.jpg');
      expect(state.duration, const Duration(seconds: 270));
      expect(state.isVisible, isTrue);
      expect(state.status, PlaybackStatus.playing);
      expect(state.isPlaying, isTrue);
    });

    test('togglePlayPause toggles between playing and paused states', () async {
      const song = Song(
        videoId: 'song_1',
        title: 'Song 1',
        channelTitle: 'Artist 1',
        durationSeconds: 200,
      );

      final notifier = container.read(playerPlaybackStateProvider.notifier);
      await notifier.playSong(song);

      expect(container.read(playerPlaybackStateProvider).isPlaying, isTrue);

      await notifier.togglePlayPause();
      expect(container.read(playerPlaybackStateProvider).status, PlaybackStatus.paused);
      expect(container.read(playerPlaybackStateProvider).isPlaying, isFalse);

      await notifier.togglePlayPause();
      expect(container.read(playerPlaybackStateProvider).status, PlaybackStatus.playing);
      expect(container.read(playerPlaybackStateProvider).isPlaying, isTrue);
    });

    test('seekTo updates position and calculates progress accurately', () async {
      const song = Song(
        videoId: 'song_1',
        title: 'Song 1',
        channelTitle: 'Artist 1',
        durationSeconds: 200,
      );

      final notifier = container.read(playerPlaybackStateProvider.notifier);
      await notifier.playSong(song);

      await notifier.seekTo(100.0); // 100 seconds out of 200 = 50%
      final state = container.read(playerPlaybackStateProvider);

      expect(state.position, const Duration(seconds: 100));
      expect(state.formattedPosition, '01:40');
      expect(state.progress, 0.5);
    });

    test('setExpanded controls full-player modal expansion state', () {
      final notifier = container.read(playerPlaybackStateProvider.notifier);

      expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);

      notifier.setExpanded(true);
      expect(container.read(playerPlaybackStateProvider).isExpanded, isTrue);

      notifier.setExpanded(false);
      expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);
    });

    test('setVisibility controls mini-player bar visibility', () {
      final notifier = container.read(playerPlaybackStateProvider.notifier);

      notifier.setVisibility(true);
      expect(container.read(playerPlaybackStateProvider).isVisible, isTrue);

      notifier.setVisibility(false);
      expect(container.read(playerPlaybackStateProvider).isVisible, isFalse);
    });
  });

  group('MomentsAudioHandler Proxy Media Session Tests', () {
    late MomentsAudioHandler audioHandler;

    setUp(() {
      audioHandler = MomentsAudioHandler();
    });

    tearDown(() async {
      await audioHandler.stop();
    });

    test('audioHandler initializes with idle playback state and default actions', () {
      final state = audioHandler.playbackState.value;
      expect(state.playing, isFalse);
      expect(state.systemActions.contains(MediaAction.seek), isTrue);
    });

    test('audioHandler syncPlaybackState updates system media session state', () {
      audioHandler.syncPlaybackState(
        isPlaying: true,
        isBuffering: false,
        position: const Duration(seconds: 45),
        bufferedPosition: const Duration(seconds: 90),
      );

      final state = audioHandler.playbackState.value;
      expect(state.playing, isTrue);
      expect(state.updatePosition, const Duration(seconds: 45));
      expect(state.bufferedPosition, const Duration(seconds: 90));
      expect(state.speed, 1.0);
    });

    test('audioHandler setTrackMetadata updates system notification metadata', () {
      audioHandler.setTrackMetadata(
        id: 'track_123',
        title: 'Hymn For The Weekend',
        artist: 'Coldplay',
        thumbnailUrl: 'https://example.com/hymn.jpg',
        duration: const Duration(seconds: 260),
      );

      final item = audioHandler.mediaItem.value;
      expect(item?.id, 'track_123');
      expect(item?.title, 'Hymn For The Weekend');
      expect(item?.artist, 'Coldplay');
      expect(item?.duration, const Duration(seconds: 260));
      expect(item?.artUri.toString(), 'https://example.com/hymn.jpg');
    });

    test('audioHandler forwards play, pause, seek callbacks correctly', () async {
      bool playCalled = false;
      bool pauseCalled = false;
      Duration? seekTarget;

      audioHandler.onPlayCallback = () => playCalled = true;
      audioHandler.onPauseCallback = () => pauseCalled = true;
      audioHandler.onSeekCallback = (pos) => seekTarget = pos;

      await audioHandler.play();
      expect(playCalled, isTrue);

      await audioHandler.pause();
      expect(pauseCalled, isTrue);

      await audioHandler.seek(const Duration(seconds: 77));
      expect(seekTarget, const Duration(seconds: 77));
    });
  });
}
