import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/moment_range_slider.dart';
import 'package:moments/features/moments/presentation/providers/trim_selection_provider.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// Screen enabling users to trim a precise musical snippet ("Moment") from the active song.
///
/// Features:
/// - Continuous YouTube WebView playback via top-level [PersistentPlayerHost]
/// - Dual-handle timeline range slider with rhythmic waveform visualization
/// - Instant "Set start here" and "Set end here" position capture buttons
/// - Micro-adjuster steppers (-1s / +1s) for fine-grained millisecond alignment
/// - Active loop preview playing exclusively within the selected boundaries
/// - Real-time validation feedback (minimum 3s, maximum 60s)
class MomentCreatorScreen extends ConsumerStatefulWidget {
  const MomentCreatorScreen({super.key});

  @override
  ConsumerState<MomentCreatorScreen> createState() => _MomentCreatorScreenState();
}

class _MomentCreatorScreenState extends ConsumerState<MomentCreatorScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the persistent player host maintains expanded widescreen video mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerPlaybackStateProvider.notifier).setExpanded(true);
      final playerState = ref.read(playerPlaybackStateProvider);
      ref.read(trimSelectionProvider.notifier).initFromPlayer(playerState);
    });
  }

  @override
  void dispose() {
    // If user navigates away while previewing, halt range loop cleanly
    ref.read(trimSelectionProvider.notifier).stopPreview();
    super.dispose();
  }

  void _onPopInvoked() {
    ref.read(trimSelectionProvider.notifier).stopPreview();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerPlaybackStateProvider);
    final trimState = ref.watch(trimSelectionProvider);
    final trimNotifier = ref.read(trimSelectionProvider.notifier);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final durationSecs = playerState.duration.inSeconds.toDouble();
    final isBufferingDuration = durationSecs <= 0.0;
    final totalSecs = isBufferingDuration ? 240.0 : durationSecs;

    final currentPositionSecs = playerState.position.inMilliseconds / 1000.0;
    final validationError = trimState.validationError;
    final isValid = validationError == null && !isBufferingDuration;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) => _onPopInvoked(),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back to Player',
            onPressed: () {
              _onPopInvoked();
              context.pop();
            },
          ),
          title: Text(
            'Create Moment',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            // Preview Action Icon in AppBar
            IconButton(
              icon: Icon(
                trimState.isPreviewing
                    ? Icons.stop_circle_rounded
                    : Icons.play_circle_fill_rounded,
                color: trimState.isPreviewing ? AppColors.error : AppColors.primary,
              ),
              tooltip: trimState.isPreviewing ? 'Stop Preview' : 'Preview Moment',
              onPressed: () => trimNotifier.togglePreview(),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Video Player Slot (16:9 aspect ratio)
                // PersistentPlayerHost anchors the live YouTube WebView directly over this slot
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

                const SizedBox(height: 16),

                // 2. Track Title & Artist
                Text(
                  trimState.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  trimState.artist,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // 3. Trimmed Range Display Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Start Timestamp
                      _TimestampColumn(
                        label: 'START',
                        formattedTime: trimState.formattedStart,
                        color: AppColors.primary,
                        theme: theme,
                      ),

                      // Connecting Arrow & Duration Pill
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isValid ? AppColors.primary : AppColors.error)
                                  .withAlpha(isDark ? 40 : 25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              trimState.formattedClipDuration,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isValid ? AppColors.primary : AppColors.error,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
                          ),
                        ],
                      ),

                      // End Timestamp
                      _TimestampColumn(
                        label: 'END',
                        formattedTime: trimState.formattedEnd,
                        color: AppColors.primary,
                        theme: theme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Dual-Handle Range Slider
                if (isBufferingDuration)
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading track timeline...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  MomentRangeSlider(
                    startSeconds: trimState.startSeconds,
                    endSeconds: trimState.endSeconds,
                    totalDurationSeconds: totalSecs,
                    currentPlaybackSeconds: currentPositionSecs,
                    isValid: isValid,
                    onRangeChanged: (start, end) {
                      trimNotifier.setRange(start, end);
                    },
                  ),

                const SizedBox(height: 16),

                // 5. Quick-Capture "Set start here" & "Set end here" Buttons
                Row(
                  children: [
                    // Set Start Button
                    Expanded(
                      child: _CaptureButton(
                        icon: Icons.timer_outlined,
                        label: 'Set Start Here',
                        onPressed: () {
                          trimNotifier.captureStartFromCurrent(currentPositionSecs);
                        },
                        theme: theme,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Set End Button
                    Expanded(
                      child: _CaptureButton(
                        icon: Icons.timer_off_outlined,
                        label: 'Set End Here',
                        onPressed: () {
                          trimNotifier.captureEndFromCurrent(currentPositionSecs);
                        },
                        theme: theme,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 6. Micro-Adjustment Stepper Row (-1s / +1s)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Start micro-steppers
                      Row(
                        children: [
                          Text(
                            'Start: ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          _MicroStepper(
                            text: '-1s',
                            onTap: () => trimNotifier.adjustStart(-1.0),
                          ),
                          const SizedBox(width: 4),
                          _MicroStepper(
                            text: '+1s',
                            onTap: () => trimNotifier.adjustStart(1.0),
                          ),
                        ],
                      ),

                      // End micro-steppers
                      Row(
                        children: [
                          Text(
                            'End: ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          _MicroStepper(
                            text: '-1s',
                            onTap: () => trimNotifier.adjustEnd(-1.0),
                          ),
                          const SizedBox(width: 4),
                          _MicroStepper(
                            text: '+1s',
                            onTap: () => trimNotifier.adjustEnd(1.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 7. Validation Banner / Feedback
                if (validationError != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(isDark ? 35 : 20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withAlpha(80),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            validationError,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(isDark ? 30 : 15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withAlpha(60),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Valid clip range (${trimState.formattedClipDuration}) • Ready to preview or save',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // 8. Loop Preview Toggle Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: trimState.isPreviewing
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: 1.2,
                    ),
                    backgroundColor: trimState.isPreviewing
                        ? AppColors.primary.withAlpha(isDark ? 40 : 25)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    trimState.isPreviewing
                        ? Icons.pause_circle_rounded
                        : Icons.all_inclusive_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  label: Text(
                    trimState.isPreviewing ? 'Stop Loop Preview' : 'Loop Preview Moment',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  onPressed: () => trimNotifier.togglePreview(),
                ),

                const SizedBox(height: 12),

                // 9. Save Moment Primary CTA
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: isDark ? Colors.white12 : Colors.black12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isValid
                      ? () {
                          // Log trimmed range per Phase 6 requirements
                          debugPrint(
                            '[MomentCreator] Final Trim: videoId=${trimState.videoId}, '
                            'start=${trimState.startSeconds}s, '
                            'end=${trimState.endSeconds}s, '
                            'duration=${trimState.clipDurationSeconds}s, '
                            'title="${trimState.title}"',
                          );

                          // Halt preview loop before navigating
                          trimNotifier.stopPreview();

                          // Navigate to stub confirmation screen
                          context.push(
                            AppRoutes.momentReady,
                            extra: trimState,
                          );
                        }
                      : null,
                  child: Text(
                    'Save Moment (${trimState.formattedClipDuration})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isValid ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
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

class _TimestampColumn extends StatelessWidget {
  const _TimestampColumn({
    required this.label,
    required this.formattedTime,
    required this.color,
    required this.theme,
  });

  final String label;
  final String formattedTime;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formattedTime,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.theme,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MicroStepper extends StatelessWidget {
  const _MicroStepper({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
