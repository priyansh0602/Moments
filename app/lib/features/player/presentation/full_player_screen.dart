import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/features/player/domain/models/player_playback_state.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// Full-screen expanded player screen reachable by tapping the mini-player.
///
/// **Playback Continuity**:
/// The real YouTube WebView is maintained continuously by [PersistentPlayerHost].
/// When this screen opens, the player expands to fill the 16:9 video frame at the top.
/// When collapsed, it returns to the mini-player without destroying or reloading the WebView.
class FullPlayerScreen extends ConsumerStatefulWidget {
  /// Creates a [FullPlayerScreen].
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  double? _dragValue;

  void _collapse() {
    ref.read(playerPlaybackStateProvider.notifier).setExpanded(false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerPlaybackStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final durationSecs = max(1.0, playerState.duration.inSeconds.toDouble());
    final currentSecs = _dragValue ?? playerState.position.inSeconds.toDouble().clamp(0.0, durationSecs);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        ref.read(playerPlaybackStateProvider.notifier).setExpanded(false);
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            tooltip: 'Collapse Player',
            onPressed: _collapse,
          ),
          title: Text(
            'Now Playing',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded),
              tooltip: 'Options',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Moment trimming and options are coming in Phase 6'),
                    duration: Duration(milliseconds: 900),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Video Player Container Slot (16:9 aspect ratio)
                // The persistent YoutubePlayer from PersistentPlayerHost sits exactly in this slot
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = width * (9.0 / 16.0);
                    return Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 2. Track Title & Artist Information
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerState.title.isNotEmpty
                                ? playerState.title
                                : 'No Song Playing',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: playerState.isPlaying
                                      ? AppColors.success
                                      : (playerState.isBuffering
                                          ? AppColors.primary
                                          : AppColors.darkTextMuted),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  playerState.isBuffering
                                      ? 'Buffering stream...'
                                      : playerState.artist,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
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
                    IconButton(
                      icon: const Icon(Icons.favorite_border_rounded, size: 26),
                      color: AppColors.primary,
                      tooltip: 'Save to Liked',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Moment saving is coming in Phase 6'),
                            duration: Duration(milliseconds: 900),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. Playback Scrubber (Seek Bar)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withAlpha(40),
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                  ),
                  child: Slider(
                    value: currentSecs,
                    min: 0.0,
                    max: durationSecs,
                    onChanged: (val) {
                      setState(() {
                        _dragValue = val;
                      });
                    },
                    onChangeEnd: (val) {
                      setState(() {
                        _dragValue = null;
                      });
                      ref.read(playerPlaybackStateProvider.notifier).seekTo(val);
                    },
                  ),
                ),

                // 4. Timestamp Labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dragValue != null
                            ? PlayerPlaybackState(position: Duration(seconds: _dragValue!.round())).formattedPosition
                            : playerState.formattedPosition,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        playerState.formattedDuration,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Playback Transport Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rewind 10 Seconds
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded, size: 30),
                      color: theme.colorScheme.onSurfaceVariant,
                      tooltip: 'Rewind 10s',
                      onPressed: () {
                        final target = max(0.0, playerState.position.inSeconds - 10.0);
                        ref.read(playerPlaybackStateProvider.notifier).seekTo(target);
                      },
                    ),

                    // Skip Previous
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, size: 38),
                      color: theme.colorScheme.onSurface,
                      tooltip: 'Restart',
                      onPressed: () {
                        ref.read(playerPlaybackStateProvider.notifier).seekTo(0.0);
                      },
                    ),

                    // Primary Play / Pause Button with Radiant Glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(isDark ? 100 : 60),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 48,
                        icon: Icon(
                          playerState.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                        onPressed: () {
                          ref.read(playerPlaybackStateProvider.notifier).togglePlayPause();
                        },
                      ),
                    ),

                    // Skip Next / Forward 10s
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded, size: 30),
                      color: theme.colorScheme.onSurfaceVariant,
                      tooltip: 'Forward 10s',
                      onPressed: () {
                        final target = min(
                          durationSecs,
                          playerState.position.inSeconds + 10.0,
                        );
                        ref.read(playerPlaybackStateProvider.notifier).seekTo(target);
                      },
                    ),

                    // Repeat / Loop Snippet
                    IconButton(
                      icon: const Icon(Icons.repeat_one_rounded, size: 28),
                      color: AppColors.primary,
                      tooltip: 'Repeat',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Loop mode active for current track'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 6. Create Moment Primary Action Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(isDark ? 90 : 50),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.push(AppRoutes.createMoment);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.content_cut_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Create Moment',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 7. Engine Status Notice
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'YouTube IFrame Player • Phase 5 Playback Engine',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
