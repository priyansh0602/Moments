import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/empty_state.dart';
import 'package:moments/core/widgets/loading_indicator.dart';
import 'package:moments/core/widgets/song_card.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';
import 'package:moments/features/search/presentation/providers/search_provider.dart';

/// Screen for searching songs on YouTube via Supabase Edge Function to extract snippets / Moments.
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates a [SearchScreen].
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedCategory;

  static const List<String> _categories = [
    'Trending',
    'Late Night',
    'Synthwave',
    'Lo-Fi',
    'Memories',
    'Instrumental',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.text = category;
    });
    ref.read(searchProvider.notifier).executeSearch(category);
  }

  void _clearSearch() {
    setState(() {
      _selectedCategory = null;
      _searchController.clear();
    });
    ref.read(searchProvider.notifier).onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header with App Title, Search Input, and Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo & Title
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
                          child: const Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
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

                    // Active Search Input Field
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() {
                          if (value != _selectedCategory) {
                            _selectedCategory = null;
                          }
                        });
                        ref.read(searchProvider.notifier).onQueryChanged(value);
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          ref.read(searchProvider.notifier).executeSearch(value);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search songs or artist on YouTube...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: _clearSearch,
                                tooltip: 'Clear Search',
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Category Filter Tags
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () => _onCategorySelected(category),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : theme.colorScheme.outline.withAlpha(60),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Results header text
                    if (searchState.isSuccess && searchState.songs.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Results for "${searchState.query}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (searchState.isCached)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.accent.withAlpha(90),
                                ),
                              ),
                              child: Text(
                                'Cached',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Dynamic State View
            if (searchState.isInitial) ...[
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_rounded,
                  title: 'Search YouTube Music',
                  subtitle:
                      'Type any song or artist name to discover tracks and create loopable Moments.',
                ),
              ),
            ] else if (searchState.isLoading) ...[
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: LoadingIndicator(
                    message: 'Searching YouTube Music...',
                    size: 36,
                  ),
                ),
              ),
            ] else if (searchState.isError) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Search Failed',
                  subtitle: searchState.errorMessage ??
                      'Unable to complete search request.',
                  actionLabel: 'Try Again',
                  onAction: () => ref.read(searchProvider.notifier).retry(),
                ),
              ),
            ] else if (searchState.isEmpty) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.music_off_rounded,
                  title: 'No Songs Found',
                  subtitle:
                      'No matches found for "${searchState.query}". Try a different spelling or artist.',
                ),
              ),
            ] else if (searchState.songs.isNotEmpty) ...[
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = searchState.songs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: SongCard(
                          song: song,
                          onTap: () {
                            ref
                                .read(playerPlaybackStateProvider.notifier)
                                .playSong(song);
                          },
                          onTrimTap: () async {
                            await ref
                                .read(playerPlaybackStateProvider.notifier)
                                .playSong(song);
                            if (context.mounted) {
                              context.push(AppRoutes.createMoment);
                            }
                          },
                        ),
                      );
                    },
                    childCount: searchState.songs.length,
                  ),
                ),
              ),

              // Bottom Pagination Loading Indicator
              if (searchState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
