import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/widgets/app_shell.dart';
import 'package:moments/features/groups/presentation/groups_screen.dart';
import 'package:moments/features/moments/presentation/your_moments_screen.dart';
import 'package:moments/features/player/presentation/full_player_screen.dart';
import 'package:moments/features/profile/presentation/profile_screen.dart';
import 'package:moments/features/search/presentation/search_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Riverpod provider configuring the application GoRouter with stateful tab preservation.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.search,
    routes: [
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
    ],
  );
});
