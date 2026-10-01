// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trim_selection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrimSelection _$TrimSelectionFromJson(Map<String, dynamic> json) =>
    _TrimSelection(
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      totalDurationSeconds: (json['totalDurationSeconds'] as num).toDouble(),
      startSeconds: (json['startSeconds'] as num).toDouble(),
      endSeconds: (json['endSeconds'] as num).toDouble(),
      isPreviewing: json['isPreviewing'] as bool? ?? false,
    );

Map<String, dynamic> _$TrimSelectionToJson(_TrimSelection instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'title': instance.title,
      'artist': instance.artist,
      'thumbnailUrl': instance.thumbnailUrl,
      'totalDurationSeconds': instance.totalDurationSeconds,
      'startSeconds': instance.startSeconds,
      'endSeconds': instance.endSeconds,
      'isPreviewing': instance.isPreviewing,
    };
