import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/router/player_route_observer.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/moments_bottom_nav.dart';
import 'package:moments/features/player/data/youtube_player_controller_impl.dart';
import 'package:moments/features/player/presentation/mini_player_bar.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Global persistent host for the YouTube IFrame WebView.
///
/// **Architectural Rationale**:
/// WebViews in Flutter are native PlatformViews. Recreating or moving a PlatformView
/// between route widgets tears down the underlying web context and audio engine, causing
/// playback stutter and full video reloads.
///
/// By hosting the single [YoutubePlayer] in this top-level [PersistentPlayerHost], the
/// WebView is created once and NEVER destroyed across tab switches or mini <-> full transitions.
/// It seamlessly morphs between:
/// 1. Mini-player frame (46x46 square thumbnail on the left of [MiniPlayerBar])
/// 2. Full-player frame (16:9 widescreen video at the top of [FullPlayerScreen])
class PersistentPlayerHost extends ConsumerWidget {
  const PersistentPlayerHost({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerPlaybackStateProvider);
    final controller = ref.watch(playerControllerProvider);
    final currentRoute = ref.watch(currentRouteNameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // Route-driven state: player is expanded only on dedicated player routes
    final isExpandedRoute = currentRoute == 'player' || currentRoute == 'create-moment';
    final isShellRoute = currentRoute == null ||
        currentRoute == 'shell' ||
        currentRoute == 'search' ||
        currentRoute == 'moments' ||
        currentRoute == 'groups' ||
        currentRoute == 'profile';

    // Player frame is visible only when expanded or when docked in the shell's MiniPlayerBar
    final shouldShowFrame = isExpandedRoute || isShellRoute;
    final isExpanded = isExpandedRoute;

    // Only render the video player if a video has actually been loaded
    final hasActiveVideo = playerState.videoId != null && playerState.isVisible;

    // Compute geometry for mini-player mode (anchored inside MiniPlayerBar at bottom-left)
    final bottomNavHeight = MomentsBottomNav.barHeight + mediaQuery.padding.bottom;
    final miniBottom = bottomNavHeight + 4.0 + (MiniPlayerBar.height - 46.0) / 2.0;
    const miniLeft = 12.0 + 8.0; // Margin (12) + bar inner padding (8)
    const miniWidth = 46.0;
    const miniHeight = 46.0;

    // Compute geometry for full-player mode (anchored in top half of FullPlayerScreen / MomentCreatorScreen)
    final fullTop = mediaQuery.padding.top + 56.0 + 8.0; // AppBar height + spacing
    const fullLeft = 20.0;
    final fullWidth = screenWidth - (fullLeft * 2);
    final fullHeight = fullWidth * (9.0 / 16.0);

    return Stack(
      children: [
        // 1. Root application UI (all routes, shell, navigators)
        child,

        // 2. Persistent YouTube WebView element
        if (hasActiveVideo && controller is YoutubePlayerControllerImpl)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            top: shouldShowFrame ? (isExpanded ? fullTop : null) : null,
            bottom: shouldShowFrame ? (isExpanded ? null : miniBottom) : -200,
            left: shouldShowFrame ? (isExpanded ? fullLeft : miniLeft) : -200,
            width: isExpanded ? fullWidth : miniWidth,
            height: isExpanded ? fullHeight : miniHeight,
            child: Opacity(
              opacity: shouldShowFrame ? 1.0 : 0.0,
              child: IgnorePointer(
                // Allow gestures on full player; pass gestures through in mini mode or when hidden
                ignoring: !isExpanded || !shouldShowFrame,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(isExpanded ? 18 : 8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(isExpanded ? (isDark ? 90 : 50) : 0),
                      blurRadius: isExpanded ? 24 : 0,
                      offset: Offset(0, isExpanded ? 8 : 0),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => YoutubePlayer(
                        controller: controller.rawController,
                        aspectRatio: isExpanded ? (16 / 9) : 1.0,
                        enableFullScreenOnVerticalDrag: false,
                        autoFullScreen: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
