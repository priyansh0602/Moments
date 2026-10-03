import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/groups/data/groups_repository.dart';
import 'package:moments/features/groups/domain/models/group_item.dart';
import 'package:moments/features/groups/presentation/providers/my_groups_provider.dart';

/// The loading/success/error status of a group's items.
enum GroupItemsStatus {
  /// Initial idle state.
  initial,

  /// Loading items for the group.
  loading,

  /// Successfully loaded items.
  success,

  /// An error occurred while fetching items.
  error,
}

/// State representation for the ordered moments within a group.
class GroupItemsState {
  /// Creates a [GroupItemsState].
  const GroupItemsState({
    this.status = GroupItemsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  /// Current status.
  final GroupItemsStatus status;

  /// Ordered list of [GroupItem]s.
  final List<GroupItem> items;

  /// Error message if status is error.
  final String? errorMessage;

  bool get isInitial => status == GroupItemsStatus.initial;
  bool get isLoading => status == GroupItemsStatus.loading;
  bool get isSuccess => status == GroupItemsStatus.success;
  bool get isError => status == GroupItemsStatus.error;
  bool get isEmpty => !isLoading && items.isEmpty;

  /// Copies state with optional updated properties.
  GroupItemsState copyWith({
    GroupItemsStatus? status,
    List<GroupItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier managing ordered items for a specific [groupId], supporting reorder and item removal.
class GroupItemsNotifier extends Notifier<GroupItemsState> {
  GroupItemsNotifier(this.groupId);

  /// ID of the group whose items are managed.
  final String groupId;

  GroupsRepository get _repository => ref.read(groupsRepositoryProvider);

  bool _isFetching = false;

  @override
  GroupItemsState build() {
    Future.microtask(() => loadItems());
    return const GroupItemsState(status: GroupItemsStatus.loading);
  }

  /// Loads the items for this group ordered by position ASC.
  Future<void> loadItems({bool isRefresh = false}) async {
    if (_isFetching && !isRefresh) return;
    _isFetching = true;

    if (!isRefresh) {
      state = state.copyWith(status: GroupItemsStatus.loading, clearError: true);
    }
    try {
      final items = await _repository.getGroupItems(groupId);
      state = state.copyWith(
        status: GroupItemsStatus.success,
        items: items,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: GroupItemsStatus.error,
        errorMessage: e is GroupsRepositoryException ? e.message : e.toString(),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Optimistically reorders items within the group and persists the new sequential positions.
  Future<bool> reorder(int oldIndex, int newIndex) async {
    final previousItems = state.items;
    if (oldIndex < 0 || oldIndex >= previousItems.length) return false;
    if (newIndex < 0) return false;

    // Flutter ReorderableListView index adjustment
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (newIndex >= previousItems.length) {
      newIndex = previousItems.length - 1;
    }
    if (oldIndex == newIndex) return true;

    // 1. Optimistic in-memory reorder
    final updated = List<GroupItem>.from(previousItems);
    final movedItem = updated.removeAt(oldIndex);
    updated.insert(newIndex, movedItem);

    // Update positions sequentially 0..N-1
    final reindexed = [
      for (int i = 0; i < updated.length; i++)
        updated[i].copyWith(position: i)
    ];

    state = state.copyWith(items: reindexed);

    // 2. Persist to database batch upsert
    try {
      final orderedMomentIds =
          reindexed.map((item) => item.momentId).toList();
      await _repository.reorderGroupItems(groupId, orderedMomentIds);
      return true;
    } catch (e) {
      // 3. Rollback on failure
      state = state.copyWith(
        items: previousItems,
        errorMessage: 'Failed to save reorder. Rolled back.',
      );
      return false;
    }
  }

  /// Removes an item from the group with optimistic UI removal and rollback on failure.
  Future<bool> removeItem(String momentId) async {
    final previousItems = state.items;
    final index = previousItems.indexWhere((i) => i.momentId == momentId);
    if (index == -1) return false;

    // 1. Optimistic removal
    final updated = List<GroupItem>.from(previousItems)..removeAt(index);
    state = state.copyWith(items: updated);

    // Update parent group momentCount in myGroupsProvider
    ref.read(myGroupsProvider.notifier).adjustMomentCount(groupId, -1);

    // 2. Persist deletion to Supabase
    try {
      await _repository.removeMomentFromGroup(groupId, momentId);
      return true;
    } catch (e) {
      // 3. Rollback on failure
      ref.read(myGroupsProvider.notifier).adjustMomentCount(groupId, 1);
      state = state.copyWith(
        items: previousItems,
        errorMessage: 'Failed to remove Moment from group. Rolled back.',
      );
      return false;
    }
  }

  /// Adds a freshly added item to the list in memory.
  void addItem(GroupItem item) {
    state = state.copyWith(
      status: GroupItemsStatus.success,
      items: [...state.items, item],
    );
  }
}

/// Family provider keyed by [groupId] exposing its ordered items.
final groupItemsProvider =
    NotifierProvider.family<GroupItemsNotifier, GroupItemsState, String>(
  GroupItemsNotifier.new,
);
