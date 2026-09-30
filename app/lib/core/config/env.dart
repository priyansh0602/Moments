import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  /// Loads environment variables from the `.env` asset file.
  static Future<void> init({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (e, st) {
      debugPrint('Warning: Could not load $fileName file: $e\n$st');
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
    return value.trim();
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
    return value.trim();
  }

  /// Checks whether real, non-placeholder credentials have been supplied.
  static bool get isSupabaseConfigured {
    final rawUrl = dotenv.maybeGet('SUPABASE_URL');
    final rawKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

    if (rawUrl == null || rawKey == null) return false;
    final url = rawUrl.trim();
    final key = rawKey.trim();

    if (url.isEmpty || key.isEmpty) return false;
    if (url.contains('your-project') || key.contains('your-anon-key')) {
      return false;
    }

    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }
}
