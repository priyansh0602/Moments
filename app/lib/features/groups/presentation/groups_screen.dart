import 'package:flutter/material.dart';
import 'package:moments/core/widgets/group_card.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';

/// Screen displaying collections and playlists of Moments (Groups).
class GroupsScreen extends StatelessWidget {
  /// Creates a [GroupsScreen].
  const GroupsScreen({super.key});

  static const List<MomentGroup> _mockGroups = [
    MomentGroup(
      id: 'g-1',
      name: 'Late Night Drives',
      momentCount: 14,
      description: 'Atmospheric synthwave and mellow night hooks',
    ),
    MomentGroup(
      id: 'g-2',
      name: 'Gym High Energy',
      momentCount: 8,
      description: 'Adrenaline pumping bass drops and buildups',
    ),
    MomentGroup(
      id: 'g-3',
      name: 'Memories & Nostalgia',
      momentCount: 19,
      description: 'Dreamy acoustic and introspective snippets',
    ),
    MomentGroup(
      id: 'g-4',
      name: 'Focus & Flow State',
      momentCount: 6,
      description: 'Minimalist repetitive rhythm snippets for deep work',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Group',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create Group flow (Coming in Phase 9)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _mockGroups.length,
        itemBuilder: (context, index) {
          final group = _mockGroups[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GroupCard(
              group: group,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening group "${group.name}"'),
                    duration: const Duration(milliseconds: 900),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
