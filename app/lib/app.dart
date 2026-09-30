import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/router/app_router.dart';
import 'package:moments/core/services/deep_link_service.dart';
import 'package:moments/core/theme/app_theme.dart';
import 'package:moments/features/player/presentation/persistent_player_host.dart';

/// Root application widget configuring theme, router, and global services.
class MomentsApp extends ConsumerWidget {
  const MomentsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Register and keep deep link listener active across app lifecycle
    ref.watch(deepLinkServiceProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Moments',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return PersistentPlayerHost(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
