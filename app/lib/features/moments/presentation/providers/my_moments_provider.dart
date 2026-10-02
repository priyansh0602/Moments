import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/moments/data/moments_repository.dart';
import 'package:moments/features/moments/domain/models/moment.dart';

/// The status of the user's Moments library retrieval.
enum MyMomentsStatus {
  /// Initial idle state before first load.
  initial,

  /// Loading the initial page of moments.
  loading,

  /// Successfully loaded moments list (may be empty).
  success,

  /// An error occurred while fetching moments.
  error,

  /// Loading next paginated batch.
  loadingMore,
}

/// State representation for the "Your Moments" screen.
class MyMomentsState {
  /// Creates a [MyMomentsState].
  const MyMomentsState({
    this.status = MyMomentsStatus.initial,
    this.moments = const [],
    this.hasMore = true,
    this.errorMessage,
  });

  /// Current loading/success/error status.
  final MyMomentsStatus status;

  /// List of loaded Moment entities.
  final List<Moment> moments;

  /// Whether additional pages can be fetched.
  final bool hasMore;

  /// Human-readable error message if [status] is [MyMomentsStatus.error].
  final String? errorMessage;

  /// Convenient status getters.
  bool get isInitial => status == MyMomentsStatus.initial;
  bool get isLoading => status == MyMomentsStatus.loading;
  bool get isSuccess => status == MyMomentsStatus.success;
  bool get isError => status == MyMomentsStatus.error;
  bool get isLoadingMore => status == MyMomentsStatus.loadingMore;
  bool get isEmpty => !isLoading && moments.isEmpty;

  /// Copies state with optional updated properties.
  MyMomentsState copyWith({
    MyMomentsStatus? status,
    List<Moment>? moments,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyMomentsState(
      status: status ?? this.status,
      moments: moments ?? this.moments,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier managing user's saved moments, pagination, pull-to-refresh, and optimistic deletion.
class MyMomentsNotifier extends Notifier<MyMomentsState> {
  static const int pageSize = 20;
  bool _isFetching = false;

  MomentsRepository get _repository => ref.read(momentsRepositoryProvider);

  @override
  MyMomentsState build() {
    // Automatically trigger initial load upon provider subscription
    Future.microtask(() => loadMoments());
    return const MyMomentsState(status: MyMomentsStatus.loading);
  }

  /// Loads the first page of Moments.
  Future<void> loadMoments({bool isRefresh = false}) async {
    if (_isFetching && !isRefresh) {
      return;
    }

    _isFetching = true;

    if (!isRefresh) {
      state = state.copyWith(
        status: MyMomentsStatus.loading,
        clearError: true,
      );
    }

    try {
      final items = await _repository.getMyMoments(
        limit: pageSize,
        offset: 0,
      );

      state = state.copyWith(
        status: MyMomentsStatus.success,
        moments: items,
        hasMore: items.length >= pageSize,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: MyMomentsStatus.error,
        errorMessage: e is MomentsRepositoryException ? e.message : e.toString(),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Loads the next batch of Moments (infinite scroll pagination).
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(status: MyMomentsStatus.loadingMore);

    try {
      final newItems = await _repository.getMyMoments(
        limit: pageSize,
        offset: state.moments.length,
      );

      state = state.copyWith(
        status: MyMomentsStatus.success,
        moments: [...state.moments, ...newItems],
        hasMore: newItems.length >= pageSize,
      );
    } catch (e) {
      // Revert loadingMore status without removing already loaded moments
      state = state.copyWith(
        status: MyMomentsStatus.success,
        errorMessage: e is MomentsRepositoryException ? e.message : e.toString(),
      );
    }
  }

  /// Deletes a Moment with optimistic UI removal and rollback on failure.
  Future<bool> deleteMoment(String momentId) async {
    final previousMoments = state.moments;
    final index = previousMoments.indexWhere((m) => m.id == momentId);
    if (index == -1) return false;

    // 1. Optimistic removal from UI list
    final updatedList = List<Moment>.from(previousMoments)..removeAt(index);
    state = state.copyWith(moments: updatedList);

    // 2. Perform database deletion
    try {
      await _repository.deleteMoment(momentId);
      return true;
    } catch (e) {
      // 3. Rollback state on failure
      state = state.copyWith(
        moments: previousMoments,
        errorMessage: 'Failed to delete Moment. Rolled back.',
      );
      return false;
    }
  }

  /// Prepends a freshly created [Moment] to the list immediately.
  void insertMoment(Moment moment) {
    state = state.copyWith(
      status: MyMomentsStatus.success,
      moments: [moment, ...state.moments],
    );
  }
}

/// Provider exposing [MyMomentsState] and operations.
final myMomentsProvider = NotifierProvider<MyMomentsNotifier, MyMomentsState>(
  MyMomentsNotifier.new,
);
