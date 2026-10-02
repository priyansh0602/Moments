import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/features/moments/data/moments_repository.dart';
import 'package:moments/features/moments/domain/models/moment.dart';
import 'package:moments/features/moments/presentation/providers/my_moments_provider.dart';

class MockMomentsRepository implements MomentsRepository {
  MockMomentsRepository({
    this.momentsToReturn,
    this.createToReturn,
    this.errorToThrow,
    this.deleteErrorToThrow,
  });

  List<Moment>? momentsToReturn;
  Moment? createToReturn;
  Exception? errorToThrow;
  Exception? deleteErrorToThrow;

  int getMyMomentsCallCount = 0;
  int deleteCallCount = 0;
  String? lastDeletedId;
  int? lastLimit;
  int? lastOffset;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Moment>> getMyMoments({int limit = 20, int offset = 0}) async {
    getMyMomentsCallCount++;
    lastLimit = limit;
    lastOffset = offset;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return momentsToReturn ??
        List.generate(
          5,
          (i) => Moment(
            id: 'm-$i',
            userId: 'user-1',
            videoId: 'v-$i',
            title: 'Song $i',
            artist: 'Artist $i',
            thumbnailUrl: 'https://img.youtube.com/vi/v-$i/0.jpg',
            startSeconds: 10.0 * i,
            endSeconds: 10.0 * i + 25.0,
            createdAt: DateTime.now().subtract(Duration(minutes: i)),
          ),
        );
  }

  @override
  Future<void> deleteMoment(String momentId) async {
    deleteCallCount++;
    lastDeletedId = momentId;

    if (deleteErrorToThrow != null) {
      throw deleteErrorToThrow!;
    }
  }

  @override
  Future<Moment> createMoment({
    required String videoId,
    required String title,
    required String artist,
    required String thumbnailUrl,
    required double startSeconds,
    required double endSeconds,
    bool isPublic = true,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return createToReturn ??
        Moment(
          id: 'created-id-1',
          userId: 'user-1',
          videoId: videoId,
          title: title,
          artist: artist,
          thumbnailUrl: thumbnailUrl,
          startSeconds: startSeconds,
          endSeconds: endSeconds,
          isPublic: isPublic,
          createdAt: DateTime.now(),
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyMomentsNotifier Provider Tests', () {
    late MockMomentsRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockMomentsRepository();
      container = ProviderContainer(
        overrides: [
          momentsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1. Initial subscription triggers loading and transitions to success with data', () async {
      // Read initial state
      final initialState = container.read(myMomentsProvider);
      expect(initialState.isLoading, isTrue);

      // Wait for microtask / async fetch
      await container.read(myMomentsProvider.notifier).loadMoments();

      final state = container.read(myMomentsProvider);
      expect(state.isSuccess, isTrue);
      expect(state.moments.length, 5);
      expect(state.moments.first.title, 'Song 0');
      expect(state.hasMore, isFalse); // < pageSize (20)
      expect(state.errorMessage, isNull);
    });

    test('2. Error in getMyMoments transitions state to error with message', () async {
      mockRepo.errorToThrow = const MomentsRepositoryException('Network connection failed');

      await container.read(myMomentsProvider.notifier).loadMoments();

      final state = container.read(myMomentsProvider);
      expect(state.isError, isTrue);
      expect(state.errorMessage, contains('Network connection failed'));
      expect(state.moments, isEmpty);
    });

    test('3. Empty state is reported accurately when repository returns zero moments', () async {
      mockRepo.momentsToReturn = [];

      await container.read(myMomentsProvider.notifier).loadMoments();

      final state = container.read(myMomentsProvider);
      expect(state.isSuccess, isTrue);
      expect(state.moments, isEmpty);
      expect(state.isEmpty, isTrue);
      expect(state.hasMore, isFalse);
    });

    test('4. Pagination loadMore appends next page correctly', () async {
      // Simulate 20 items on first page
      mockRepo.momentsToReturn = List.generate(
        20,
        (i) => Moment(
          id: 'p1-$i',
          userId: 'user-1',
          videoId: 'v1-$i',
          title: 'Page1 Track $i',
          startSeconds: 0,
          endSeconds: 30,
        ),
      );

      await container.read(myMomentsProvider.notifier).loadMoments();

      var state = container.read(myMomentsProvider);
      expect(state.moments.length, 20);
      expect(state.hasMore, isTrue);

      // Next page has 5 items
      mockRepo.momentsToReturn = List.generate(
        5,
        (i) => Moment(
          id: 'p2-$i',
          userId: 'user-1',
          videoId: 'v2-$i',
          title: 'Page2 Track $i',
          startSeconds: 0,
          endSeconds: 30,
        ),
      );

      await container.read(myMomentsProvider.notifier).loadMore();

      state = container.read(myMomentsProvider);
      expect(state.moments.length, 25);
      expect(state.moments[20].title, 'Page2 Track 0');
      expect(state.hasMore, isFalse);
      expect(mockRepo.lastOffset, 20);
    });

    test('5. Optimistic delete immediately removes item from list and completes', () async {
      await container.read(myMomentsProvider.notifier).loadMoments();
      var state = container.read(myMomentsProvider);
      expect(state.moments.length, 5);

      final toDeleteId = state.moments[1].id; // 'm-1'
      final success = await container.read(myMomentsProvider.notifier).deleteMoment(toDeleteId);

      expect(success, isTrue);
      expect(mockRepo.deleteCallCount, 1);
      expect(mockRepo.lastDeletedId, toDeleteId);

      state = container.read(myMomentsProvider);
      expect(state.moments.length, 4);
      expect(state.moments.any((m) => m.id == toDeleteId), isFalse);
    });

    test('6. Optimistic delete rollback restores moment list on repository failure', () async {
      await container.read(myMomentsProvider.notifier).loadMoments();
      var state = container.read(myMomentsProvider);
      expect(state.moments.length, 5);

      // Configure repository to fail on delete
      mockRepo.deleteErrorToThrow = const MomentsRepositoryException('RLS permission denied');

      final toDeleteId = state.moments[0].id; // 'm-0'
      final success = await container.read(myMomentsProvider.notifier).deleteMoment(toDeleteId);

      expect(success, isFalse);
      expect(mockRepo.deleteCallCount, 1);

      // Verify list is rolled back to original 5 items including 'm-0'
      state = container.read(myMomentsProvider);
      expect(state.moments.length, 5);
      expect(state.moments.first.id, toDeleteId);
      expect(state.errorMessage, contains('Failed to delete Moment. Rolled back.'));
    });

    test('7. insertMoment prepends newly saved Moment at the top of the library', () async {
      await container.read(myMomentsProvider.notifier).loadMoments();

      const newMoment = Moment(
        id: 'newly-created-id',
        userId: 'user-1',
        videoId: 'v-new',
        title: 'Brand New Moment',
        startSeconds: 40.0,
        endSeconds: 65.0,
      );

      container.read(myMomentsProvider.notifier).insertMoment(newMoment);

      final state = container.read(myMomentsProvider);
      expect(state.moments.length, 6);
      expect(state.moments.first.id, 'newly-created-id');
      expect(state.moments.first.title, 'Brand New Moment');
    });
  });
}
