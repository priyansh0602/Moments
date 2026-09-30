// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchResult _$SearchResultFromJson(Map<String, dynamic> json) =>
    _SearchResult(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextPageToken: json['nextPageToken'] as String?,
      cached: json['cached'] as bool? ?? false,
    );

Map<String, dynamic> _$SearchResultToJson(_SearchResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextPageToken': instance.nextPageToken,
      'cached': instance.cached,
    };
