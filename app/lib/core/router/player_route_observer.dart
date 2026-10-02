import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/player/presentation/providers/player_provider.dart';

/// State notifier tracking the currently active route name.
class CurrentRouteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Updates the currently active route name.
  void setRoute(String? routeName) {
    if (routeName != null && state != routeName) {
      state = routeName;
    }
  }
}

/// Provider exposing the name of the currently active route.
final currentRouteNameProvider =
    NotifierProvider<CurrentRouteNotifier, String?>(
  CurrentRouteNotifier.new,
);

/// Route observer that automatically synchronizes the persistent player display mode
/// with whichever route is active, preventing the player frame from ever getting stuck.
class PlayerRouteObserver extends NavigatorObserver {
  /// Creates a [PlayerRouteObserver].
  PlayerRouteObserver(this._ref);

  final Ref _ref;

  void _syncRoute(String? routeName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final effectiveRoute = routeName ?? 'shell';
      _ref.read(currentRouteNameProvider.notifier).setRoute(effectiveRoute);

      final isExpanded =
          effectiveRoute == 'player' || effectiveRoute == 'create-moment';
      _ref.read(playerPlaybackStateProvider.notifier).setExpanded(isExpanded);
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _syncRoute(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _syncRoute(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _syncRoute(newRoute?.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _syncRoute(previousRoute?.settings.name);
  }
}
