import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/app.dart';
import 'package:moments/core/config/env.dart';
import 'package:moments/core/services/audio_handler_provider.dart';
import 'package:moments/core/widgets/supabase_init_error_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration
  await Env.init();

  // Initialize OS background audio service proxy
  await initAudioService();

  String? initError;

  try {
    if (!Env.isSupabaseConfigured) {
      throw StateError(
        'Supabase credentials are not configured or placeholder values are present in app/.env',
      );
    }

    // Fully await Supabase initialization BEFORE runApp or ProviderScope attach
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        detectSessionInUri: false,
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Supabase initialization failed: $error\n$stackTrace');
    initError = error.toString();
  }

  // Defensive fallback: if Supabase initialization failed, show error/retry screen
  // instead of allowing downstream providers to crash with an AssertionError.
  if (initError != null) {
    runApp(
      SupabaseInitErrorApp(
        errorMessage: initError,
        onRetry: () => main(),
      ),
    );
    return;
  }

  // Only attach ProviderScope and MomentsApp AFTER Supabase is initialized
  runApp(
    const ProviderScope(
      child: MomentsApp(),
    ),
  );
}
