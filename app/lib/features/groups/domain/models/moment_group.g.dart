// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MomentGroup _$MomentGroupFromJson(Map<String, dynamic> json) => _MomentGroup(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  coverThumbnailUrl: json['cover_thumbnail_url'] as String?,
  isPublic: json['is_public'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  momentCount: (_readMomentCount(json, 'momentCount') as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MomentGroupToJson(_MomentGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'cover_thumbnail_url': instance.coverThumbnailUrl,
      'is_public': instance.isPublic,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'momentCount': instance.momentCount,
    };
