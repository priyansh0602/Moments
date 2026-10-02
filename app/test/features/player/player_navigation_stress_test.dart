import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/app.dart';
import 'package:moments/core/router/player_route_observer.dart';
import 'package:moments/core/widgets/moments_bottom_nav.dart';
import 'package:moments/features/auth/presentation/providers/auth_status_provider.dart';
import 'package:moments/features/groups/presentation/groups_screen.dart';
import 'package:moments/features/moments/data/moments_repository.dart';
import 'package:moments/features/moments/domain/models/moment.dart';
import 'package:moments/features/moments/presentation/moment_creator_screen.dart';
import 'package:moments/features/moments/presentation/moment_ready_screen.dart';
import 'package:moments/features/moments/presentation/your_moments_screen.dart';
import 'package:moments/features/player/data/fake_player_controller.dart';
import 'package:moments/features/player/presentation/full_player_screen.dart';
import 'package:moments/features/player/presentation/mini_player_bar.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';
import 'package:moments/features/profile/domain/models/user_profile.dart';
import 'package:moments/features/profile/presentation/profile_screen.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';
import 'package:moments/features/search/presentation/search_screen.dart';

class _FakeProfileNotifier extends CurrentUserProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    return const UserProfile(
      id: 'test-user-id',
      username: 'priyansh',
      displayName: 'Priyansh',
      momentsCount: 47,
    );
  }
}

class _TestPlayerController extends FakePlayerController {
  _TestPlayerController() {
    loadVideo(
      'demo-123',
      title: 'After Dark',
      artist: 'Mr.Kitty',
      duration: const Duration(seconds: 258),
    );
    pause();
  }
}

