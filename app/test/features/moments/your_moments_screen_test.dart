import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/core/widgets/empty_state.dart';
import 'package:moments/core/widgets/moment_card.dart';
import 'package:moments/features/moments/domain/models/moment.dart';
import 'package:moments/features/moments/presentation/providers/my_moments_provider.dart';
import 'package:moments/features/moments/presentation/your_moments_screen.dart';
import 'package:moments/features/player/data/fake_player_controller.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

class _FakeMyMomentsNotifier extends MyMomentsNotifier {
  _FakeMyMomentsNotifier({required this.initialState});

  final MyMomentsState initialState;

  @override
  MyMomentsState build() {
    return initialState;
  }

  @override
  Future<bool> deleteMoment(String momentId) async {
    state = state.copyWith(
      moments: state.moments.where((m) => m.id != momentId).toList(),
    );
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YourMomentsScreen Widget Tests', () {
    late FakePlayerController fakePlayer;

    setUp(() {
      fakePlayer = FakePlayerController();
    });

    tearDown(() {
      fakePlayer.dispose();
    });

    testWidgets('1. Displays EmptyState when user has zero moments', (tester) async {
      final container = ProviderContainer(
        overrides: [
          myMomentsProvider.overrideWith(
            () => _FakeMyMomentsNotifier(
              initialState: const MyMomentsState(
                status: MyMomentsStatus.success,
                moments: [],
              ),
            ),
          ),
          playerControllerProvider.overrideWithValue(fakePlayer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: YourMomentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No Moments Saved Yet'), findsOneWidget);
      expect(find.text('Discover Songs'), findsOneWidget);
    });

    testWidgets('2. Displays MomentCard list with title, artist, and formatted time range', (tester) async {
      final testMoments = [
        const Moment(
          id: 'm-1',
          userId: 'u-1',
          videoId: 'v-1',
          title: 'Resonance Intro',
          artist: 'HOME',
          thumbnailUrl: '',
          startSeconds: 0.0,
          endSeconds: 32.0,
        ),
        const Moment(
          id: 'm-2',
          userId: 'u-1',
          videoId: 'v-2',
          title: 'Midnight City Sax',
          artist: 'M83',
          thumbnailUrl: '',
          startSeconds: 182.0,
          endSeconds: 215.0,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          myMomentsProvider.overrideWith(
            () => _FakeMyMomentsNotifier(
              initialState: MyMomentsState(
                status: MyMomentsStatus.success,
                moments: testMoments,
              ),
            ),
          ),
          playerControllerProvider.overrideWithValue(fakePlayer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: YourMomentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MomentCard), findsNWidgets(2));
      expect(find.text('Resonance Intro'), findsOneWidget);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('00:00–00:32'), findsOneWidget);

      expect(find.text('Midnight City Sax'), findsOneWidget);
      expect(find.text('M83'), findsOneWidget);
      expect(find.text('03:02–03:35'), findsOneWidget);
    });

    testWidgets('3. Tapping a MomentCard loads video into player with start and end boundaries', (tester) async {
      const moment = Moment(
        id: 'm-play',
        userId: 'u-1',
        videoId: 'yt-play-123',
        title: 'After Dark Hook',
        artist: 'Mr.Kitty',
        thumbnailUrl: 'https://img.youtube.com/vi/yt-play-123/0.jpg',
        startSeconds: 62.0,
        endSeconds: 88.0,
      );

      final container = ProviderContainer(
        overrides: [
          myMomentsProvider.overrideWith(
            () => _FakeMyMomentsNotifier(
              initialState: const MyMomentsState(
                status: MyMomentsStatus.success,
                moments: [moment],
              ),
            ),
          ),
          playerControllerProvider.overrideWithValue(fakePlayer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: YourMomentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the moment card
      await tester.tap(find.text('After Dark Hook'));
      await tester.pumpAndSettle();

      // Verify FakePlayerController received the trimmed range
      final playerState = container.read(playerPlaybackStateProvider);
      expect(playerState.videoId, 'yt-play-123');
      expect(playerState.startSeconds, 62.0);
      expect(playerState.endSeconds, 88.0);
      expect(playerState.isMoment, isTrue);
      expect(fakePlayer.previewStartSeconds, 62.0);
      expect(fakePlayer.previewEndSeconds, 88.0);
      expect(fakePlayer.previewLoop, isTrue);
    });

    testWidgets('4. Deleting a moment: confirmation dialog cancels without deleting, confirm deletes', (tester) async {
      final testMoments = [
        const Moment(
          id: 'm-del-1',
          userId: 'u-1',
          videoId: 'v-1',
          title: 'Snippet To Delete',
          artist: 'Artist',
          startSeconds: 10.0,
          endSeconds: 25.0,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          myMomentsProvider.overrideWith(
            () => _FakeMyMomentsNotifier(
              initialState: MyMomentsState(
                status: MyMomentsStatus.success,
                moments: testMoments,
              ),
            ),
          ),
          playerControllerProvider.overrideWithValue(fakePlayer),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: YourMomentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Snippet To Delete'), findsOneWidget);

      // Open popup menu on MomentCard
      final menuBtn = find.byIcon(Icons.more_vert_rounded);
      expect(menuBtn, findsOneWidget);
      await tester.tap(menuBtn);
      await tester.pumpAndSettle();

      // Tap Delete Moment
      final deleteItem = find.text('Delete Moment');
      expect(deleteItem, findsOneWidget);
      await tester.tap(deleteItem);
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('Delete Moment?'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Snippet To Delete"? This cannot be undone.'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Card still exists
      expect(find.text('Snippet To Delete'), findsOneWidget);

      // Tap delete again
      await tester.tap(menuBtn);
      await tester.pumpAndSettle();
      await tester.tap(deleteItem);
      await tester.pumpAndSettle();

      // Tap Delete (confirm)
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      // Item is removed and EmptyState is rendered
      expect(find.text('Snippet To Delete'), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
    });
  });
}
