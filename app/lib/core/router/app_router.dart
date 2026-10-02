import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/router/player_route_observer.dart';
import 'package:moments/core/widgets/app_shell.dart';
import 'package:moments/features/auth/presentation/onboarding_username_screen.dart';
import 'package:moments/features/auth/presentation/providers/auth_status_provider.dart';
import 'package:moments/features/auth/presentation/sign_in_screen.dart';
import 'package:moments/features/auth/presentation/splash_screen.dart';
import 'package:moments/features/groups/presentation/groups_screen.dart';
import 'package:moments/features/moments/domain/models/moment.dart';
import 'package:moments/features/moments/presentation/moment_creator_screen.dart';
import 'package:moments/features/moments/presentation/moment_ready_screen.dart';
import 'package:moments/features/moments/presentation/your_moments_screen.dart';
import 'package:moments/features/player/presentation/full_player_screen.dart';
import 'package:moments/features/profile/presentation/edit_profile_screen.dart';
import 'package:moments/features/profile/presentation/profile_screen.dart';
import 'package:moments/features/search/domain/models/song.dart';
import 'package:moments/features/search/presentation/search_screen.dart';
import 'package:moments/features/search/presentation/selected_song_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Riverpod provider configuring the application GoRouter with auth gating and tab preservation.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStatusNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    observers: [
      PlayerRouteObserver(ref),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStatusProvider);
      final location = state.matchedLocation;

      final isAuthRoute = location == AppRoutes.signIn;
      final isSplash = location == AppRoutes.splash;

      debugPrint(
        '[GoRouter redirect] location: "$location", '
        'status: ${authState.status}, '
        'user: ${authState.userId}',
      );

      // 1. Session is resolving on app boot or during post-OAuth profile fetch
      if (authState.isLoading) {
        if (isSplash || isAuthRoute) return null;
        return AppRoutes.splash;
      }

      // 2. Unauthenticated user
      if (authState.isUnauthenticated) {
        if (isAuthRoute) return null;
        return AppRoutes.signIn;
      }

      // 3. Authenticated user (routes directly into main shell without blocking onboarding)
      if (authState.isAuthenticated || authState.needsOnboarding) {
        if (isAuthRoute || isSplash) {
          return AppRoutes.search;
        }
      }

      return null;
    },
    routes: [
      // Splash / Session Resolution Screen
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const SplashScreen(),
        ),
      ),

      // Auth Route (Google OAuth)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.signIn,
        name: 'sign-in',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const SignInScreen(),
        ),
      ),

      // Onboarding Route (optional, reachable from Profile / direct)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.onboardingUsername,
        name: 'onboarding-username',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          name: state.name,
          child: const OnboardingUsernameScreen(),
        ),
      ),

      // Edit Profile Route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.editProfile,
        name: 'edit-profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          name: state.name,
          child: const EditProfileScreen(),
        ),
      ),

      // Selected Song Preview Route (Phase 4 placeholder)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.songPreview,
        name: 'song-preview',
        pageBuilder: (context, state) {
          final song = state.extra as Song?;
          return MaterialPage(
            key: state.pageKey,
            name: state.name,
            child: SelectedSongScreen(song: song),
          );
        },
      ),

      // Stateful shell branch route preserving state across all 4 bottom tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SearchScreen(),
                ),
              ),
            ],
          ),

          // Branch 1: Your Moments
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.moments,
                name: 'moments',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: YourMomentsScreen(),
                ),
              ),
            ],
          ),

          // Branch 2: Groups
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.groups,
                name: 'groups',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: GroupsScreen(),
                ),
              ),
            ],
          ),

          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Top-level full player modal route (outside the tab shell)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.player,
        name: 'player',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const FullPlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        ),
      ),

      // Moment Creator Screen (Phase 6)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.createMoment,
        name: 'create-moment',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          name: state.name,
          child: const MomentCreatorScreen(),
        ),
      ),

      // Moment Ready Confirmation Screen (Phase 7)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.momentReady,
        name: 'moment-ready',
        pageBuilder: (context, state) {
          final moment = state.extra as Moment;
          return MaterialPage(
            key: state.pageKey,
            name: state.name,
            child: MomentReadyScreen(moment: moment),
          );
        },
      ),
    ],
  );
});
