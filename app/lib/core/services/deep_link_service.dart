import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider exposing the singleton [DeepLinkService].
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService(ref: ref);
  service.init();
  ref.onDispose(service.dispose);
  return service;
});

/// Service responsible for capturing app deep links (e.g. `moments://login-callback`)
/// and forwarding OAuth callbacks to Supabase for session token exchange.
class DeepLinkService {
  DeepLinkService({Ref? ref, AppLinks? appLinks})
      : _ref = ref,
        _appLinks = appLinks ?? AppLinks();

  final Ref? _ref;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;
  bool _initialized = false;

  /// Initializes deep link listeners for both streaming and cold-boot links.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Listen for background -> foreground or active deep link intents
    try {
      _linkSub = _appLinks.uriLinkStream.listen(
        (uri) => _handleUri(uri, source: 'uriLinkStream'),
        onError: (error, stackTrace) {
          debugPrint('[DeepLinkService] Error in uriLinkStream: $error\n$stackTrace');
        },
      );
    } catch (e) {
      debugPrint('[DeepLinkService] Could not register uriLinkStream: $e');
    }

    // 2. Check if the app was launched directly from a cold deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleUri(initialUri, source: 'getInitialLink');
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Could not check initialLink: $e');
    }
  }

  /// Processes an incoming deep link URI.
  Future<void> _handleUri(Uri uri, {required String source}) async {
    // Check if this URI matches the OAuth redirect pattern (moments://login-callback)
    final isOAuthCallback = uri.scheme == 'moments' &&
        (uri.host == 'login-callback' || uri.path.contains('login-callback'));

    if (isOAuthCallback) {
      _ref?.read(authControllerProvider.notifier).onCallbackReceived();
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } on AuthException catch (e) {
        final current = Supabase.instance.client.auth.currentSession;
        if (current == null) {
          _ref?.read(authControllerProvider.notifier).setError(e.message);
        }
      } catch (e) {
        _ref?.read(authControllerProvider.notifier).setError(
              'Failed to complete sign-in. Please try again.',
            );
      }
    }
  }

  /// Cancels any active subscriptions.
  void dispose() {
    _linkSub?.cancel();
    _linkSub = null;
  }
}
