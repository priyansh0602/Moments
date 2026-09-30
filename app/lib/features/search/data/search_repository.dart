import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/features/search/domain/models/search_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the [SearchRepository].
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(supabaseClientProvider));
});

/// Exception thrown when a YouTube song search operation fails.
class SearchException implements Exception {
  /// Creates a [SearchException].
  const SearchException(this.message, {this.statusCode});

  /// Human-readable error message.
  final String message;

  /// Optional HTTP status code from the Edge Function or upstream API.
  final int? statusCode;

  @override
  String toString() => message;
}

/// Repository responsible for proxying YouTube song searches through the Supabase Edge Function.
class SearchRepository {
  /// Creates a [SearchRepository].
  const SearchRepository(this._client);

  final SupabaseClient _client;

  /// Searches for YouTube songs matching [query] with optional pagination [pageToken].
  Future<SearchResult> searchSongs(String query, {String? pageToken}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return const SearchResult(items: []);
    }

    try {
      final response = await _client.functions.invoke(
        'search-songs',
        body: {
          'query': cleanQuery,
          if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
        },
      );

      if (response.status != 200) {
        String errorMsg = 'Search request failed';
        if (response.data is Map) {
          final dataMap = response.data as Map;
          errorMsg = dataMap['error']?.toString() ?? errorMsg;
        }
        throw SearchException(errorMsg, statusCode: response.status);
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SearchResult.fromJson(data);
      } else if (data is Map) {
        return SearchResult.fromJson(Map<String, dynamic>.from(data));
      }

      throw const SearchException('Invalid search response format.');
    } on FunctionException catch (e) {
      String message = 'Search service error';
      final details = e.details;
      if (details is Map && details['error'] != null) {
        message = details['error'].toString();
      } else if (details != null) {
        message = details.toString();
      }
      throw SearchException(message, statusCode: e.status);
    } catch (e) {
      if (e is SearchException) rethrow;
      throw SearchException('Failed to search songs: $e');
    }
  }
}
