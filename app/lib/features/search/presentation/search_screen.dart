import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/song_card.dart';
import 'package:moments/features/player/presentation/providers/mini_player_provider.dart';
import 'package:moments/features/search/domain/models/song.dart';

/// Screen for searching songs on YouTube to extract snippets / Moments.
class SearchScreen extends ConsumerWidget {
  /// Creates a [SearchScreen].
  const SearchScreen({super.key});

  static const List<Song> _mockSongs = [
    Song(
      id: 'mock-1',
      title: 'After Dark',
      artist: 'Mr.Kitty',
      thumbnailUrl: '',
      durationSeconds: 258,
    ),
    Song(
      id: 'mock-2',
      title: 'Midnight City',
      artist: 'M83',
      thumbnailUrl: '',
      durationSeconds: 244,
    ),
    Song(
      id: 'mock-3',
      title: 'Resonance',
      artist: 'HOME',
      thumbnailUrl: '',
      durationSeconds: 212,
    ),
    Song(
      id: 'mock-4',
      title: 'Nightcall',
      artist: 'Kavinsky',
      thumbnailUrl: '',
      durationSeconds: 259,
    ),
    Song(
      id: 'mock-5',
      title: 'Starboy',
      artist: 'The Weeknd ft. Daft Punk',
      thumbnailUrl: '',
      durationSeconds: 230,
    ),
    Song(
      id: 'mock-6',
      title: 'Space Song',
      artist: 'Beach House',
      thumbnailUrl: '',
      durationSeconds: 320,
    ),
    Song(
      id: 'mock-7',
      title: 'Memory Reboot',
      artist: 'VOJ & Narvent',
      thumbnailUrl: '',
      durationSeconds: 168,
    ),
    Song(
      id: 'mock-8',
      title: 'Chamber of Reflection',
      artist: 'Mac DeMarco',
      thumbnailUrl: '',
      durationSeconds: 231,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top App Bar / Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Moments',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Non-functional mock search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search songs or paste YouTube link...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune_rounded, size: 20),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Pill Tags
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, 'Trending', isSelected: true),
                          _buildFilterChip(context, 'Late Night'),
                          _buildFilterChip(context, 'Synthwave'),
                          _buildFilterChip(context, 'Lo-Fi'),
                          _buildFilterChip(context, 'Memories'),
                          _buildFilterChip(context, 'Instrumental'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'Trending Snippets',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Mock Song List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = _mockSongs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SongCard(
                        song: song,
                        onTap: () {
                          ref.read(miniPlayerProvider.notifier).loadTrack(
                                title: song.title,
                                artist: song.artist,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Loaded "${song.title}" into player'),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        },
                        onTrimTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Trim UI for "${song.title}" (Coming in Phase 6)'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: _mockSongs.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
