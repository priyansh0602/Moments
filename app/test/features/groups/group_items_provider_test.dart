import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:moments/features/groups/domain/models/group_item.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';
import 'package:moments/features/groups/presentation/providers/group_items_provider.dart';
import 'package:moments/features/groups/presentation/providers/my_groups_provider.dart';
import 'package:moments/features/moments/domain/models/moment.dart';

class MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  group('GroupItemsNotifier Tests', () {
    late MockGroupsRepository mockRepository;
    late ProviderContainer container;

    final testMoment1 = Moment(
      id: 'm-1',
      userId: 'u-1',
      videoId: 'vid-1',
      title: 'Midnight City',
      artist: 'M83',
      thumbnailUrl: 'https://img.youtube.com/vi/vid-1/hqdefault.jpg',
      startSeconds: 10.0,
      endSeconds: 30.0,
      createdAt: DateTime.parse('2026-10-01T00:00:00Z'),
    );

    final testMoment2 = Moment(
      id: 'm-2',
      userId: 'u-1',
      videoId: 'vid-2',
      title: 'Resonance',
      artist: 'HOME',
      thumbnailUrl: 'https://img.youtube.com/vi/vid-2/hqdefault.jpg',
      startSeconds: 0.0,
      endSeconds: 20.0,
      createdAt: DateTime.parse('2026-10-02T00:00:00Z'),
    );

    final item1 = GroupItem(
      id: 'gi-1',
      groupId: 'g-1',
      momentId: 'm-1',
      position: 0,
      addedAt: DateTime.parse('2026-10-01T01:00:00Z'),
      moment: testMoment1,
    );

    final item2 = GroupItem(
      id: 'gi-2',
      groupId: 'g-1',
      momentId: 'm-2',
      position: 1,
      addedAt: DateTime.parse('2026-10-01T02:00:00Z'),
      moment: testMoment2,
    );

    setUp(() {
      mockRepository = MockGroupsRepository();
      container = ProviderContainer(
        overrides: [
          groupsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1. loadItems loads items successfully', () async {
      when(() => mockRepository.getGroupItems('g-1'))
          .thenAnswer((_) async => [item1, item2]);

      final notifier = container.read(groupItemsProvider('g-1').notifier);
      await notifier.loadItems();

      final state = container.read(groupItemsProvider('g-1'));
      expect(state.status, GroupItemsStatus.success);
      expect(state.items.length, 2);
      expect(state.items.first.moment.title, 'Midnight City');
    });

    test('2. loadItems sets error status on failure', () async {
      when(() => mockRepository.getGroupItems('g-1'))
          .thenThrow(const GroupsRepositoryException('Failed'));

      final notifier = container.read(groupItemsProvider('g-1').notifier);
      await notifier.loadItems();

      final state = container.read(groupItemsProvider('g-1'));
      expect(state.status, GroupItemsStatus.error);
      expect(state.errorMessage, contains('Failed'));
    });

    test('3. reorder moves item and persists sequential positions', () async {
      when(() => mockRepository.getGroupItems('g-1'))
          .thenAnswer((_) async => [item1, item2]);
      when(() => mockRepository.reorderGroupItems('g-1', ['m-2', 'm-1']))
          .thenAnswer((_) async {});

      final notifier = container.read(groupItemsProvider('g-1').notifier);
      await notifier.loadItems();

      // Moving item from index 0 to after index 1 (newIndex = 2 in Flutter ReorderableListView)
      final success = await notifier.reorder(0, 2);
      expect(success, isTrue);

      final state = container.read(groupItemsProvider('g-1'));
      expect(state.items.first.momentId, 'm-2');
      expect(state.items.first.position, 0);
      expect(state.items.last.momentId, 'm-1');
      expect(state.items.last.position, 1);
    });

    test('4. reorder rolls back on failure', () async {
      when(() => mockRepository.getGroupItems('g-1'))
          .thenAnswer((_) async => [item1, item2]);
      when(() => mockRepository.reorderGroupItems('g-1', any()))
          .thenThrow(const GroupsRepositoryException('Network error'));

      final notifier = container.read(groupItemsProvider('g-1').notifier);
      await notifier.loadItems();

      final success = await notifier.reorder(0, 2);
      expect(success, isFalse);

      final state = container.read(groupItemsProvider('g-1'));
      expect(state.items.first.momentId, 'm-1');
      expect(state.errorMessage, contains('Rolled back'));
    });

    test('5. removeItem removes item optimistically and updates group count', () async {
      when(() => mockRepository.getMyGroups()).thenAnswer((_) async => [
            MomentGroup(
              id: 'g-1',
              userId: 'u-1',
              name: 'Group 1',
              createdAt: DateTime.now(),
              momentCount: 2,
            )
          ]);
      when(() => mockRepository.getGroupItems('g-1'))
          .thenAnswer((_) async => [item1, item2]);
      when(() => mockRepository.removeMomentFromGroup('g-1', 'm-1'))
          .thenAnswer((_) async {});

      // Initialize groups provider
      await container.read(myGroupsProvider.notifier).loadGroups();
      expect(container.read(myGroupsProvider).groups.first.momentCount, 2);

      final notifier = container.read(groupItemsProvider('g-1').notifier);
      await notifier.loadItems();

      final success = await notifier.removeItem('m-1');
      expect(success, isTrue);

      final state = container.read(groupItemsProvider('g-1'));
      expect(state.items.length, 1);
      expect(state.items.first.momentId, 'm-2');

      // Check group count decremented in myGroupsProvider
      expect(container.read(myGroupsProvider).groups.first.momentCount, 1);
    });

    test('6. removeItem rolls back on failure and restores group count', () async {
      when(() => mockRepository.getMyGroups()).thenAnswer((_) async => [
            MomentGroup(
              id: 'g-1',
              userId: 'u-1',
              name: 'Group 1',
              createdAt: DateTime.now(),
              momentCount: 2,
            )
          ]);
      when(() => mockRepository.getGroupItems('g-1'))
          .thenAnswer((_) async => [item1, item2]);
      when(() => mockRepository.removeMomentFromGroup('g-1', 'm-1'))
          .thenThrow(const GroupsRepositoryException('Delete failed'));

      await container.read(myGroupsProvider.notifier).loadGroups();

      final notifier = container.read(groupItemsProvider('g-1').notifier);
      await notifier.loadItems();

      final success = await notifier.removeItem('m-1');
      expect(success, isFalse);

      final state = container.read(groupItemsProvider('g-1'));
      expect(state.items.length, 2);
      expect(container.read(myGroupsProvider).groups.first.momentCount, 2);
      expect(state.errorMessage, contains('Rolled back'));
    });
  });
}
