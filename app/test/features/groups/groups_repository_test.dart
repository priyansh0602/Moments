import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  group('GroupsRepository Unit Tests with Mocked Supabase', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late GroupsRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);

      repository = GroupsRepository(mockClient);
    });

    test('1. createGroup throws GroupsRepositoryException when user is unauthenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.createGroup(name: 'Late Night'),
        throwsA(isA<GroupsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('User must be authenticated'),
        )),
      );
    });

    test('2. getMyGroups returns empty list when user is unauthenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repository.getMyGroups();
      expect(result, isEmpty);
      verifyNever(() => mockClient.from(any()));
    });

    test('3. updateGroup wraps database exception in GroupsRepositoryException', () async {
      when(() => mockQueryBuilder.update(any())).thenThrow(Exception('DB Error'));

      expect(
        () => repository.updateGroup('g-1', name: 'Renamed'),
        throwsA(isA<GroupsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('Failed to update Group'),
        )),
      );
    });

    test('4. deleteGroup wraps database exception in GroupsRepositoryException', () async {
      when(() => mockQueryBuilder.delete()).thenThrow(Exception('RLS Error'));

      expect(
        () => repository.deleteGroup('g-1'),
        throwsA(isA<GroupsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('Failed to delete Group'),
        )),
      );
    });

    test('5. addMomentToGroup throws MomentAlreadyInGroupException on duplicate key', () async {
      when(() => mockQueryBuilder.select(any())).thenThrow(
        const PostgrestException(
          message: 'duplicate key value violates unique constraint "moment_group_items_group_moment_unique"',
          code: '23505',
        ),
      );

      expect(
        () => repository.addMomentToGroup('g-1', 'm-1'),
        throwsA(isA<MomentAlreadyInGroupException>().having(
          (e) => e.message,
          'message',
          contains('already in this group'),
        )),
      );
    });

    test('6. removeMomentFromGroup wraps database exception in GroupsRepositoryException', () async {
      when(() => mockQueryBuilder.delete()).thenThrow(Exception('Cascade error'));

      expect(
        () => repository.removeMomentFromGroup('g-1', 'm-1'),
        throwsA(isA<GroupsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('Failed to remove Moment from group'),
        )),
      );
    });

    test('7. reorderGroupItems does nothing when orderedMomentIds is empty', () async {
      await repository.reorderGroupItems('g-1', []);
      verifyNever(() => mockClient.from(any()));
    });

    test('8. reorderGroupItems wraps database exception in GroupsRepositoryException', () async {
      when(() => mockQueryBuilder.upsert(any(), onConflict: any(named: 'onConflict')))
          .thenThrow(Exception('Upsert error'));

      expect(
        () => repository.reorderGroupItems('g-1', ['m-1', 'm-2']),
        throwsA(isA<GroupsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('Failed to reorder Group items'),
        )),
      );
    });
  });
}
