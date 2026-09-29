import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/features/player/presentation/providers/mini_player_provider.dart';

/// Persistent mini-player bar displayed above the bottom navigation bar.
///
/// Reads state from [miniPlayerProvider] and opens the full player route when tapped.
class MiniPlayerBar extends ConsumerWidget {
  /// Creates a [MiniPlayerBar].
  const MiniPlayerBar({super.key});

  /// Height of the mini-player bar itself (excluding progress line).
  static const double height = 62.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(miniPlayerProvider);

    if (!playerState.isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.miniPlayerDarkBg : AppColors.miniPlayerLightBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Playback progress indicator line at the very top of the bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: playerState.progress,
              backgroundColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 2.5,
            ),
          ),

          // Main interactive bar content
          Positioned.fill(
            top: 2.5,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.push(AppRoutes.player);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    // Thumbnail box
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(200),
                              AppColors.accentViolet.withAlpha(220),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and Artist
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerState.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: playerState.isPlaying
                                      ? AppColors.success
                                      : AppColors.darkTextMuted,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${playerState.artist} • ${playerState.currentTimestamp}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Loop mode indicator
                    IconButton(
                      icon: const Icon(Icons.repeat_one_rounded, size: 20),
                      color: AppColors.primary,
                      tooltip: 'Loop snippet',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Loop mode active for current snippet'),
                            duration: Duration(milliseconds: 900),
                          ),
                        );
                      },
                    ),

                    // Play / Pause toggle button
                    IconButton(
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        size: 34,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        ref.read(miniPlayerProvider.notifier).togglePlayPause();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper wrapper allowing Phase 5 to toggle mini-player visibility without restructuring layouts.
class MiniPlayerVisibility extends ConsumerWidget {
  /// Creates a [MiniPlayerVisibility].
  const MiniPlayerVisibility({
    required this.child,
    super.key,
  });

  /// The child widget (typically the [MiniPlayerBar]).
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(miniPlayerProvider.select((s) => s.isVisible));
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    return child;
  }
}
