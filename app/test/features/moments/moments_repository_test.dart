import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moments/features/moments/data/moments_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder {}

void main() {
  group('MomentsRepository Unit Tests with Mocked Supabase', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MomentsRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);

      repository = MomentsRepository(mockClient);
    });

    test('1. createMoment throws MomentsRepositoryException when user is unauthenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.createMoment(
          videoId: 'v-123',
          title: 'Test Song',
          artist: 'Test Artist',
          thumbnailUrl: 'https://thumb.url',
          startSeconds: 10.0,
          endSeconds: 30.0,
        ),
        throwsA(isA<MomentsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('User must be authenticated'),
        )),
      );
    });

    test('2. getMyMoments returns empty list when user is unauthenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repository.getMyMoments();
      expect(result, isEmpty);
      verifyNever(() => mockClient.from(any()));
    });

    test('3. deleteMoment wraps database exception in MomentsRepositoryException', () async {
      when(() => mockQueryBuilder.delete()).thenThrow(Exception('PostgreSQL error 42501'));

      expect(
        () => repository.deleteMoment('moment-id-to-delete'),
        throwsA(isA<MomentsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('Failed to delete Moment'),
        )),
      );
    });

    test('4. updateMoment wraps database exception in MomentsRepositoryException', () async {
      when(() => mockQueryBuilder.update(any())).thenThrow(Exception('Network timeout'));

      expect(
        () => repository.updateMoment(
          'moment-id',
          startSeconds: 12.0,
          endSeconds: 35.0,
          isPublic: false,
        ),
        throwsA(isA<MomentsRepositoryException>().having(
          (e) => e.message,
          'message',
          contains('Failed to update Moment'),
        )),
      );
    });
  });
}
