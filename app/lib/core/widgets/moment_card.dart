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
    this.onDelete,
  });

  /// The moment entity to display.
  final Moment moment;

  /// Callback when the card is tapped to play or view.
  final VoidCallback? onTap;

  /// Callback when the trailing options menu is tapped.
  final VoidCallback? onMenuTap;

  /// Callback when the delete option is triggered.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangeText = moment.formattedTimeRange;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Thumbnail with snippet play badge
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (moment.thumbnailUrl.isNotEmpty)
                        Image.network(
                          moment.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.black26,
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      else
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
                      // Subtle playback hint overlay
                      Container(
                        color: Colors.black.withAlpha(50),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
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
                      moment.artist.isNotEmpty ? moment.artist : 'Unknown Artist',
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
              if (onMenuTap != null)
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  color: theme.colorScheme.onSurfaceVariant,
                  onPressed: onMenuTap,
                )
              else if (onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Delete Moment',
                            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  color: theme.colorScheme.onSurfaceVariant,
                  onPressed: () {
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
