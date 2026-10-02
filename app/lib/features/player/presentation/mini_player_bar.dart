import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// Persistent mini-player bar displayed above the bottom navigation bar.
///
/// Reads state from [playerPlaybackStateProvider] and opens the full player route when tapped.
class MiniPlayerBar extends ConsumerWidget {
  /// Creates a [MiniPlayerBar].
  const MiniPlayerBar({super.key});

  /// Height of the mini-player bar itself (excluding progress line).
  static const double height = 62.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerPlaybackStateProvider);

    if (!playerState.isVisible || playerState.videoId == null) {
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ref.read(playerPlaybackStateProvider.notifier).setExpanded(true);
                  context.push(AppRoutes.player);
                },
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    // Video slot placeholder (the live YoutubePlayer from PersistentPlayerHost sits directly over this)
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: playerState.thumbnailUrl != null
                          ? Image.network(
                              playerState.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.music_note_rounded,
                                color: Colors.white70,
                                size: 24,
                              ),
                            )
                          : const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white70,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Title and Artist
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (playerState.isMoment) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(isDark ? 50 : 30),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.primary.withAlpha(120),
                                      width: 0.7,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.timelapse_rounded,
                                        size: 10,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'MOMENT',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Expanded(
                                child: Text(
                                  playerState.title.isNotEmpty ? playerState.title : 'Loading Track...',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
                                      : (playerState.isBuffering
                                          ? AppColors.primary
                                          : AppColors.darkTextMuted),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  playerState.isBuffering
                                      ? 'Buffering...'
                                      : '${playerState.artist} • ${playerState.formattedPosition}',
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

                    // Play / Pause toggle button
                    IconButton(
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                      onPressed: () {
                        ref.read(playerPlaybackStateProvider.notifier).togglePlayPause();
                      },
                    ),
                  ],
                ),
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
    final isVisible = ref.watch(
      playerPlaybackStateProvider.select((s) => s.isVisible && s.videoId != null),
    );
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    return child;
  }
}
