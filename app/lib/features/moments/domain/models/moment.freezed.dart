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

 String get id; String get title; String get artist; String get thumbnailUrl; double get startSeconds; double get endSeconds; String get songId; List<String> get tags;
/// Create a copy of Moment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MomentCopyWith<Moment> get copyWith => _$MomentCopyWithImpl<Moment>(this as Moment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Moment&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.startSeconds, startSeconds) || other.startSeconds == startSeconds)&&(identical(other.endSeconds, endSeconds) || other.endSeconds == endSeconds)&&(identical(other.songId, songId) || other.songId == songId)&&const DeepCollectionEquality().equals(other.tags, tags));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,artist,thumbnailUrl,startSeconds,endSeconds,songId,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'Moment(id: $id, title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, startSeconds: $startSeconds, endSeconds: $endSeconds, songId: $songId, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $MomentCopyWith<$Res>  {
  factory $MomentCopyWith(Moment value, $Res Function(Moment) _then) = _$MomentCopyWithImpl;
@useResult
$Res call({
 String id, String title, String artist, String thumbnailUrl, double startSeconds, double endSeconds, String songId, List<String> tags
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? thumbnailUrl = null,Object? startSeconds = null,Object? endSeconds = null,Object? songId = null,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,startSeconds: null == startSeconds ? _self.startSeconds : startSeconds // ignore: cast_nullable_to_non_nullable
as double,endSeconds: null == endSeconds ? _self.endSeconds : endSeconds // ignore: cast_nullable_to_non_nullable
as double,songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String thumbnailUrl,  double startSeconds,  double endSeconds,  String songId,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Moment() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.thumbnailUrl,_that.startSeconds,_that.endSeconds,_that.songId,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String thumbnailUrl,  double startSeconds,  double endSeconds,  String songId,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _Moment():
return $default(_that.id,_that.title,_that.artist,_that.thumbnailUrl,_that.startSeconds,_that.endSeconds,_that.songId,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String artist,  String thumbnailUrl,  double startSeconds,  double endSeconds,  String songId,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _Moment() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.thumbnailUrl,_that.startSeconds,_that.endSeconds,_that.songId,_that.tags);case _:
  return null;

}
}

}

/// @nodoc


class _Moment implements Moment {
  const _Moment({required this.id, required this.title, required this.artist, required this.thumbnailUrl, required this.startSeconds, required this.endSeconds, required this.songId, final  List<String> tags = const <String>[]}): _tags = tags;
  

@override final  String id;
@override final  String title;
@override final  String artist;
@override final  String thumbnailUrl;
@override final  double startSeconds;
@override final  double endSeconds;
@override final  String songId;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Moment&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.startSeconds, startSeconds) || other.startSeconds == startSeconds)&&(identical(other.endSeconds, endSeconds) || other.endSeconds == endSeconds)&&(identical(other.songId, songId) || other.songId == songId)&&const DeepCollectionEquality().equals(other._tags, _tags));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,artist,thumbnailUrl,startSeconds,endSeconds,songId,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'Moment(id: $id, title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, startSeconds: $startSeconds, endSeconds: $endSeconds, songId: $songId, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$MomentCopyWith<$Res> implements $MomentCopyWith<$Res> {
  factory _$MomentCopyWith(_Moment value, $Res Function(_Moment) _then) = __$MomentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String artist, String thumbnailUrl, double startSeconds, double endSeconds, String songId, List<String> tags
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? thumbnailUrl = null,Object? startSeconds = null,Object? endSeconds = null,Object? songId = null,Object? tags = null,}) {
  return _then(_Moment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,startSeconds: null == startSeconds ? _self.startSeconds : startSeconds // ignore: cast_nullable_to_non_nullable
as double,endSeconds: null == endSeconds ? _self.endSeconds : endSeconds // ignore: cast_nullable_to_non_nullable
as double,songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
