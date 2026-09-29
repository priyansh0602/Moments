import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/widgets/moments_bottom_nav.dart';
import 'package:moments/features/player/presentation/mini_player_bar.dart';

/// App scaffold shell hosting the persistent tab navigation and mini-player.
///
/// Ensures layout order from bottom to top:
/// [System Navigation] -> [Bottom Nav Bar] -> [Mini-Player Bar] -> [Tab Content].
/// Uses a Column with an Expanded content area so content never overlaps with the bars.
class AppShell extends StatelessWidget {
  /// Creates an [AppShell].
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  /// The stateful navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. Content Area: fills available viewport without overlapping bars
          Expanded(
            child: navigationShell,
          ),

          // 2. Mini-Player Bar: sits directly above the bottom navigation bar
          const MiniPlayerVisibility(
            child: MiniPlayerBar(),
          ),

          // 3. Custom Bottom Navigation Bar: sits at the bottom above system nav
          MomentsBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ],
      ),
    );
  }
}
