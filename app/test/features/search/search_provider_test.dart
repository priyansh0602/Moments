import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/features/search/data/search_repository.dart';
import 'package:moments/features/search/domain/models/search_result.dart';
import 'package:moments/features/search/domain/models/song.dart';
import 'package:moments/features/search/presentation/providers/search_provider.dart';

class MockSearchRepository implements SearchRepository {
  MockSearchRepository({
    this.resultsToReturn,
    this.errorToThrow,
  });

  SearchResult? resultsToReturn;
  Exception? errorToThrow;
  int callCount = 0;
  String? lastQuery;
  String? lastPageToken;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<SearchResult> searchSongs(String query, {String? pageToken}) async {
    callCount++;
    lastQuery = query;
    lastPageToken = pageToken;

    if (errorToThrow != null) {
      throw errorToThrow!;
    }

    return resultsToReturn ??
        const SearchResult(
          items: [
            Song(
              videoId: 'v1',
              title: 'After Dark',
              channelTitle: 'Mr.Kitty',
              thumbnailUrl: 'https://i.ytimg.com/vi/v1/mqdefault.jpg',
              durationSeconds: 258,
            ),
          ],
          nextPageToken: 'page_2',
          cached: false,
        );
  }
}

void main() {
  group('SearchNotifier & Provider Tests', () {
    late MockSearchRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockSearchRepository();
      container = ProviderContainer(
        overrides: [
          searchRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is SearchStatus.initial with empty songs', () {
      final state = container.read(searchProvider);
      expect(state.status, SearchStatus.initial);
      expect(state.isInitial, isTrue);
      expect(state.songs, isEmpty);
      expect(state.query, isEmpty);
    });

    test('Empty query immediately resets to initial state without calling repository', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('');
      final state = container.read(searchProvider);
      expect(state.status, SearchStatus.initial);
      expect(mockRepo.callCount, 0);
    });

    test('1-character query updates query text but does not trigger API search', () async {
      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('a');
      expect(container.read(searchProvider).query, 'a');

      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(mockRepo.callCount, 0);
      expect(container.read(searchProvider).status, SearchStatus.initial);
    });

    test('Debounces rapid keystrokes and only fires once after delay', () async {
      final notifier = container.read(searchProvider.notifier);
      notifier.onQueryChanged('af');
      notifier.onQueryChanged('aft');
      notifier.onQueryChanged('after');

      // Before debounce duration expires
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(mockRepo.callCount, 0);

      // Wait for debounce to complete
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(mockRepo.callCount, 1);
      expect(mockRepo.lastQuery, 'after');
      final state = container.read(searchProvider);
      expect(state.isSuccess, isTrue);
      expect(state.songs.length, 1);
      expect(state.songs.first.title, 'After Dark');
    });

    test('executeSearch transitions through loading to success state', () async {
      final notifier = container.read(searchProvider.notifier);
      final future = notifier.executeSearch('resonance');
      expect(container.read(searchProvider).isLoading, isTrue);

      await future;
      final state = container.read(searchProvider);
      expect(state.isSuccess, isTrue);
      expect(state.songs.isNotEmpty, isTrue);
      expect(state.nextPageToken, 'page_2');
      expect(state.hasMore, isTrue);
    });

    test('executeSearch handles error properly and records errorMessage', () async {
      mockRepo.errorToThrow = const SearchException('Quota exceeded', statusCode: 429);
      final notifier = container.read(searchProvider.notifier);

      await notifier.executeSearch('kavinsky');
      final state = container.read(searchProvider);
      expect(state.isError, isTrue);
      expect(state.errorMessage, contains('Quota exceeded'));
    });

    test('loadMore appends next page results to existing songs', () async {
      final notifier = container.read(searchProvider.notifier);

      // First page
      await notifier.executeSearch('synthwave');
      expect(container.read(searchProvider).songs.length, 1);
      expect(container.read(searchProvider).nextPageToken, 'page_2');

      // Prepare second page response
      mockRepo.resultsToReturn = const SearchResult(
        items: [
          Song(
            videoId: 'v2',
            title: 'Nightcall',
            channelTitle: 'Kavinsky',
            thumbnailUrl: 'https://i.ytimg.com/vi/v2/mqdefault.jpg',
            durationSeconds: 259,
          ),
        ],
        nextPageToken: null,
      );

      // Load more
      await notifier.loadMore();

      final state = container.read(searchProvider);
      expect(state.isSuccess, isTrue);
      expect(state.songs.length, 2);
      expect(state.songs[0].videoId, 'v1');
      expect(state.songs[1].videoId, 'v2');
      expect(state.hasMore, isFalse);
    });

    test('retry executes search again with current query', () async {
      mockRepo.errorToThrow = const SearchException('Network error');
      final notifier = container.read(searchProvider.notifier);
      await notifier.executeSearch('retry_test');
      expect(container.read(searchProvider).isError, isTrue);

      // Clear error on mock repo
      mockRepo.errorToThrow = null;
      notifier.retry();

      // Wait for execution
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(searchProvider);
      expect(state.isSuccess, isTrue);
      expect(state.songs.isNotEmpty, isTrue);
    });
  });
}
