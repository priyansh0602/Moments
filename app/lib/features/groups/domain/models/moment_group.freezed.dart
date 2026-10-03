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

 String get id;@JsonKey(name: 'user_id') String get userId; String get name; String? get description;@JsonKey(name: 'cover_thumbnail_url') String? get coverThumbnailUrl;@JsonKey(name: 'is_public') bool get isPublic;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(readValue: _readMomentCount) int get momentCount;
/// Create a copy of MomentGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MomentGroupCopyWith<MomentGroup> get copyWith => _$MomentGroupCopyWithImpl<MomentGroup>(this as MomentGroup, _$identity);

  /// Serializes this MomentGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MomentGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverThumbnailUrl, coverThumbnailUrl) || other.coverThumbnailUrl == coverThumbnailUrl)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.momentCount, momentCount) || other.momentCount == momentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,coverThumbnailUrl,isPublic,createdAt,updatedAt,momentCount);

@override
String toString() {
  return 'MomentGroup(id: $id, userId: $userId, name: $name, description: $description, coverThumbnailUrl: $coverThumbnailUrl, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt, momentCount: $momentCount)';
}


}

/// @nodoc
abstract mixin class $MomentGroupCopyWith<$Res>  {
  factory $MomentGroupCopyWith(MomentGroup value, $Res Function(MomentGroup) _then) = _$MomentGroupCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String? description,@JsonKey(name: 'cover_thumbnail_url') String? coverThumbnailUrl,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(readValue: _readMomentCount) int momentCount
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? coverThumbnailUrl = freezed,Object? isPublic = null,Object? createdAt = null,Object? updatedAt = freezed,Object? momentCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverThumbnailUrl: freezed == coverThumbnailUrl ? _self.coverThumbnailUrl : coverThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,momentCount: null == momentCount ? _self.momentCount : momentCount // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description, @JsonKey(name: 'cover_thumbnail_url')  String? coverThumbnailUrl, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(readValue: _readMomentCount)  int momentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MomentGroup() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.coverThumbnailUrl,_that.isPublic,_that.createdAt,_that.updatedAt,_that.momentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description, @JsonKey(name: 'cover_thumbnail_url')  String? coverThumbnailUrl, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(readValue: _readMomentCount)  int momentCount)  $default,) {final _that = this;
switch (_that) {
case _MomentGroup():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.coverThumbnailUrl,_that.isPublic,_that.createdAt,_that.updatedAt,_that.momentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  String? description, @JsonKey(name: 'cover_thumbnail_url')  String? coverThumbnailUrl, @JsonKey(name: 'is_public')  bool isPublic, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(readValue: _readMomentCount)  int momentCount)?  $default,) {final _that = this;
switch (_that) {
case _MomentGroup() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.coverThumbnailUrl,_that.isPublic,_that.createdAt,_that.updatedAt,_that.momentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MomentGroup implements MomentGroup {
  const _MomentGroup({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, this.description, @JsonKey(name: 'cover_thumbnail_url') this.coverThumbnailUrl, @JsonKey(name: 'is_public') this.isPublic = false, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(readValue: _readMomentCount) this.momentCount = 0});
  factory _MomentGroup.fromJson(Map<String, dynamic> json) => _$MomentGroupFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override final  String? description;
@override@JsonKey(name: 'cover_thumbnail_url') final  String? coverThumbnailUrl;
@override@JsonKey(name: 'is_public') final  bool isPublic;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(readValue: _readMomentCount) final  int momentCount;

/// Create a copy of MomentGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MomentGroupCopyWith<_MomentGroup> get copyWith => __$MomentGroupCopyWithImpl<_MomentGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MomentGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MomentGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverThumbnailUrl, coverThumbnailUrl) || other.coverThumbnailUrl == coverThumbnailUrl)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.momentCount, momentCount) || other.momentCount == momentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,coverThumbnailUrl,isPublic,createdAt,updatedAt,momentCount);

@override
String toString() {
  return 'MomentGroup(id: $id, userId: $userId, name: $name, description: $description, coverThumbnailUrl: $coverThumbnailUrl, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt, momentCount: $momentCount)';
}


}

/// @nodoc
abstract mixin class _$MomentGroupCopyWith<$Res> implements $MomentGroupCopyWith<$Res> {
  factory _$MomentGroupCopyWith(_MomentGroup value, $Res Function(_MomentGroup) _then) = __$MomentGroupCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, String? description,@JsonKey(name: 'cover_thumbnail_url') String? coverThumbnailUrl,@JsonKey(name: 'is_public') bool isPublic,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(readValue: _readMomentCount) int momentCount
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? coverThumbnailUrl = freezed,Object? isPublic = null,Object? createdAt = null,Object? updatedAt = freezed,Object? momentCount = null,}) {
  return _then(_MomentGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverThumbnailUrl: freezed == coverThumbnailUrl ? _self.coverThumbnailUrl : coverThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,momentCount: null == momentCount ? _self.momentCount : momentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
