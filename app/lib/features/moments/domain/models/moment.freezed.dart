// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Moment {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'video_id') String get videoId;@JsonKey(name: 'song_title') String get title; String get artist;@JsonKey(name: 'thumbnail_url') String get thumbnailUrl;@JsonKey(name: 'start_seconds') double get startSeconds;@JsonKey(name: 'end_seconds') double get endSeconds;@JsonKey(name: 'is_public') bool get isPublic;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(includeFromJson: false, includeToJson: false) List<String> get tags;
/// Create a copy of Moment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MomentCopyWith<Moment> get copyWith => _$MomentCopyWithImpl<Moment>(this as Moment, _$identity);

  /// Serializes this Moment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Moment&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.startSeconds, startSeconds) || other.startSeconds == startSeconds)&&(identical(other.endSeconds, endSeconds) || other.endSeconds == endSeconds)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,videoId,title,artist,thumbnailUrl,startSeconds,endSeconds,isPublic,createdAt,updatedAt,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'Moment(id: $id, userId: $userId, videoId: $videoId, title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, startSeconds: $startSeconds, endSeconds: $endSeconds, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $MomentCopyWith<$Res>  {
  factory $MomentCopyWith(Moment value, $Res Function(Moment) _then) = _$MomentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'video_id') String videoId,@JsonKey(name: 'song_title') String title, String artist,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'start_seconds') double startSeconds,@JsonKey(name: 'end_seconds') double endSeconds,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(includeFromJson: false, includeToJson: false) List<String> tags
});




}
/// @nodoc
class _$MomentCopyWithImpl<$Res>
    implements $MomentCopyWith<$Res> {
  _$MomentCopyWithImpl(this._self, this._then);

  final Moment _self;
  final $Res Function(Moment) _then;

/// Create a copy of Moment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? videoId = null,Object? title = null,Object? artist = null,Object? thumbnailUrl = null,Object? startSeconds = null,Object? endSeconds = null,Object? isPublic = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,startSeconds: null == startSeconds ? _self.startSeconds : startSeconds // ignore: cast_nullable_to_non_nullable
as double,endSeconds: null == endSeconds ? _self.endSeconds : endSeconds // ignore: cast_nullable_to_non_nullable
as double,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Moment].
extension MomentPatterns on Moment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Moment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Moment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Moment value)  $default,){
final _that = this;
switch (_that) {
case _Moment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Moment value)?  $default,){
final _that = this;
switch (_that) {
case _Moment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'video_id')  String videoId, @JsonKey(name: 'song_title')  String title,  String artist, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'start_seconds')  double startSeconds, @JsonKey(name: 'end_seconds')  double endSeconds, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Moment() when $default != null:
return $default(_that.id,_that.userId,_that.videoId,_that.title,_that.artist,_that.thumbnailUrl,_that.startSeconds,_that.endSeconds,_that.isPublic,_that.createdAt,_that.updatedAt,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'video_id')  String videoId, @JsonKey(name: 'song_title')  String title,  String artist, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'start_seconds')  double startSeconds, @JsonKey(name: 'end_seconds')  double endSeconds, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _Moment():
return $default(_that.id,_that.userId,_that.videoId,_that.title,_that.artist,_that.thumbnailUrl,_that.startSeconds,_that.endSeconds,_that.isPublic,_that.createdAt,_that.updatedAt,_that.tags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'video_id')  String videoId, @JsonKey(name: 'song_title')  String title,  String artist, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'start_seconds')  double startSeconds, @JsonKey(name: 'end_seconds')  double endSeconds, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _Moment() when $default != null:
return $default(_that.id,_that.userId,_that.videoId,_that.title,_that.artist,_that.thumbnailUrl,_that.startSeconds,_that.endSeconds,_that.isPublic,_that.createdAt,_that.updatedAt,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Moment extends Moment {
  const _Moment({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'video_id') required this.videoId, @JsonKey(name: 'song_title') required this.title, this.artist = '', @JsonKey(name: 'thumbnail_url') this.thumbnailUrl = '', @JsonKey(name: 'start_seconds') required this.startSeconds, @JsonKey(name: 'end_seconds') required this.endSeconds, @JsonKey(name: 'is_public') this.isPublic = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(includeFromJson: false, includeToJson: false) final  List<String> tags = const <String>[]}): _tags = tags,super._();
  factory _Moment.fromJson(Map<String, dynamic> json) => _$MomentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'video_id') final  String videoId;
@override@JsonKey(name: 'song_title') final  String title;
@override@JsonKey() final  String artist;
@override@JsonKey(name: 'thumbnail_url') final  String thumbnailUrl;
@override@JsonKey(name: 'start_seconds') final  double startSeconds;
@override@JsonKey(name: 'end_seconds') final  double endSeconds;
@override@JsonKey(name: 'is_public') final  bool isPublic;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
 final  List<String> _tags;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of Moment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MomentCopyWith<_Moment> get copyWith => __$MomentCopyWithImpl<_Moment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MomentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Moment&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.startSeconds, startSeconds) || other.startSeconds == startSeconds)&&(identical(other.endSeconds, endSeconds) || other.endSeconds == endSeconds)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,videoId,title,artist,thumbnailUrl,startSeconds,endSeconds,isPublic,createdAt,updatedAt,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'Moment(id: $id, userId: $userId, videoId: $videoId, title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, startSeconds: $startSeconds, endSeconds: $endSeconds, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$MomentCopyWith<$Res> implements $MomentCopyWith<$Res> {
  factory _$MomentCopyWith(_Moment value, $Res Function(_Moment) _then) = __$MomentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'video_id') String videoId,@JsonKey(name: 'song_title') String title, String artist,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'start_seconds') double startSeconds,@JsonKey(name: 'end_seconds') double endSeconds,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(includeFromJson: false, includeToJson: false) List<String> tags
});




}
/// @nodoc
class __$MomentCopyWithImpl<$Res>
    implements _$MomentCopyWith<$Res> {
  __$MomentCopyWithImpl(this._self, this._then);

  final _Moment _self;
  final $Res Function(_Moment) _then;

/// Create a copy of Moment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? videoId = null,Object? title = null,Object? artist = null,Object? thumbnailUrl = null,Object? startSeconds = null,Object? endSeconds = null,Object? isPublic = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? tags = null,}) {
  return _then(_Moment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,startSeconds: null == startSeconds ? _self.startSeconds : startSeconds // ignore: cast_nullable_to_non_nullable
as double,endSeconds: null == endSeconds ? _self.endSeconds : endSeconds // ignore: cast_nullable_to_non_nullable
as double,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
