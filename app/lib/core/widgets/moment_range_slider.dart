import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/features/moments/domain/models/trim_selection.dart';

/// Interactive dual-handle range slider widget for trimming musical Moments.
///
/// Combines a tactile Material 3 [RangeSlider] with a rhythmic background waveform
/// visualization and playhead indicator.
class MomentRangeSlider extends StatelessWidget {
  const MomentRangeSlider({
    required this.startSeconds,
    required this.endSeconds,
    required this.totalDurationSeconds,
    required this.onRangeChanged,
    this.currentPlaybackSeconds,
    this.onRangeChangeEnd,
    this.isValid = true,
    super.key,
  });

  final double startSeconds;
  final double endSeconds;
  final double totalDurationSeconds;
  final double? currentPlaybackSeconds;
  final void Function(double start, double end) onRangeChanged;
  final void Function(double start, double end)? onRangeChangeEnd;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxDuration = max(1.0, totalDurationSeconds);

    final safeStart = startSeconds.clamp(0.0, maxDuration);
    final safeEnd = endSeconds.clamp(safeStart, maxDuration);

    final activeColor = isValid ? AppColors.primary : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Waveform track container with RangeSlider overlay
        Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isValid
                  ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                  : AppColors.error.withAlpha(120),
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1a. Rhythmic waveform bars
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: _WaveformVisualization(
                      startFraction: safeStart / maxDuration,
                      endFraction: safeEnd / maxDuration,
                      activeColor: activeColor,
                      isDark: isDark,
                    ),
                  ),
                ),

                // 1b. Real-time playhead indicator
                if (currentPlaybackSeconds != null && maxDuration > 0)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final usableWidth = constraints.maxWidth - 32.0; // padding
                      final playheadFraction = (currentPlaybackSeconds! / maxDuration).clamp(0.0, 1.0);
                      final playheadX = 16.0 + (usableWidth * playheadFraction);

                      return Positioned(
                        left: playheadX - 1.5,
                        top: 6,
                        bottom: 6,
                        child: Container(
                          width: 3.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(80),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // 1c. Dual-handle Range Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    activeTrackColor: activeColor,
                    inactiveTrackColor: Colors.white.withAlpha(20),
                    thumbColor: Colors.white,
                    overlayColor: activeColor.withAlpha(40),
                    rangeThumbShape: _MomentRangeThumbShape(
                      activeColor: activeColor,
                    ),
                    rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                  ),
                  child: RangeSlider(
                    values: RangeValues(safeStart, safeEnd),
                    min: 0.0,
                    max: maxDuration,
                    onChanged: (RangeValues values) {
                      onRangeChanged(values.start, values.end);
                    },
                    onChangeEnd: onRangeChangeEnd != null
                        ? (RangeValues values) => onRangeChangeEnd!(values.start, values.end)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 2. Timeline ruler labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '00:00',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                TrimSelection.formatSeconds(maxDuration / 2),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                TrimSelection.formatSeconds(maxDuration),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simulated waveform equalizer bars visualization.
class _WaveformVisualization extends StatelessWidget {
  const _WaveformVisualization({
    required this.startFraction,
    required this.endFraction,
    required this.activeColor,
    required this.isDark,
  });

  final double startFraction;
  final double endFraction;
  final Color activeColor;
  final bool isDark;

  // Preset harmonic pattern for visual rhythm
  static const List<double> _barHeights = [
    0.35, 0.55, 0.85, 0.45, 0.90, 0.70, 0.30, 0.60, 0.80, 0.50,
    0.95, 0.65, 0.40, 0.75, 0.85, 0.35, 0.60, 0.90, 0.55, 0.45,
    0.70, 0.85, 0.30, 0.65, 0.95, 0.50, 0.40, 0.80, 0.75, 0.60,
    0.90, 0.45, 0.35, 0.85, 0.70, 0.55, 0.40, 0.75, 0.90, 0.60,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalBars = _barHeights.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(totalBars, (index) {
            final barFraction = index / (totalBars - 1);
            final isInRange = barFraction >= startFraction && barFraction <= endFraction;
            final heightFactor = _barHeights[index % totalBars];

            return Container(
              width: 3.0,
              height: constraints.maxHeight * heightFactor,
              decoration: BoxDecoration(
                color: isInRange
                    ? activeColor.withAlpha(isDark ? 220 : 180)
                    : (isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(20)),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Custom tactical range slider thumb shape with dual-layer border and grab handle lines.
class _MomentRangeThumbShape extends RangeSliderThumbShape {
  const _MomentRangeThumbShape({
    required this.activeColor,
  });

  final Color activeColor;
  static const double thumbRadius = 12.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    // 1. Drop shadow
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center + const Offset(0, 2), radius: thumbRadius));
    canvas.drawShadow(shadowPath, Colors.black.withAlpha(100), 4.0, true);

    // 2. Outer glowing ring
    final Paint ringPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, ringPaint);

    // 3. Inner solid white thumb
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius - 2.5, innerPaint);

    // 4. Center grip icon / dot
    final Paint dotPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.0, dotPaint);
  }
}
