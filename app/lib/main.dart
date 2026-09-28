import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/app.dart';
import 'package:moments/core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration
  await Env.init();

  // Guarded Supabase initialization: boot safely even with placeholder credentials
  if (Env.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: Env.supabaseAnonKey,
      );
    } catch (error) {
      debugPrint('Failed to initialize Supabase: $error');
    }
  } else {
    debugPrint(
      'Supabase not initialized: placeholder or missing credentials in .env',
    );
  }

  runApp(
    const ProviderScope(
      child: MomentsApp(),
    ),
  );
}
