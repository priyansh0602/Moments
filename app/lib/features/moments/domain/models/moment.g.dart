// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Moment _$MomentFromJson(Map<String, dynamic> json) => _Moment(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  videoId: json['video_id'] as String,
  title: json['song_title'] as String,
  artist: json['artist'] as String? ?? '',
  thumbnailUrl: json['thumbnail_url'] as String? ?? '',
  startSeconds: (json['start_seconds'] as num).toDouble(),
  endSeconds: (json['end_seconds'] as num).toDouble(),
  isPublic: json['is_public'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MomentToJson(_Moment instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'video_id': instance.videoId,
  'song_title': instance.title,
  'artist': instance.artist,
  'thumbnail_url': instance.thumbnailUrl,
  'start_seconds': instance.startSeconds,
  'end_seconds': instance.endSeconds,
  'is_public': instance.isPublic,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
