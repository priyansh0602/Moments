import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:moments/features/groups/domain/models/moment_group.dart';
import 'package:moments/features/groups/presentation/providers/my_groups_provider.dart';

class MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  group('MyGroupsNotifier Tests', () {
    late MockGroupsRepository mockRepository;
    late ProviderContainer container;

    final testGroup1 = MomentGroup(
      id: 'g-1',
      userId: 'u-1',
      name: 'Late Night Drives',
      description: 'Mellow synthwave',
      createdAt: DateTime.parse('2026-10-01T00:00:00Z'),
      momentCount: 3,
    );

    final testGroup2 = MomentGroup(
      id: 'g-2',
      userId: 'u-1',
      name: 'Gym Hype',
      description: 'Heavy bass',
      createdAt: DateTime.parse('2026-10-02T00:00:00Z'),
      momentCount: 5,
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

    test('1. Initial build triggers loadGroups and transitions to success', () async {
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup1, testGroup2]);

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      final state = container.read(myGroupsProvider);
      expect(state.status, MyGroupsStatus.success);
      expect(state.groups.length, 2);
      expect(state.groups.first.name, 'Late Night Drives');
      expect(state.isEmpty, isFalse);
    });

    test('2. loadGroups sets status to error when repository fails', () async {
      when(() => mockRepository.getMyGroups())
          .thenThrow(const GroupsRepositoryException('Network timeout'));

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      final state = container.read(myGroupsProvider);
      expect(state.status, MyGroupsStatus.error);
      expect(state.errorMessage, contains('Network timeout'));
    });

    test('3. loadGroups handles empty list correctly', () async {
      when(() => mockRepository.getMyGroups()).thenAnswer((_) async => []);

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      final state = container.read(myGroupsProvider);
      expect(state.status, MyGroupsStatus.success);
      expect(state.groups, isEmpty);
      expect(state.isEmpty, isTrue);
    });

    test('4. createGroup prepends newly created group to state', () async {
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup1]);
      when(() => mockRepository.createGroup(
            name: 'Study Session',
            description: any(named: 'description'),
            coverThumbnailUrl: any(named: 'coverThumbnailUrl'),
            isPublic: any(named: 'isPublic'),
          )).thenAnswer((_) async => MomentGroup(
            id: 'g-3',
            userId: 'u-1',
            name: 'Study Session',
            createdAt: DateTime.now(),
            momentCount: 0,
          ));

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      final created = await notifier.createGroup(name: 'Study Session');
      expect(created, isNotNull);
      expect(created!.name, 'Study Session');

      final state = container.read(myGroupsProvider);
      expect(state.groups.length, 2);
      expect(state.groups.first.id, 'g-3');
    });

    test('5. updateGroup updates group optimistically and confirms on success', () async {
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup1]);
      when(() => mockRepository.updateGroup(
            'g-1',
            name: 'Late Night Vibes',
            description: any(named: 'description'),
            coverThumbnailUrl: any(named: 'coverThumbnailUrl'),
            isPublic: any(named: 'isPublic'),
          )).thenAnswer((_) async => testGroup1.copyWith(name: 'Late Night Vibes'));

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      final success = await notifier.updateGroup('g-1', name: 'Late Night Vibes');
      expect(success, isTrue);

      final state = container.read(myGroupsProvider);
      expect(state.groups.first.name, 'Late Night Vibes');
    });

    test('6. updateGroup rolls back on failure', () async {
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup1]);
      when(() => mockRepository.updateGroup(
            'g-1',
            name: any(named: 'name'),
            description: any(named: 'description'),
            coverThumbnailUrl: any(named: 'coverThumbnailUrl'),
            isPublic: any(named: 'isPublic'),
          )).thenThrow(const GroupsRepositoryException('Update failed'));

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      final success = await notifier.updateGroup('g-1', name: 'Should Fail');
      expect(success, isFalse);

      final state = container.read(myGroupsProvider);
      expect(state.groups.first.name, 'Late Night Drives');
      expect(state.errorMessage, contains('Rolled back'));
    });

    test('7. deleteGroup deletes group optimistically and rolls back on failure', () async {
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup1, testGroup2]);
      when(() => mockRepository.deleteGroup('g-1'))
          .thenThrow(const GroupsRepositoryException('Delete failed'));

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      final success = await notifier.deleteGroup('g-1');
      expect(success, isFalse);

      final state = container.read(myGroupsProvider);
      expect(state.groups.length, 2);
      expect(state.errorMessage, contains('Rolled back'));
    });

    test('8. adjustMomentCount modifies momentCount correctly', () async {
      when(() => mockRepository.getMyGroups())
          .thenAnswer((_) async => [testGroup1]);

      final notifier = container.read(myGroupsProvider.notifier);
      await notifier.loadGroups();

      notifier.adjustMomentCount('g-1', 1);
      expect(container.read(myGroupsProvider).groups.first.momentCount, 4);

      notifier.adjustMomentCount('g-1', -10);
      expect(container.read(myGroupsProvider).groups.first.momentCount, 0);
    });
  });
}
