// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupItem _$GroupItemFromJson(Map<String, dynamic> json) => _GroupItem(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  momentId: json['moment_id'] as String,
  position: (json['position'] as num).toInt(),
  addedAt: DateTime.parse(json['added_at'] as String),
  moment: Moment.fromJson(_readMoment(json, 'moment') as Map<String, dynamic>),
);

Map<String, dynamic> _$GroupItemToJson(_GroupItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'moment_id': instance.momentId,
      'position': instance.position,
      'added_at': instance.addedAt.toIso8601String(),
      'moment': instance.moment,
    };
