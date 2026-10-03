import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moments/features/moments/domain/models/moment.dart';

part 'group_item.freezed.dart';
part 'group_item.g.dart';

Object? _readMoment(Map<dynamic, dynamic> json, String key) {
  if (json['moments'] != null) {
    return json['moments'];
  }
  if (json['moment'] != null) {
    return json['moment'];
  }
  return null;
}

/// Immutable representation of an ordered Moment entry within a [MomentGroup].
@freezed
abstract class GroupItem with _$GroupItem {
  const factory GroupItem({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'moment_id') required String momentId,
    required int position,
    @JsonKey(name: 'added_at') required DateTime addedAt,
    @JsonKey(readValue: _readMoment) required Moment moment,
  }) = _GroupItem;

  /// Deserializes a [GroupItem] from a joined Supabase JSON map.
  factory GroupItem.fromJson(Map<String, dynamic> json) =>
      _$GroupItemFromJson(json);
}
