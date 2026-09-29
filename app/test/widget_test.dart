import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/app.dart';
import 'package:moments/core/widgets/empty_state.dart';
import 'package:moments/core/widgets/moments_bottom_nav.dart';
import 'package:moments/features/groups/presentation/groups_screen.dart';
import 'package:moments/features/moments/presentation/your_moments_screen.dart';
import 'package:moments/features/player/presentation/full_player_screen.dart';
import 'package:moments/features/player/presentation/mini_player_bar.dart';
import 'package:moments/features/profile/presentation/profile_screen.dart';
import 'package:moments/features/search/presentation/search_screen.dart';

void main() {
  testWidgets('App launches on Search tab with bottom nav and mini-player visible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Search screen is default
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Trending Snippets'), findsOneWidget);

    // Verify MiniPlayerBar is visible with its track info
    expect(find.byType(MiniPlayerBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MiniPlayerBar),
        matching: find.text('After Dark'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Mr.Kitty'), findsWidgets);

    // Verify MomentsBottomNav is visible with all 4 tab labels
    expect(find.byType(MomentsBottomNav), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MomentsBottomNav),
        matching: find.text('Search'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(MomentsBottomNav),
        matching: find.text('Moments'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(MomentsBottomNav),
        matching: find.text('Groups'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(MomentsBottomNav),
        matching: find.text('Profile'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Bottom nav and mini-player coexist without overlapping', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );
    await tester.pumpAndSettle();

    final miniPlayerRect = tester.getRect(find.byType(MiniPlayerBar));
    final bottomNavRect = tester.getRect(find.byType(MomentsBottomNav));
    final searchScreenRect = tester.getRect(find.byType(SearchScreen));

    // Verify MiniPlayer sits above BottomNav
    expect(miniPlayerRect.bottom <= bottomNavRect.top, isTrue,
        reason: 'MiniPlayer bottom (${miniPlayerRect.bottom}) should be at or above BottomNav top (${bottomNavRect.top})');

    // Verify SearchScreen content sits above MiniPlayer
    expect(searchScreenRect.bottom <= miniPlayerRect.top, isTrue,
        reason: 'SearchScreen bottom (${searchScreenRect.bottom}) should be at or above MiniPlayer top (${miniPlayerRect.top})');

    // Verify no vertical overlapping between the 3 elements
    expect(miniPlayerRect.overlaps(bottomNavRect), isFalse,
        reason: 'MiniPlayer and BottomNav must not overlap');
    expect(searchScreenRect.overlaps(miniPlayerRect), isFalse,
        reason: 'SearchScreen and MiniPlayer must not overlap');
  });

  testWidgets('All 4 tabs are reachable and preserve state across switches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initially on Search tab
    expect(find.byType(SearchScreen), findsOneWidget);

    // 2. Switch to Moments tab via bottom nav
    final momentsTab = find.descendant(
      of: find.byType(MomentsBottomNav),
      matching: find.text('Moments'),
    );
    await tester.tap(momentsTab);
    await tester.pumpAndSettle();
    expect(find.byType(YourMomentsScreen), findsOneWidget);
    expect(find.text('After Dark (Drop)'), findsOneWidget);

    // Toggle Empty State in Moments tab to test state preservation
    final emptyToggleFinder = find.byTooltip('Preview Empty State');
    expect(emptyToggleFinder, findsOneWidget);
    await tester.tap(emptyToggleFinder);
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);

    // 3. Switch to Groups tab via bottom nav
    final groupsTab = find.descendant(
      of: find.byType(MomentsBottomNav),
      matching: find.text('Groups'),
    );
    await tester.tap(groupsTab);
    await tester.pumpAndSettle();
    expect(find.byType(GroupsScreen), findsOneWidget);
    expect(find.text('Late Night Drives'), findsOneWidget);

    // 4. Switch to Profile tab via bottom nav
    final profileTab = find.descendant(
      of: find.byType(MomentsBottomNav),
      matching: find.text('Profile'),
    );
    await tester.tap(profileTab);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Priyansh'), findsOneWidget);
    expect(find.text('47'), findsOneWidget);

    // 5. Switch back to Moments tab - verify state was PRESERVED (still in empty state)
    await tester.tap(momentsTab);
    await tester.pumpAndSettle();
    expect(find.byType(YourMomentsScreen), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget,
        reason: 'Moments tab state should be preserved via StatefulShellRoute');

    // Toggle back to list
    final listToggleFinder = find.byTooltip('Show Mock List');
    expect(listToggleFinder, findsOneWidget);
    await tester.tap(listToggleFinder);
    await tester.pumpAndSettle();
    expect(find.text('After Dark (Drop)'), findsOneWidget);
  });

  testWidgets('Tapping mini-player bar navigates to full player and back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on the mini-player bar specifically
    final miniPlayerTitle = find.descendant(
      of: find.byType(MiniPlayerBar),
      matching: find.text('After Dark'),
    );
    await tester.tap(miniPlayerTitle);
    await tester.pumpAndSettle();

    // Verify FullPlayerScreen is opened
    expect(find.byType(FullPlayerScreen), findsOneWidget);
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Full Player Shell • Real YouTube Player in Phase 5'), findsOneWidget);

    // Tap collapse / back button
    final collapseBtn = find.byTooltip('Collapse Player');
    expect(collapseBtn, findsOneWidget);
    await tester.tap(collapseBtn);
    await tester.pumpAndSettle();

    // Verify returned to Search tab with shell visible
    expect(find.byType(FullPlayerScreen), findsNothing);
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.byType(MiniPlayerBar), findsOneWidget);
    expect(find.byType(MomentsBottomNav), findsOneWidget);
  });

  testWidgets('Mini-player play/pause button toggles state locally', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Initially paused (shows play icon)
    expect(find.byIcon(Icons.play_circle_filled_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsNothing);

    // Tap play
    await tester.tap(find.byIcon(Icons.play_circle_filled_rounded));
    await tester.pumpAndSettle();

    // Now playing (shows pause icon)
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_filled_rounded), findsNothing);

    // Tap pause
    await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
    await tester.pumpAndSettle();

    // Now paused again
    expect(find.byIcon(Icons.play_circle_filled_rounded), findsOneWidget);
  });

  testWidgets('App renders correctly in both Dark and Light theme modes', (
    WidgetTester tester,
  ) async {
    // 1. Dark Theme test (default platform brightness dark)
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );
    await tester.pumpAndSettle();

    final darkScaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(SearchScreen),
        matching: find.byType(Scaffold),
      ),
    );
    expect(darkScaffold, isNotNull);

    // 2. Light Theme test (platform brightness light)
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(
      const ProviderScope(
        child: MomentsApp(),
      ),
    );
    await tester.pumpAndSettle();

    final lightScaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(SearchScreen),
        matching: find.byType(Scaffold),
      ),
    );
    expect(lightScaffold, isNotNull);

    // Reset platform brightness
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
  });
}

