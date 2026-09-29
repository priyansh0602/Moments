// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mini_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MiniPlayerState {

 String get title; String get artist; String? get thumbnailUrl; bool get isPlaying; double get progress; bool get isVisible; String get currentTimestamp; String get totalDuration;
/// Create a copy of MiniPlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniPlayerStateCopyWith<MiniPlayerState> get copyWith => _$MiniPlayerStateCopyWithImpl<MiniPlayerState>(this as MiniPlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniPlayerState&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.currentTimestamp, currentTimestamp) || other.currentTimestamp == currentTimestamp)&&(identical(other.totalDuration, totalDuration) || other.totalDuration == totalDuration));
}


@override
int get hashCode => Object.hash(runtimeType,title,artist,thumbnailUrl,isPlaying,progress,isVisible,currentTimestamp,totalDuration);

@override
String toString() {
  return 'MiniPlayerState(title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, isPlaying: $isPlaying, progress: $progress, isVisible: $isVisible, currentTimestamp: $currentTimestamp, totalDuration: $totalDuration)';
}


}

/// @nodoc
abstract mixin class $MiniPlayerStateCopyWith<$Res>  {
  factory $MiniPlayerStateCopyWith(MiniPlayerState value, $Res Function(MiniPlayerState) _then) = _$MiniPlayerStateCopyWithImpl;
@useResult
$Res call({
 String title, String artist, String? thumbnailUrl, bool isPlaying, double progress, bool isVisible, String currentTimestamp, String totalDuration
});




}
/// @nodoc
class _$MiniPlayerStateCopyWithImpl<$Res>
    implements $MiniPlayerStateCopyWith<$Res> {
  _$MiniPlayerStateCopyWithImpl(this._self, this._then);

  final MiniPlayerState _self;
  final $Res Function(MiniPlayerState) _then;

/// Create a copy of MiniPlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? artist = null,Object? thumbnailUrl = freezed,Object? isPlaying = null,Object? progress = null,Object? isVisible = null,Object? currentTimestamp = null,Object? totalDuration = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,currentTimestamp: null == currentTimestamp ? _self.currentTimestamp : currentTimestamp // ignore: cast_nullable_to_non_nullable
as String,totalDuration: null == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniPlayerState].
extension MiniPlayerStatePatterns on MiniPlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniPlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniPlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniPlayerState value)  $default,){
final _that = this;
switch (_that) {
case _MiniPlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniPlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _MiniPlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String artist,  String? thumbnailUrl,  bool isPlaying,  double progress,  bool isVisible,  String currentTimestamp,  String totalDuration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniPlayerState() when $default != null:
return $default(_that.title,_that.artist,_that.thumbnailUrl,_that.isPlaying,_that.progress,_that.isVisible,_that.currentTimestamp,_that.totalDuration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String artist,  String? thumbnailUrl,  bool isPlaying,  double progress,  bool isVisible,  String currentTimestamp,  String totalDuration)  $default,) {final _that = this;
switch (_that) {
case _MiniPlayerState():
return $default(_that.title,_that.artist,_that.thumbnailUrl,_that.isPlaying,_that.progress,_that.isVisible,_that.currentTimestamp,_that.totalDuration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String artist,  String? thumbnailUrl,  bool isPlaying,  double progress,  bool isVisible,  String currentTimestamp,  String totalDuration)?  $default,) {final _that = this;
switch (_that) {
case _MiniPlayerState() when $default != null:
return $default(_that.title,_that.artist,_that.thumbnailUrl,_that.isPlaying,_that.progress,_that.isVisible,_that.currentTimestamp,_that.totalDuration);case _:
  return null;

}
}

}

/// @nodoc


class _MiniPlayerState implements MiniPlayerState {
  const _MiniPlayerState({required this.title, required this.artist, this.thumbnailUrl, this.isPlaying = false, this.progress = 0.35, this.isVisible = true, this.currentTimestamp = '01:12', this.totalDuration = '03:48'});
  

@override final  String title;
@override final  String artist;
@override final  String? thumbnailUrl;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  double progress;
@override@JsonKey() final  bool isVisible;
@override@JsonKey() final  String currentTimestamp;
@override@JsonKey() final  String totalDuration;

/// Create a copy of MiniPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniPlayerStateCopyWith<_MiniPlayerState> get copyWith => __$MiniPlayerStateCopyWithImpl<_MiniPlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniPlayerState&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.currentTimestamp, currentTimestamp) || other.currentTimestamp == currentTimestamp)&&(identical(other.totalDuration, totalDuration) || other.totalDuration == totalDuration));
}


@override
int get hashCode => Object.hash(runtimeType,title,artist,thumbnailUrl,isPlaying,progress,isVisible,currentTimestamp,totalDuration);

@override
String toString() {
  return 'MiniPlayerState(title: $title, artist: $artist, thumbnailUrl: $thumbnailUrl, isPlaying: $isPlaying, progress: $progress, isVisible: $isVisible, currentTimestamp: $currentTimestamp, totalDuration: $totalDuration)';
}


}

/// @nodoc
abstract mixin class _$MiniPlayerStateCopyWith<$Res> implements $MiniPlayerStateCopyWith<$Res> {
  factory _$MiniPlayerStateCopyWith(_MiniPlayerState value, $Res Function(_MiniPlayerState) _then) = __$MiniPlayerStateCopyWithImpl;
@override @useResult
$Res call({
 String title, String artist, String? thumbnailUrl, bool isPlaying, double progress, bool isVisible, String currentTimestamp, String totalDuration
});




}
/// @nodoc
class __$MiniPlayerStateCopyWithImpl<$Res>
    implements _$MiniPlayerStateCopyWith<$Res> {
  __$MiniPlayerStateCopyWithImpl(this._self, this._then);

  final _MiniPlayerState _self;
  final $Res Function(_MiniPlayerState) _then;

/// Create a copy of MiniPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? artist = null,Object? thumbnailUrl = freezed,Object? isPlaying = null,Object? progress = null,Object? isVisible = null,Object? currentTimestamp = null,Object? totalDuration = null,}) {
  return _then(_MiniPlayerState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,currentTimestamp: null == currentTimestamp ? _self.currentTimestamp : currentTimestamp // ignore: cast_nullable_to_non_nullable
as String,totalDuration: null == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
