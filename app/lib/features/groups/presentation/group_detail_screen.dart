import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/loading_indicator.dart';
import 'package:moments/features/groups/domain/models/group_item.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';
import 'package:moments/features/groups/presentation/providers/group_items_provider.dart';
import 'package:moments/features/groups/presentation/providers/my_groups_provider.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// Screen displaying the ordered moments of a specific [MomentGroup].
///
/// Supports drag-and-drop reordering, removing moments from the group,
/// editing group details, and deleting the group.
class GroupDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [GroupDetailScreen].
  const GroupDetailScreen({
    required this.group,
    super.key,
  });

  /// The group being viewed.
  final MomentGroup group;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final myGroupsState = ref.watch(myGroupsProvider);

    // Watch latest group data from myGroupsProvider if available
    final currentGroup = myGroupsState.groups.firstWhere(
      (g) => g.id == widget.group.id,
      orElse: () => widget.group,
    );

    final itemsState = ref.watch(groupItemsProvider(currentGroup.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentGroup.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Group Options',
            onSelected: (value) {
              if (value == 'edit') {
                _showEditGroupDialog(context, currentGroup);
              } else if (value == 'delete') {
                _confirmDeleteGroup(context, currentGroup);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Group'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 20, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Delete Group',
                        style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildContent(context, currentGroup, itemsState),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MomentGroup currentGroup,
    GroupItemsState itemsState,
  ) {
    final theme = Theme.of(context);

    if (itemsState.isLoading && itemsState.items.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (itemsState.isError && itemsState.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                itemsState.errorMessage ?? 'Failed to load group items',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => ref
                    .read(groupItemsProvider(currentGroup.id).notifier)
                    .loadItems(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Group Header Info
        _buildGroupHeader(context, currentGroup, itemsState.items.length),

        const Divider(height: 1),

        // Items list or Empty state
        Expanded(
          child: itemsState.isEmpty
              ? _buildEmptyState(context)
              : _buildReorderableList(context, currentGroup, itemsState.items),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    MomentGroup group,
    int itemCount,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: Text(
                  '$itemCount ${itemCount == 1 ? 'Moment' : 'Moments'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (group.description != null && group.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              group.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(20),
              ),
              child: const Icon(
                Icons.playlist_add_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Moments in this group yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Moments to this group from Your Moments or while saving a newly trimmed clip.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.moments),
              icon: const Icon(Icons.bookmark_border_rounded),
              label: const Text('Browse Your Moments'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableList(
    BuildContext context,
    MomentGroup currentGroup,
    List<GroupItem> items,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 80.0),
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        ref
            .read(groupItemsProvider(currentGroup.id).notifier)
            .reorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          key: ValueKey(item.id),
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildGroupItemCard(context, currentGroup, item, index),
        );
      },
    );
  }

  Widget _buildGroupItemCard(
    BuildContext context,
    MomentGroup group,
    GroupItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final moment = item.moment;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Play the trimmed Moment preview via PlayerController
          ref.read(playerPlaybackStateProvider.notifier).playMoment(moment);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: AppColors.darkTextMuted,
                    size: 24,
                  ),
                ),
              ),

              // Thumbnail with play overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (moment.thumbnailUrl.isNotEmpty)
                        Image.network(
                          moment.thumbnailUrl,
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultThumbnail(),
                        )
                      else
                        _buildDefaultThumbnail(),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, Artist & Time Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moment.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      moment.artist.isNotEmpty
                          ? moment.artist
                          : 'Unknown Artist',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            moment.formattedTimeRange,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Remove from Group Option
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.darkTextSecondary, size: 20),
                tooltip: 'Item options',
                onSelected: (value) {
                  if (value == 'remove') {
                    _confirmRemoveItem(context, group, item);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline_rounded,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Remove from Group',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: const Center(
        child: Icon(Icons.music_note, color: AppColors.primary, size: 24),
      ),
    );
  }

  void _confirmRemoveItem(
    BuildContext context,
    MomentGroup group,
    GroupItem item,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from Group?'),
        content: Text(
          'Remove "${item.moment.title}" from "${group.name}"?\n\n'
          'The Moment will still remain saved in Your Moments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(dialogContext).pop();
              final success = await ref
                  .read(groupItemsProvider(group.id).notifier)
                  .removeItem(item.momentId);
              if (!mounted) return;
              if (!success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to remove Moment from group.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, MomentGroup group) {
    final nameController = TextEditingController(text: group.name);
    final descController = TextEditingController(text: group.description ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g. Late Night Drives',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g. Atmospheric synthwave hooks',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(dialogContext).pop();
              final success = await ref
                  .read(myGroupsProvider.notifier)
                  .updateGroup(
                    group.id,
                    name: newName,
                    description: descController.text.trim(),
                  );
              if (!mounted) return;
              if (!success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update group details.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, MomentGroup group) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Text(
          'Are you sure you want to delete "${group.name}"?\n\n'
          'All Moments in this collection will remain safe in Your Moments, '
          'but this group will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              Navigator.of(dialogContext).pop();
              final success = await ref
                  .read(myGroupsProvider.notifier)
                  .deleteGroup(group.id);
              if (!mounted) return;
              if (success) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Group "${group.name}" deleted.'),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete group.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Group'),
          ),
        ],
      ),
    );
  }
}
