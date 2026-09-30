import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/primary_button.dart';
import 'package:moments/core/widgets/secondary_button.dart';
import 'package:moments/features/player/presentation/providers/mini_player_provider.dart';
import 'package:moments/features/search/domain/models/song.dart';

/// Screen displaying a selected YouTube song preview.
///
/// Serves as the Phase 4 tappable placeholder route before full IFrame player wiring in Phase 5.
class SelectedSongScreen extends ConsumerWidget {
  /// Creates a [SelectedSongScreen].
  const SelectedSongScreen({
    this.song,
    super.key,
  });

  /// The selected song entity passed from the search list.
  final Song? song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentSong = song ??
        const Song(
          videoId: 'unknown',
          title: 'Unknown Title',
          channelTitle: 'Unknown Artist',
          thumbnailUrl: '',
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Song'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Large Thumbnail Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: currentSong.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          currentSong.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackThumbnail(),
                        )
                      : _buildFallbackThumbnail(),
                ),
              ),
              const SizedBox(height: 24),

              // Song Title
              Text(
                'You selected: ${currentSong.title}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Artist / Channel
              Text(
                currentSong.artist,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Duration Badge
              if (currentSong.durationSeconds != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        currentSong.formattedDuration,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 28),

              // Phase 5 Notification Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Full YouTube IFrame player integration and background playback are coming in Phase 5.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Action: Load in Mini Player
              PrimaryButton(
                label: 'Load into Player',
                isFullWidth: true,
                onPressed: () {
                  ref.read(miniPlayerProvider.notifier).loadTrack(
                        title: currentSong.title,
                        artist: currentSong.artist,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Loaded "${currentSong.title}" into player bar'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  context.pop();
                },
              ),
              const SizedBox(height: 14),

              // Action: Back to Search
              SecondaryButton(
                label: 'Back to Search',
                isFullWidth: true,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 64,
          color: Colors.white70,
        ),
      ),
    );
  }
}
