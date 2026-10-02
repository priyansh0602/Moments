import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/empty_state.dart';
import 'package:moments/core/widgets/loading_indicator.dart';
import 'package:moments/core/widgets/moment_card.dart';
import 'package:moments/features/moments/domain/models/moment.dart';
import 'package:moments/features/moments/presentation/providers/my_moments_provider.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// Screen displaying the user's saved song snippets / Moments backed by Supabase.
class YourMomentsScreen extends ConsumerStatefulWidget {
  /// Creates a [YourMomentsScreen].
  const YourMomentsScreen({super.key});

  @override
  ConsumerState<YourMomentsScreen> createState() => _YourMomentsScreenState();
}

class _YourMomentsScreenState extends ConsumerState<YourMomentsScreen> {
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(myMomentsProvider.notifier).loadMore();
    }
  }

  Future<void> _confirmDelete(Moment moment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Moment?'),
        content: Text(
          'Are you sure you want to delete "${moment.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(myMomentsProvider.notifier)
          .deleteMoment(moment.id);

      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete Moment. Rolled back.'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${moment.title}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final momentsState = ref.watch(myMomentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Moments'),
      ),
      body: _buildBody(context, momentsState, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MyMomentsState state,
    ThemeData theme,
  ) {
    // 1. Initial loading state
    if (state.isLoading && state.moments.isEmpty) {
      return const LoadingIndicator(
        message: 'Loading your Moments...',
      );
    }

    // 2. Full error state (no cached moments)
    if (state.isError && state.moments.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 54,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load Moments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'An unexpected error occurred.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  ref.read(myMomentsProvider.notifier).loadMoments();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Real Empty state
    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(myMomentsProvider.notifier).loadMoments(isRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No Moments Saved Yet',
              subtitle:
                  'Search for songs on YouTube, trim your favorite timestamped snippet, and loop it anytime.',
              actionLabel: 'Discover Songs',
              onAction: () {
                context.go(AppRoutes.search);
              },
            ),
          ),
        ),
      );
    }

    // 4. Data list with pull-to-refresh and pagination
    return RefreshIndicator(
      onRefresh: () => ref.read(myMomentsProvider.notifier).loadMoments(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: state.moments.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.moments.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          final moment = state.moments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: MomentCard(
              moment: moment,
              onTap: () {
                ref.read(playerPlaybackStateProvider.notifier).playMoment(moment);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playing Moment "${moment.title}" (${moment.formattedTimeRange})'),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
              onDelete: () => _confirmDelete(moment),
            ),
          );
        },
      ),
    );
  }
}
