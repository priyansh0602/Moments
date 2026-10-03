import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/loading_indicator.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';
import 'package:moments/features/groups/presentation/providers/group_items_provider.dart';
import 'package:moments/features/groups/presentation/providers/my_groups_provider.dart';
import 'package:moments/features/moments/domain/models/moment.dart';

/// Modal bottom sheet allowing users to add a [Moment] to an existing or new [MomentGroup].
class AddToGroupSheet extends ConsumerStatefulWidget {
  /// Creates an [AddToGroupSheet].
  const AddToGroupSheet({
    required this.moment,
    super.key,
  });

  /// The moment to add to a group.
  final Moment moment;

  /// Convenience static helper to display the sheet.
  static Future<void> show(BuildContext context, Moment moment) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToGroupSheet(moment: moment),
    );
  }

  @override
  ConsumerState<AddToGroupSheet> createState() => _AddToGroupSheetState();
}

class _AddToGroupSheetState extends ConsumerState<AddToGroupSheet> {
  String? _addingToGroupId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupsState = ref.watch(myGroupsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add to Group',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.moment.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showCreateGroupDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Group'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Group list
          if (groupsState.isLoading && groupsState.groups.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: LoadingIndicator(),
            )
          else if (groupsState.groups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(Icons.folder_open_rounded,
                      size: 44, color: AppColors.darkTextMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No Groups Found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your first collection to organize your Moments.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showCreateGroupDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create New Group'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: groupsState.groups.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  indent: 64,
                ),
                itemBuilder: (context, index) {
                  final group = groupsState.groups[index];
                  final isAdding = _addingToGroupId == group.id;

                  return ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.queue_music_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${group.momentCount} ${group.momentCount == 1 ? 'Moment' : 'Moments'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.primary),
                    onTap: isAdding ? null : () => _addToGroup(group),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addToGroup(MomentGroup group) async {
    setState(() => _addingToGroupId = group.id);

    try {
      final repository = ref.read(groupsRepositoryProvider);
      final item = await repository.addMomentToGroup(
        group.id,
        widget.moment.id,
      );

      // Adjust moment count on group
      ref.read(myGroupsProvider.notifier).adjustMomentCount(group.id, 1);

      // If group items provider was active, add item
      ref.read(groupItemsProvider(group.id).notifier).addItem(item);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to "${group.name}"'),
          ),
        );
      }
    } on MomentAlreadyInGroupException {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This Moment is already in "${group.name}".'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _addingToGroupId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to group: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g. Late Night, Gym Hype',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
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
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              Navigator.of(dialogContext).pop();
              final created = await ref
                  .read(myGroupsProvider.notifier)
                  .createGroup(
                    name: name,
                    description: descController.text.trim(),
                  );

              if (created != null && mounted) {
                // Add the moment to the newly created group directly
                await _addToGroup(created);
              }
            },
            child: const Text('Create & Add'),
          ),
        ],
      ),
    );
  }
}
