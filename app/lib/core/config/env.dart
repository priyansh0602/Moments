import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  /// Loads environment variables from the `.env` asset file.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Allow fallback if .env is missing during tests or initial setup
    }
  }

  /// Supabase project URL.
  /// Throws [StateError] if missing or empty.
  static String get supabaseUrl {
    final value = dotenv.maybeGet('SUPABASE_URL');
    if (value == null || value.trim().isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL. Please configure it in app/.env',
      );
    }
    return value;
  }

  /// Supabase public anonymous API key.
  /// Throws [StateError] if missing or empty.
  static String get supabaseAnonKey {
    final value = dotenv.maybeGet('SUPABASE_ANON_KEY');
    if (value == null || value.trim().isEmpty) {
      throw StateError(
        'Missing SUPABASE_ANON_KEY. Please configure it in app/.env',
      );
    }
    return value;
  }

  /// Checks whether real, non-placeholder credentials have been supplied.
  static bool get isSupabaseConfigured {
    final url = dotenv.maybeGet('SUPABASE_URL');
    final key = dotenv.maybeGet('SUPABASE_ANON_KEY');

    if (url == null || key == null) return false;
    if (url.trim().isEmpty || key.trim().isEmpty) return false;
    if (url.contains('your-project') || key.contains('your-anon-key')) {
      return false;
    }
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }
}