class _FakeMomentsRepository implements MomentsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Moment> createMoment({
    required String videoId,
    required String title,
    required String artist,
    required String thumbnailUrl,
    required double startSeconds,
    required double endSeconds,
    bool isPublic = true,
  }) async {
    return Moment(
      id: 'test-saved-id-1',
      userId: 'test-user-id',
      videoId: videoId,
      title: title,
      artist: artist,
      thumbnailUrl: thumbnailUrl,
      startSeconds: startSeconds,
      endSeconds: endSeconds,
      isPublic: isPublic,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Moment>> getMyMoments({int limit = 20, int offset = 0}) async {
    return const [];
  }
}

ProviderContainer _createTestContainer(FakePlayerController playerCtrl) {
  return ProviderContainer(
    overrides: [
      authStatusProvider.overrideWithValue(
        const AuthStatusState(
          status: AppAuthStatus.authenticated,
          userId: 'test-user-id',
          username: 'priyansh',
        ),
      ),
      currentUserProfileProvider.overrideWith(
        _FakeProfileNotifier.new,
      ),
      playerControllerProvider.overrideWithValue(playerCtrl),
      momentsRepositoryProvider.overrideWithValue(_FakeMomentsRepository()),
    ],
  );
}

Widget _buildTestApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MomentsApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Player Navigation & Stress-Test Suite', () {
    testWidgets(
      '1. Exact Bug Path: Play -> Full Player -> Creator -> Save -> Ready -> Your Moments collapses cleanly',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final playerCtrl = _TestPlayerController();
        final container = _createTestContainer(playerCtrl);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pumpAndSettle();

        // 1. Initial State: On SearchScreen with mini-player docked
        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);
        expect(container.read(currentRouteNameProvider), 'shell');

        // 2. Open FullPlayerScreen by tapping mini player
        final miniPlayerTitle = find.descendant(
          of: find.byType(MiniPlayerBar),
          matching: find.text('After Dark'),
        );
        await tester.tap(miniPlayerTitle);
        await tester.pumpAndSettle();

        expect(find.byType(FullPlayerScreen), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isTrue);
        expect(container.read(currentRouteNameProvider), 'player');

        // 3. Open MomentCreatorScreen by tapping "Create Moment"
        final trimButton = find.text('Create Moment');
        expect(trimButton, findsOneWidget);
        await tester.tap(trimButton);
        await tester.pumpAndSettle();

        expect(find.byType(MomentCreatorScreen), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isTrue);
        expect(container.read(currentRouteNameProvider), 'create-moment');

        // 4. Save Moment -> lands on MomentReadyScreen
        final saveButton = find.textContaining('Save Moment');
        expect(saveButton, findsOneWidget);
        await tester.ensureVisible(saveButton);
        await tester.pumpAndSettle();
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.byType(MomentReadyScreen), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);
        expect(container.read(currentRouteNameProvider), 'moment-ready');

        // 5. Navigate to "Your Moments" from MomentReadyScreen
        final goToMomentsBtn = find.widgetWithText(FilledButton, 'Go to Your Moments');
        expect(goToMomentsBtn, findsOneWidget);
        await tester.tap(goToMomentsBtn);
        await tester.pumpAndSettle();

        // 6. Verify we are on YourMomentsScreen
        expect(find.byType(YourMomentsScreen), findsOneWidget);
        expect(find.text('Your Moments'), findsOneWidget);

        // 7. CRITICAL BUG CHECK: Verify player is NOT stuck expanded!
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);
        expect(container.read(currentRouteNameProvider), 'shell');

        // MiniPlayerBar is visible at the bottom of the shell
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(find.byType(MomentsBottomNav), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        container.dispose();
      },
    );

    testWidgets(
      '2. Full Player Normal Collapse Button collapses cleanly to mini-player',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final playerCtrl = _TestPlayerController();
        final container = _createTestContainer(playerCtrl);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pumpAndSettle();

        // Open full player
        await tester.tap(find.text('After Dark'));
        await tester.pumpAndSettle();
        expect(find.byType(FullPlayerScreen), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isTrue);

        // Tap collapse button
        final collapseBtn = find.byTooltip('Collapse Player');
        expect(collapseBtn, findsOneWidget);
        await tester.tap(collapseBtn);
        await tester.pumpAndSettle();

        // Collapsed back to SearchScreen
        expect(find.byType(FullPlayerScreen), findsNothing);
        expect(find.byType(SearchScreen), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);
        expect(container.read(currentRouteNameProvider), 'shell');

        await tester.pumpWidget(const SizedBox());
        container.dispose();
      },
    );

    testWidgets(
      '3. Open Moment Creator -> back out WITHOUT saving returns cleanly to Full Player then collapses',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final playerCtrl = _TestPlayerController();
        final container = _createTestContainer(playerCtrl);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pumpAndSettle();

        // Open full player
        await tester.tap(find.text('After Dark'));
        await tester.pumpAndSettle();

        // Open creator
        await tester.tap(find.text('Create Moment'));
        await tester.pumpAndSettle();
        expect(find.byType(MomentCreatorScreen), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isTrue);

        // Back out via AppBar back button WITHOUT saving
        final backBtn = find.byTooltip('Back to Player');
        expect(backBtn, findsOneWidget);
        await tester.tap(backBtn);
        await tester.pumpAndSettle();

        // Should return to FullPlayerScreen
        expect(find.byType(MomentCreatorScreen), findsNothing);
        expect(find.byType(FullPlayerScreen), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isTrue);
        expect(container.read(currentRouteNameProvider), 'player');

        // Now collapse FullPlayerScreen
        await tester.tap(find.byTooltip('Collapse Player'));
        await tester.pumpAndSettle();

        expect(find.byType(FullPlayerScreen), findsNothing);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);
        expect(container.read(currentRouteNameProvider), 'shell');

        await tester.pumpWidget(const SizedBox());
        container.dispose();
      },
    );

    testWidgets(
      '4. Switch all 4 tabs (Search -> Moments -> Groups -> Profile -> Search) retains mini-player',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final playerCtrl = _TestPlayerController();
        final container = _createTestContainer(playerCtrl);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pumpAndSettle();

        // 1. Search tab
        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);

        // 2. Moments tab
        final momentsTab = find.descendant(
          of: find.byType(MomentsBottomNav),
          matching: find.text('Moments'),
        );
        await tester.tap(momentsTab);
        await tester.pumpAndSettle();
        expect(find.byType(YourMomentsScreen), findsOneWidget);
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);

        // 3. Groups tab
        final groupsTab = find.descendant(
          of: find.byType(MomentsBottomNav),
          matching: find.text('Groups'),
        );
        await tester.tap(groupsTab);
        await tester.pumpAndSettle();
        expect(find.byType(GroupsScreen), findsOneWidget);
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);

        // 4. Profile tab
        final profileTab = find.descendant(
          of: find.byType(MomentsBottomNav),
          matching: find.text('Profile'),
        );
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);

        // 5. Back to Search tab
        final searchTab = find.descendant(
          of: find.byType(MomentsBottomNav),
          matching: find.text('Search'),
        );
        await tester.tap(searchTab);
        await tester.pumpAndSettle();
        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);

        await tester.pumpWidget(const SizedBox());
        container.dispose();
      },
    );

    testWidgets(
      '5. Resize and rotation: layout adapts cleanly in both mini and expanded states',
      (tester) async {
        // Portrait mobile size
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final playerCtrl = _TestPlayerController();
        final container = _createTestContainer(playerCtrl);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pumpAndSettle();

        // Rotate to landscape / foldable width
        tester.view.physicalSize = const Size(844, 390);
        await tester.pumpAndSettle();
        expect(find.byType(MiniPlayerBar), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Open full player in landscape
        await tester.tap(find.text('After Dark'));
        await tester.pumpAndSettle();
        expect(find.byType(FullPlayerScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Rotate back to portrait
        tester.view.physicalSize = const Size(390, 844);
        await tester.pumpAndSettle();
        expect(find.byType(FullPlayerScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
        container.dispose();
      },
    );

    testWidgets(
      '6. Initial app launch with no track playing shows sensible state (no stuck frame)',
      (tester) async {
        final idleController = FakePlayerController(); // No video loaded
        final container = _createTestContainer(idleController);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pumpAndSettle();

        // Mini player bar is not visible because isVisible is false
        expect(find.byType(MiniPlayerBar), findsNothing);
        expect(container.read(playerPlaybackStateProvider).isExpanded, isFalse);
        expect(container.read(playerPlaybackStateProvider).videoId, isNull);

        await tester.pumpWidget(const SizedBox());
        container.dispose();
        idleController.dispose();
      },
    );
  });
}
