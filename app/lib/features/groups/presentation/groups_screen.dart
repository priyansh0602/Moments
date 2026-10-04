import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/group_card.dart';
import 'package:moments/core/widgets/loading_indicator.dart';
import 'package:moments/features/groups/presentation/providers/my_groups_provider.dart';

/// Screen displaying collections and playlists of Moments (Groups) backed by Supabase.
class GroupsScreen extends ConsumerWidget {
  /// Creates a [GroupsScreen].
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Group',
            onPressed: () => _showCreateGroupDialog(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Group'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(context, ref, groupsState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MyGroupsState state,
  ) {
    final theme = Theme.of(context);

    // Initial / loading state
    if (state.isLoading && state.groups.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    // Error state
    if (state.isError && state.groups.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Failed to load Groups',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () =>
                    ref.read(myGroupsProvider.notifier).loadGroups(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(myGroupsProvider.notifier).loadGroups(isRefresh: true),
        color: AppColors.primary,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
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
                          Icons.folder_special_outlined,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Groups Yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Organize your favorite Moments into custom collections like "Late Night", "Gym Hype", or "Road Trip".',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _showCreateGroupDialog(context, ref),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create First Group'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Populated list
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(myGroupsProvider.notifier).loadGroups(isRefresh: true),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 80.0),
        itemCount: state.groups.length,
        itemBuilder: (context, index) {
          final group = state.groups[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GroupCard(
              group: group,
              onTap: () {
                context.push(AppRoutes.groupDetail, extra: group);
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        Future<void> submit() async {
          final name = nameController.text.trim();
          debugPrint('[CreateGroup] submit called with name: "$name"');
          if (name.isEmpty) return;

          Navigator.of(dialogContext).pop();
          final created = await ref
              .read(myGroupsProvider.notifier)
              .createGroup(
                name: name,
                description: descController.text.trim(),
              );

          if (created != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Group "${created.name}" created!')),
            );
          }
        }

        return AlertDialog(
          title: const Text('Create Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('create_group_name_input'),
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'e.g. Late Night, Gym Hype',
                ),
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submit(),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('create_group_desc_input'),
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g. Energetic bass drops and hooks',
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
              key: const ValueKey('create_group_submit_button'),
              onPressed: submit,
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
