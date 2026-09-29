import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/app.dart';
import 'package:moments/core/widgets/empty_state.dart';
import 'package:moments/core/widgets/moments_bottom_nav.dart';
import 'package:moments/features/auth/presentation/forgot_password_screen.dart';
import 'package:moments/features/auth/presentation/onboarding_username_screen.dart';
import 'package:moments/features/auth/presentation/providers/auth_status_provider.dart';
import 'package:moments/features/auth/presentation/sign_in_screen.dart';
import 'package:moments/features/auth/presentation/sign_up_screen.dart';
import 'package:moments/features/groups/presentation/groups_screen.dart';
import 'package:moments/features/moments/presentation/your_moments_screen.dart';
import 'package:moments/features/player/presentation/full_player_screen.dart';
import 'package:moments/features/player/presentation/mini_player_bar.dart';
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

Widget _buildAuthenticatedApp() {
  return ProviderScope(
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
    ],
    child: const MomentsApp(),
  );
}

void main() {
  group('Phase 3 Auth & Route Guarding Tests', () {
    testWidgets('Unauthenticated user is redirected to SignInScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStatusProvider.overrideWithValue(
              const AuthStatusState(status: AppAuthStatus.unauthenticated),
            ),
          ],
          child: const MomentsApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('User needing onboarding is redirected to OnboardingUsernameScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStatusProvider.overrideWithValue(
              const AuthStatusState(
                status: AppAuthStatus.needsOnboarding,
                userId: 'new-user-id',
                username: 'user_a1b2c',
              ),
            ),
          ],
          child: const MomentsApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingUsernameScreen), findsOneWidget);
      expect(find.text('Pick Your Handle'), findsOneWidget);
      expect(find.text('Complete Setup'), findsOneWidget);
    });

    testWidgets('Can navigate from Sign In to Sign Up and Forgot Password screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStatusProvider.overrideWithValue(
              const AuthStatusState(status: AppAuthStatus.unauthenticated),
            ),
          ],
          child: const MomentsApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Sign Up link
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);

      // Go back to Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);

      // Tap Forgot Password
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
    });

    test('UserProfile isPlaceholderUsername correctly identifies placeholder handles', () {
      const placeholder1 = UserProfile(id: '1', username: 'user_12345');
      const placeholder2 = UserProfile(id: '2', username: 'priyansh_a1b2c');
      const realUser = UserProfile(id: '3', username: 'priyansh06');
      const realUser2 = UserProfile(id: '4', username: 'synth_wave');

      expect(placeholder1.isPlaceholderUsername, isTrue);
      expect(placeholder2.isPlaceholderUsername, isTrue);
      expect(realUser.isPlaceholderUsername, isFalse);
      expect(realUser2.isPlaceholderUsername, isFalse);
    });
  });

  group('Authenticated Shell & Navigation Tests', () {
    testWidgets('App launches on Search tab with bottom nav and mini-player visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildAuthenticatedApp());
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
      await tester.pumpWidget(_buildAuthenticatedApp());
      await tester.pumpAndSettle();

      final miniPlayerRect = tester.getRect(find.byType(MiniPlayerBar));
      final bottomNavRect = tester.getRect(find.byType(MomentsBottomNav));
      final searchScreenRect = tester.getRect(find.byType(SearchScreen));

      // Verify MiniPlayer sits above BottomNav
      expect(miniPlayerRect.bottom <= bottomNavRect.top, isTrue);

      // Verify SearchScreen content sits above MiniPlayer
      expect(searchScreenRect.bottom <= miniPlayerRect.top, isTrue);

      // Verify no vertical overlapping between the 3 elements
      expect(miniPlayerRect.overlaps(bottomNavRect), isFalse);
      expect(searchScreenRect.overlaps(miniPlayerRect), isFalse);
    });

    testWidgets('All 4 tabs are reachable and preserve state across switches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildAuthenticatedApp());
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
      expect(find.text('Priyansh'), findsWidgets);
      expect(find.text('@priyansh'), findsOneWidget);

      // 5. Switch back to Moments tab - verify state was PRESERVED
      await tester.tap(momentsTab);
      await tester.pumpAndSettle();
      expect(find.byType(YourMomentsScreen), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('Tapping mini-player bar navigates to full player and back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildAuthenticatedApp());
      await tester.pumpAndSettle();

      final miniPlayerTitle = find.descendant(
        of: find.byType(MiniPlayerBar),
        matching: find.text('After Dark'),
      );
      await tester.tap(miniPlayerTitle);
      await tester.pumpAndSettle();

      expect(find.byType(FullPlayerScreen), findsOneWidget);
      expect(find.text('Now Playing'), findsOneWidget);

      // Tap collapse / back button
      final collapseBtn = find.byTooltip('Collapse Player');
      expect(collapseBtn, findsOneWidget);
      await tester.tap(collapseBtn);
      await tester.pumpAndSettle();

      expect(find.byType(FullPlayerScreen), findsNothing);
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('Mini-player play/pause button toggles state locally', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildAuthenticatedApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_circle_filled_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.play_circle_filled_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_filled_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_circle_filled_rounded), findsOneWidget);
    });

    testWidgets('App renders correctly in both Dark and Light theme modes', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpWidget(_buildAuthenticatedApp());
      await tester.pumpAndSettle();

      final darkScaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(Scaffold),
        ),
      );
      expect(darkScaffold, isNotNull);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpWidget(_buildAuthenticatedApp());
      await tester.pumpAndSettle();

      final lightScaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(Scaffold),
        ),
      );
      expect(lightScaffold, isNotNull);

      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });
  });
}
