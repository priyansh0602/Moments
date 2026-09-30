// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Song _$SongFromJson(Map<String, dynamic> json) => _Song(
  videoId: json['videoId'] as String,
  title: json['title'] as String,
  channelTitle: json['channelTitle'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$SongToJson(_Song instance) => <String, dynamic>{
  'videoId': instance.videoId,
  'title': instance.title,
  'channelTitle': instance.channelTitle,
  'thumbnailUrl': instance.thumbnailUrl,
  'durationSeconds': instance.durationSeconds,
};
