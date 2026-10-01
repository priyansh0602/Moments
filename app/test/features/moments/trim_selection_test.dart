import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/features/moments/domain/models/trim_selection.dart';
import 'package:moments/features/moments/presentation/providers/trim_selection_provider.dart';
import 'package:moments/features/player/data/fake_player_controller.dart';
import 'package:moments/features/player/domain/models/player_playback_state.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrimSelection Domain & Validation Tests', () {
    test('validateTrim accepts valid clip within [3s, 60s]', () {
      final error = validateTrim(
        start: 10.0,
        end: 25.0,
        totalDuration: 200.0,
      );
      expect(error, isNull);
    });

    test('validateTrim rejects clip shorter than 3 seconds (minClipSeconds)', () {
      final error = validateTrim(
        start: 10.0,
        end: 12.0, // 2s duration
        totalDuration: 200.0,
      );
      expect(error, contains('at least 3 seconds'));
    });

    test('validateTrim accepts exactly 3.0 seconds clip', () {
      final error = validateTrim(
        start: 10.0,
        end: 13.0,
        totalDuration: 200.0,
      );
      expect(error, isNull);
    });

    test('validateTrim rejects clip longer than 60 seconds (maxClipSeconds)', () {
      final error = validateTrim(
        start: 10.0,
        end: 75.0, // 65s duration
        totalDuration: 200.0,
      );
      expect(error, contains('at most 60 seconds'));
    });

    test('validateTrim accepts exactly 60.0 seconds clip', () {
      final error = validateTrim(
        start: 10.0,
        end: 70.0,
        totalDuration: 200.0,
      );
      expect(error, isNull);
    });

    test('validateTrim rejects end <= start', () {
      final errorEqual = validateTrim(
        start: 20.0,
        end: 20.0,
        totalDuration: 200.0,
      );
      expect(errorEqual, contains('End time must be after start time'));

      final errorReversed = validateTrim(
        start: 30.0,
        end: 20.0,
        totalDuration: 200.0,
      );
      expect(errorReversed, contains('End time must be after start time'));
    });

    test('validateTrim rejects negative start time', () {
      final error = validateTrim(
        start: -5.0,
        end: 20.0,
        totalDuration: 200.0,
      );
      expect(error, contains('Start time cannot be negative'));
    });

    test('validateTrim rejects end exceeding total track duration', () {
      final error = validateTrim(
        start: 180.0,
        end: 220.0,
        totalDuration: 200.0,
      );
      expect(error, contains('cannot exceed song duration'));
    });

    test('TrimSelection formatting helpers format accurately', () {
      const selection = TrimSelection(
        videoId: 'video_xyz',
        title: 'Yellow',
        artist: 'Coldplay',
        totalDurationSeconds: 270.0, // 04:30
        startSeconds: 65.0, // 01:05
        endSeconds: 95.0, // 01:35
      );

      expect(selection.formattedStart, '01:05');
      expect(selection.formattedEnd, '01:35');
      expect(selection.formattedTotalDuration, '04:30');
      expect(selection.formattedClipDuration, '30s');
      expect(selection.clipDurationSeconds, 30.0);
      expect(selection.isValid, isTrue);
      expect(selection.validationError, isNull);
    });
  });

  group('TrimSelectionNotifier & Range Clamping Tests', () {
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

    test('initFromPlayer populates initial 15-second selection window', () {
      final notifier = container.read(trimSelectionProvider.notifier);
      notifier.initFromPlayer(
        const PlayerPlaybackState(
          videoId: 'v123',
          title: 'Midnight City',
          artist: 'M83',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          duration: Duration(seconds: 240),
          position: Duration(seconds: 30),
          isVisible: true,
        ),
      );

      final state = container.read(trimSelectionProvider);
      expect(state.videoId, 'v123');
      expect(state.title, 'Midnight City');
      expect(state.artist, 'M83');
      expect(state.totalDurationSeconds, 240.0);
      expect(state.startSeconds, 30.0);
      expect(state.endSeconds, 45.0); // start + 15s default
      expect(state.isValid, isTrue);
    });

    test('setStart adjusts end automatically if start crosses end', () {
      final notifier = container.read(trimSelectionProvider.notifier);
      notifier.initFromPlayer(
        const PlayerPlaybackState(
          videoId: 'v1',
          duration: Duration(seconds: 100),
          position: Duration.zero,
        ),
      );

      // Current start: 0, end: 15. Set start to 20 -> end should auto-push to min(100, 20 + 3) = 23
      notifier.setStart(20.0);
      final state = container.read(trimSelectionProvider);
      expect(state.startSeconds, 20.0);
      expect(state.endSeconds, 23.0);
      expect(state.isValid, isTrue);
    });

    test('setEnd adjusts start automatically if end crosses start', () {
      final notifier = container.read(trimSelectionProvider.notifier);
      notifier.initFromPlayer(
        const PlayerPlaybackState(
          videoId: 'v1',
          duration: Duration(seconds: 100),
          position: Duration(seconds: 40),
        ),
      );

      // Current start: 40, end: 55. Set end to 35 -> start should auto-pull to max(0, 35 - 3) = 32
      notifier.setEnd(35.0);
      final state = container.read(trimSelectionProvider);
      expect(state.startSeconds, 32.0);
      expect(state.endSeconds, 35.0);
      expect(state.isValid, isTrue);
    });

    test('micro-adjusters (-1s / +1s) nudge boundaries', () {
      final notifier = container.read(trimSelectionProvider.notifier);
      notifier.initFromPlayer(
        const PlayerPlaybackState(
          videoId: 'v1',
          duration: Duration(seconds: 100),
          position: Duration(seconds: 20),
        ),
      );

      // Initial: 20 -> 35
      notifier.adjustStart(1.0);
      expect(container.read(trimSelectionProvider).startSeconds, 21.0);

      notifier.adjustStart(-1.0);
      expect(container.read(trimSelectionProvider).startSeconds, 20.0);

      notifier.adjustEnd(1.0);
      expect(container.read(trimSelectionProvider).endSeconds, 36.0);

      notifier.adjustEnd(-1.0);
      expect(container.read(trimSelectionProvider).endSeconds, 35.0);
    });

    test('startPreview and stopPreview configure controller preview boundaries', () async {
      final notifier = container.read(trimSelectionProvider.notifier);
      notifier.initFromPlayer(
        const PlayerPlaybackState(
          videoId: 'v1',
          duration: Duration(seconds: 100),
          position: Duration(seconds: 10),
        ),
      );

      notifier.setRange(15.0, 30.0);
      await notifier.startPreview(fakeController);

      expect(container.read(trimSelectionProvider).isPreviewing, isTrue);
      expect(fakeController.previewStartSeconds, 15.0);
      expect(fakeController.previewEndSeconds, 30.0);
      expect(fakeController.previewLoop, isTrue);

      await notifier.stopPreview();
      expect(container.read(trimSelectionProvider).isPreviewing, isFalse);
      expect(fakeController.previewStartSeconds, isNull);
      expect(fakeController.previewEndSeconds, isNull);
    });
  });
}
