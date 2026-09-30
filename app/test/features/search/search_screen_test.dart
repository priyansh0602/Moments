import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moments/core/widgets/song_card.dart';
import 'package:moments/features/search/data/search_repository.dart';
import 'package:moments/features/search/domain/models/search_result.dart';
import 'package:moments/features/search/domain/models/song.dart';
import 'package:moments/features/search/presentation/search_screen.dart';
import 'package:moments/features/search/presentation/selected_song_screen.dart';

class _FakeSearchRepository implements SearchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<SearchResult> searchSongs(String query, {String? pageToken}) async {

    if (query == 'empty_result') {
      return const SearchResult(items: [], nextPageToken: null);
    }

    if (query == 'error_result') {
      throw const SearchException('Simulated search failure', statusCode: 500);
    }

    return SearchResult(
      items: [
        Song(
          videoId: 'v_${query}_1',
          title: '$query Track 1',
          channelTitle: 'Artist 1',
          thumbnailUrl: '',
          durationSeconds: 210,
        ),
        Song(
          videoId: 'v_${query}_2',
          title: '$query Track 2',
          channelTitle: 'Artist 2',
          thumbnailUrl: '',
          durationSeconds: 180,
        ),
      ],
      nextPageToken: 'next_token_123',
    );
  }
}

void main() {
  Widget buildTestableSearchScreen({
    SearchRepository? repository,
  }) {
    return ProviderScope(
      overrides: [
        searchRepositoryProvider.overrideWithValue(
          repository ?? _FakeSearchRepository(),
        ),
      ],
      child: const MaterialApp(
        home: SearchScreen(),
      ),
    );
  }

  group('SearchScreen UI Tests', () {
    testWidgets('Renders initial empty state before user enters search query', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableSearchScreen());
      await tester.pumpAndSettle();

      expect(find.text('Search YouTube Music'), findsOneWidget);
      expect(find.text('Moments'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Trending'), findsOneWidget);
      expect(find.text('Late Night'), findsOneWidget);
      expect(find.byType(SongCard), findsNothing);
    });

    testWidgets('Tapping category pill triggers search and displays song results', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableSearchScreen());
      await tester.pumpAndSettle();

      // Tap 'Synthwave' pill
      await tester.tap(find.text('Synthwave'));
      await tester.pumpAndSettle();

      expect(find.byType(SongCard), findsNWidgets(2));
      expect(find.text('Synthwave Track 1'), findsOneWidget);
      expect(find.text('Synthwave Track 2'), findsOneWidget);
      expect(find.text('Results for "Synthwave"'), findsOneWidget);
    });

    testWidgets('Displays no-results empty state when query returns empty items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableSearchScreen());
      await tester.pumpAndSettle();

      // Enter query that returns 0 items
      await tester.enterText(find.byType(TextField), 'empty_result');
      await tester.pump(const Duration(milliseconds: 500)); // wait for debounce
      await tester.pumpAndSettle();

      expect(find.text('No Songs Found'), findsOneWidget);
      expect(find.byType(SongCard), findsNothing);
    });

    testWidgets('Displays error state and allows retry on search failure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableSearchScreen());
      await tester.pumpAndSettle();

      // Enter query that returns error
      await tester.enterText(find.byType(TextField), 'error_result');
      await tester.pump(const Duration(milliseconds: 500)); // wait for debounce
      await tester.pumpAndSettle();

      expect(find.text('Search Failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('Clearing search resets back to initial state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableSearchScreen());
      await tester.pumpAndSettle();

      // Search for something first
      await tester.tap(find.text('Lo-Fi'));
      await tester.pumpAndSettle();
      expect(find.byType(SongCard), findsNWidgets(2));

      // Tap clear icon button
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Search YouTube Music'), findsOneWidget);
      expect(find.byType(SongCard), findsNothing);
    });
  });

  group('SelectedSongScreen Placeholder Tests', () {
    testWidgets('Renders selected song details and Phase 5 notification', (
      WidgetTester tester,
    ) async {
      const selectedSong = Song(
        videoId: 'test_vid_123',
        title: 'Midnight City',
        channelTitle: 'M83',
        thumbnailUrl: '',
        durationSeconds: 244,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SelectedSongScreen(song: selectedSong),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selected Song'), findsOneWidget);
      expect(find.text('You selected: Midnight City'), findsOneWidget);
      expect(find.text('M83'), findsOneWidget);
      expect(find.text('04:04'), findsOneWidget);
      expect(
        find.text(
          'Full YouTube IFrame player integration and background playback are coming in Phase 5.',
        ),
        findsOneWidget,
      );
      expect(find.text('Load into Player'), findsOneWidget);
      expect(find.text('Back to Search'), findsOneWidget);
    });
  });
}
