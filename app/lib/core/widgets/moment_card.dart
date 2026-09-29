import 'package:flutter/material.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/features/moments/domain/models/moment.dart';

/// Card component representing a saved snippet/Moment with time range badge.
class MomentCard extends StatelessWidget {
  /// Creates a [MomentCard].
  const MomentCard({
    required this.moment,
    super.key,
    this.onTap,
    this.onMenuTap,
  });

  /// The moment entity to display.
  final Moment moment;

  /// Callback when the card is tapped to play or view.
  final VoidCallback? onTap;

  /// Callback when the trailing options menu is tapped.
  final VoidCallback? onMenuTap;

  String _formatTime(double totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangeText = '${_formatTime(moment.startSeconds)}–${_formatTime(moment.endSeconds)}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Thumbnail with snippet pulse badge
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(220),
                              AppColors.accent.withAlpha(200),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Artist, and Time Range Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moment.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      moment.artist,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(28),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(80),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timelapse_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rangeText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (moment.tags.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '#${moment.tags.first}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing action menu
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                color: theme.colorScheme.onSurfaceVariant,
                onPressed: onMenuTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Options for "${moment.title}"'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
