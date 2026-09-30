import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/search/data/search_repository.dart';
import 'package:moments/features/search/domain/models/song.dart';

/// The status of the search operation.
enum SearchStatus {
  /// User has not entered a query yet.
  initial,

  /// Currently executing initial search query.
  loading,

  /// Search succeeded with results (may be empty list).
  success,

  /// Error occurred during search.
  error,

  /// Currently loading next page of results.
  loadingMore,
}

/// State representation for the YouTube song search screen.
class SearchState {
  /// Creates a [SearchState].
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.songs = const [],
    this.nextPageToken,
    this.errorMessage,
    this.isCached = false,
  });

  /// Current search phase status.
  final SearchStatus status;

  /// Current active query string.
  final String query;

  /// Current list of song results.
  final List<Song> songs;

  /// Token for loading next page of results, or null if no further pages.
  final String? nextPageToken;

  /// Error message when status is [SearchStatus.error].
  final String? errorMessage;

  /// Whether results were served from the 24-hour cache.
  final bool isCached;

  /// Convenient status getters.
  bool get isInitial => status == SearchStatus.initial;
  bool get isLoading => status == SearchStatus.loading;
  bool get isSuccess => status == SearchStatus.success;
  bool get isError => status == SearchStatus.error;
  bool get isLoadingMore => status == SearchStatus.loadingMore;
  bool get hasMore => nextPageToken != null && nextPageToken!.isNotEmpty;
  bool get isEmpty => isSuccess && songs.isEmpty;

  /// Copies state with optional updated fields.
  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Song>? songs,
    String? nextPageToken,
    String? errorMessage,
    bool? isCached,
    bool clearNextPageToken = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      songs: songs ?? this.songs,
      nextPageToken:
          clearNextPageToken ? null : (nextPageToken ?? this.nextPageToken),
      errorMessage: errorMessage ?? this.errorMessage,
      isCached: isCached ?? this.isCached,
    );
  }
}

/// Notifier managing debounced search, pagination, and error recovery.
class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  static const Duration debounceDuration = Duration(milliseconds: 450);

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchState();
  }

  SearchRepository get _repository => ref.read(searchRepositoryProvider);

  /// Triggers a debounced search (450ms) as the user types.
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      state = const SearchState(status: SearchStatus.initial);
      return;
    }

    if (cleanQuery.length < 2) {
      // Don't search for 1 character, but preserve query text in state
      state = state.copyWith(query: query);
      return;
    }

    _debounceTimer = Timer(debounceDuration, () {
      executeSearch(cleanQuery);
    });
  }

  /// Executes an immediate search without debounce delay (e.g. category pill tap or enter key).
  Future<void> executeSearch(String query) async {
    _debounceTimer?.cancel();
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      state = const SearchState(status: SearchStatus.initial);
      return;
    }

    state = state.copyWith(
      status: SearchStatus.loading,
      query: cleanQuery,
      errorMessage: null,
    );

    try {
      final result = await _repository.searchSongs(cleanQuery);
      state = state.copyWith(
        status: SearchStatus.success,
        songs: result.items,
        nextPageToken: result.nextPageToken,
        isCached: result.cached,
        clearNextPageToken: result.nextPageToken == null,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Fetches the next page of results and appends to the current list.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.query.isEmpty) {
      return;
    }

    state = state.copyWith(status: SearchStatus.loadingMore);

    try {
      final result = await _repository.searchSongs(
        state.query,
        pageToken: state.nextPageToken,
      );

      // Deduplicate songs by videoId in case YouTube returns overlap
      final existingIds = state.songs.map((s) => s.videoId).toSet();
      final newSongs =
          result.items.where((s) => !existingIds.contains(s.videoId)).toList();

      state = state.copyWith(
        status: SearchStatus.success,
        songs: [...state.songs, ...newSongs],
        nextPageToken: result.nextPageToken,
        clearNextPageToken: result.nextPageToken == null,
      );
    } catch (e) {
      // Return to success state without losing already loaded songs
      state = state.copyWith(
        status: SearchStatus.success,
      );
    }
  }

  /// Retries the current query if in an error state.
  void retry() {
    if (state.query.isNotEmpty) {
      executeSearch(state.query);
    }
  }
}

/// Provider for [SearchNotifier] state.
final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
