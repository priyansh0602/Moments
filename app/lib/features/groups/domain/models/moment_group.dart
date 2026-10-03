import 'package:freezed_annotation/freezed_annotation.dart';

part 'moment_group.freezed.dart';
part 'moment_group.g.dart';

Object? _readMomentCount(Map<dynamic, dynamic> json, String key) {
  if (json['moment_count'] != null) {
    return (json['moment_count'] as num).toInt();
  }
  if (json['momentCount'] != null) {
    return (json['momentCount'] as num).toInt();
  }
  if (json['moment_group_items'] is List &&
      (json['moment_group_items'] as List).isNotEmpty) {
    final first = (json['moment_group_items'] as List).first;
    if (first is Map && first.containsKey('count')) {
      return (first['count'] as num).toInt();
    }
  }
  return 0;
}

/// Immutable representation of a Moment Collection / Group in Supabase.
@freezed
abstract class MomentGroup with _$MomentGroup {
  const factory MomentGroup({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? description,
    @JsonKey(name: 'cover_thumbnail_url') String? coverThumbnailUrl,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(readValue: _readMomentCount) @Default(0) int momentCount,
  }) = _MomentGroup;

  /// Deserializes a [MomentGroup] from Supabase JSON map.
  factory MomentGroup.fromJson(Map<String, dynamic> json) =>
      _$MomentGroupFromJson(json);
}
