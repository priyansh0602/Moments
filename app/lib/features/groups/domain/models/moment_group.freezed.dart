// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moment_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MomentGroup {

 String get id; String get name; int get momentCount; List<String> get thumbnailUrls; String? get description;
/// Create a copy of MomentGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MomentGroupCopyWith<MomentGroup> get copyWith => _$MomentGroupCopyWithImpl<MomentGroup>(this as MomentGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MomentGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.momentCount, momentCount) || other.momentCount == momentCount)&&const DeepCollectionEquality().equals(other.thumbnailUrls, thumbnailUrls)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,momentCount,const DeepCollectionEquality().hash(thumbnailUrls),description);

@override
String toString() {
  return 'MomentGroup(id: $id, name: $name, momentCount: $momentCount, thumbnailUrls: $thumbnailUrls, description: $description)';
}


}

/// @nodoc
abstract mixin class $MomentGroupCopyWith<$Res>  {
  factory $MomentGroupCopyWith(MomentGroup value, $Res Function(MomentGroup) _then) = _$MomentGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, int momentCount, List<String> thumbnailUrls, String? description
});




}
/// @nodoc
class _$MomentGroupCopyWithImpl<$Res>
    implements $MomentGroupCopyWith<$Res> {
  _$MomentGroupCopyWithImpl(this._self, this._then);

  final MomentGroup _self;
  final $Res Function(MomentGroup) _then;

/// Create a copy of MomentGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? momentCount = null,Object? thumbnailUrls = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,momentCount: null == momentCount ? _self.momentCount : momentCount // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrls: null == thumbnailUrls ? _self.thumbnailUrls : thumbnailUrls // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MomentGroup].
extension MomentGroupPatterns on MomentGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MomentGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MomentGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MomentGroup value)  $default,){
final _that = this;
switch (_that) {
case _MomentGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MomentGroup value)?  $default,){
final _that = this;
switch (_that) {
case _MomentGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int momentCount,  List<String> thumbnailUrls,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MomentGroup() when $default != null:
return $default(_that.id,_that.name,_that.momentCount,_that.thumbnailUrls,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int momentCount,  List<String> thumbnailUrls,  String? description)  $default,) {final _that = this;
switch (_that) {
case _MomentGroup():
return $default(_that.id,_that.name,_that.momentCount,_that.thumbnailUrls,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int momentCount,  List<String> thumbnailUrls,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _MomentGroup() when $default != null:
return $default(_that.id,_that.name,_that.momentCount,_that.thumbnailUrls,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _MomentGroup implements MomentGroup {
  const _MomentGroup({required this.id, required this.name, required this.momentCount, final  List<String> thumbnailUrls = const <String>[], this.description}): _thumbnailUrls = thumbnailUrls;
  

@override final  String id;
@override final  String name;
@override final  int momentCount;
 final  List<String> _thumbnailUrls;
@override@JsonKey() List<String> get thumbnailUrls {
  if (_thumbnailUrls is EqualUnmodifiableListView) return _thumbnailUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_thumbnailUrls);
}

@override final  String? description;

/// Create a copy of MomentGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MomentGroupCopyWith<_MomentGroup> get copyWith => __$MomentGroupCopyWithImpl<_MomentGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MomentGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.momentCount, momentCount) || other.momentCount == momentCount)&&const DeepCollectionEquality().equals(other._thumbnailUrls, _thumbnailUrls)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,momentCount,const DeepCollectionEquality().hash(_thumbnailUrls),description);

@override
String toString() {
  return 'MomentGroup(id: $id, name: $name, momentCount: $momentCount, thumbnailUrls: $thumbnailUrls, description: $description)';
}


}

/// @nodoc
abstract mixin class _$MomentGroupCopyWith<$Res> implements $MomentGroupCopyWith<$Res> {
  factory _$MomentGroupCopyWith(_MomentGroup value, $Res Function(_MomentGroup) _then) = __$MomentGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int momentCount, List<String> thumbnailUrls, String? description
});




}
/// @nodoc
class __$MomentGroupCopyWithImpl<$Res>
    implements _$MomentGroupCopyWith<$Res> {
  __$MomentGroupCopyWithImpl(this._self, this._then);

  final _MomentGroup _self;
  final $Res Function(_MomentGroup) _then;

/// Create a copy of MomentGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? momentCount = null,Object? thumbnailUrls = null,Object? description = freezed,}) {
  return _then(_MomentGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,momentCount: null == momentCount ? _self.momentCount : momentCount // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrls: null == thumbnailUrls ? _self._thumbnailUrls : thumbnailUrls // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
