// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trim_selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrimSelection {

 String get videoId; String get title; String get artist; String get thumbnailUrl; double get totalDurationSeconds; double get startSeconds; double get endSeconds; bool get isPreviewing;
/// Create a copy of TrimSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrimSelectionCopyWith<TrimSelection> get copyWith => _$TrimSelectionCopyWithImpl<TrimSelection>(this as TrimSelection, _$identity);

  /// Serializes this TrimSelection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrimSelection&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.startSeconds, startSeconds) || other.startSeconds == startSeconds)&&(identical(other.endSeconds, endSeconds) || other.endSeconds == endSeconds)&&(identical(other.isPreviewing, isPreviewing) || other.isPreviewing == isPreviewing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,title,artist,thumbnailUrl,totalDurationSeconds,startSeconds,endSeconds,isPreviewing);

@override
String toString() {
  return 'TrimSelection(videoId: $videoId, title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, totalDurationSeconds: $totalDurationSeconds, startSeconds: $startSeconds, endSeconds: $endSeconds, isPreviewing: $isPreviewing)';
}


}

/// @nodoc
abstract mixin class $TrimSelectionCopyWith<$Res>  {
  factory $TrimSelectionCopyWith(TrimSelection value, $Res Function(TrimSelection) _then) = _$TrimSelectionCopyWithImpl;
@useResult
$Res call({
 String videoId, String title, String artist, String thumbnailUrl, double totalDurationSeconds, double startSeconds, double endSeconds, bool isPreviewing
});




}
/// @nodoc
class _$TrimSelectionCopyWithImpl<$Res>
    implements $TrimSelectionCopyWith<$Res> {
  _$TrimSelectionCopyWithImpl(this._self, this._then);

  final TrimSelection _self;
  final $Res Function(TrimSelection) _then;

/// Create a copy of TrimSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? title = null,Object? artist = null,Object? thumbnailUrl = null,Object? totalDurationSeconds = null,Object? startSeconds = null,Object? endSeconds = null,Object? isPreviewing = null,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as double,startSeconds: null == startSeconds ? _self.startSeconds : startSeconds // ignore: cast_nullable_to_non_nullable
as double,endSeconds: null == endSeconds ? _self.endSeconds : endSeconds // ignore: cast_nullable_to_non_nullable
as double,isPreviewing: null == isPreviewing ? _self.isPreviewing : isPreviewing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrimSelection].
extension TrimSelectionPatterns on TrimSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrimSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrimSelection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrimSelection value)  $default,){
final _that = this;
switch (_that) {
case _TrimSelection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrimSelection value)?  $default,){
final _that = this;
switch (_that) {
case _TrimSelection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  String title,  String artist,  String thumbnailUrl,  double totalDurationSeconds,  double startSeconds,  double endSeconds,  bool isPreviewing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrimSelection() when $default != null:
return $default(_that.videoId,_that.title,_that.artist,_that.thumbnailUrl,_that.totalDurationSeconds,_that.startSeconds,_that.endSeconds,_that.isPreviewing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  String title,  String artist,  String thumbnailUrl,  double totalDurationSeconds,  double startSeconds,  double endSeconds,  bool isPreviewing)  $default,) {final _that = this;
switch (_that) {
case _TrimSelection():
return $default(_that.videoId,_that.title,_that.artist,_that.thumbnailUrl,_that.totalDurationSeconds,_that.startSeconds,_that.endSeconds,_that.isPreviewing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  String title,  String artist,  String thumbnailUrl,  double totalDurationSeconds,  double startSeconds,  double endSeconds,  bool isPreviewing)?  $default,) {final _that = this;
switch (_that) {
case _TrimSelection() when $default != null:
return $default(_that.videoId,_that.title,_that.artist,_that.thumbnailUrl,_that.totalDurationSeconds,_that.startSeconds,_that.endSeconds,_that.isPreviewing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrimSelection extends TrimSelection {
  const _TrimSelection({required this.videoId, required this.title, required this.artist, this.thumbnailUrl = '', required this.totalDurationSeconds, required this.startSeconds, required this.endSeconds, this.isPreviewing = false}): super._();
  factory _TrimSelection.fromJson(Map<String, dynamic> json) => _$TrimSelectionFromJson(json);

@override final  String videoId;
@override final  String title;
@override final  String artist;
@override@JsonKey() final  String thumbnailUrl;
@override final  double totalDurationSeconds;
@override final  double startSeconds;
@override final  double endSeconds;
@override@JsonKey() final  bool isPreviewing;

/// Create a copy of TrimSelection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrimSelectionCopyWith<_TrimSelection> get copyWith => __$TrimSelectionCopyWithImpl<_TrimSelection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrimSelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrimSelection&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.startSeconds, startSeconds) || other.startSeconds == startSeconds)&&(identical(other.endSeconds, endSeconds) || other.endSeconds == endSeconds)&&(identical(other.isPreviewing, isPreviewing) || other.isPreviewing == isPreviewing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,title,artist,thumbnailUrl,totalDurationSeconds,startSeconds,endSeconds,isPreviewing);

@override
String toString() {
  return 'TrimSelection(videoId: $videoId, title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, totalDurationSeconds: $totalDurationSeconds, startSeconds: $startSeconds, endSeconds: $endSeconds, isPreviewing: $isPreviewing)';
}


}

/// @nodoc
abstract mixin class _$TrimSelectionCopyWith<$Res> implements $TrimSelectionCopyWith<$Res> {
  factory _$TrimSelectionCopyWith(_TrimSelection value, $Res Function(_TrimSelection) _then) = __$TrimSelectionCopyWithImpl;
@override @useResult
$Res call({
 String videoId, String title, String artist, String thumbnailUrl, double totalDurationSeconds, double startSeconds, double endSeconds, bool isPreviewing
});




}
/// @nodoc
class __$TrimSelectionCopyWithImpl<$Res>
    implements _$TrimSelectionCopyWith<$Res> {
  __$TrimSelectionCopyWithImpl(this._self, this._then);

  final _TrimSelection _self;
  final $Res Function(_TrimSelection) _then;

/// Create a copy of TrimSelection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? title = null,Object? artist = null,Object? thumbnailUrl = null,Object? totalDurationSeconds = null,Object? startSeconds = null,Object? endSeconds = null,Object? isPreviewing = null,}) {
  return _then(_TrimSelection(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as double,startSeconds: null == startSeconds ? _self.startSeconds : startSeconds // ignore: cast_nullable_to_non_nullable
as double,endSeconds: null == endSeconds ? _self.endSeconds : endSeconds // ignore: cast_nullable_to_non_nullable
as double,isPreviewing: null == isPreviewing ? _self.isPreviewing : isPreviewing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
