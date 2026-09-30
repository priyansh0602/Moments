import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moments/features/search/domain/models/song.dart';

part 'search_result.freezed.dart';
part 'search_result.g.dart';

/// Response payload returned by the search-songs Edge Function.
@freezed
abstract class SearchResult with _$SearchResult {
  /// Creates a [SearchResult].
  const factory SearchResult({
    @Default([]) List<Song> items,
    String? nextPageToken,
    @Default(false) bool cached,
  }) = _SearchResult;

  /// Deserializes a [SearchResult] from JSON.
  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
