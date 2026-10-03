// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupItem {

 String get id;@JsonKey(name: 'group_id') String get groupId;@JsonKey(name: 'moment_id') String get momentId; int get position;@JsonKey(name: 'added_at') DateTime get addedAt;@JsonKey(readValue: _readMoment) Moment get moment;
/// Create a copy of GroupItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupItemCopyWith<GroupItem> get copyWith => _$GroupItemCopyWithImpl<GroupItem>(this as GroupItem, _$identity);

  /// Serializes this GroupItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupItem&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.momentId, momentId) || other.momentId == momentId)&&(identical(other.position, position) || other.position == position)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.moment, moment) || other.moment == moment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,momentId,position,addedAt,moment);

@override
String toString() {
  return 'GroupItem(id: $id, groupId: $groupId, momentId: $momentId, position: $position, addedAt: $addedAt, moment: $moment)';
}


}

/// @nodoc
abstract mixin class $GroupItemCopyWith<$Res>  {
  factory $GroupItemCopyWith(GroupItem value, $Res Function(GroupItem) _then) = _$GroupItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'group_id') String groupId,@JsonKey(name: 'moment_id') String momentId, int position,@JsonKey(name: 'added_at') DateTime addedAt,@JsonKey(readValue: _readMoment) Moment moment
});


$MomentCopyWith<$Res> get moment;

}
/// @nodoc
class _$GroupItemCopyWithImpl<$Res>
    implements $GroupItemCopyWith<$Res> {
  _$GroupItemCopyWithImpl(this._self, this._then);

  final GroupItem _self;
  final $Res Function(GroupItem) _then;

/// Create a copy of GroupItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? momentId = null,Object? position = null,Object? addedAt = null,Object? moment = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,momentId: null == momentId ? _self.momentId : momentId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,moment: null == moment ? _self.moment : moment // ignore: cast_nullable_to_non_nullable
as Moment,
  ));
}
/// Create a copy of GroupItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MomentCopyWith<$Res> get moment {
  
  return $MomentCopyWith<$Res>(_self.moment, (value) {
    return _then(_self.copyWith(moment: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupItem].
extension GroupItemPatterns on GroupItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupItem value)  $default,){
final _that = this;
switch (_that) {
case _GroupItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupItem value)?  $default,){
final _that = this;
switch (_that) {
case _GroupItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'group_id')  String groupId, @JsonKey(name: 'moment_id')  String momentId,  int position, @JsonKey(name: 'added_at')  DateTime addedAt, @JsonKey(readValue: _readMoment)  Moment moment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupItem() when $default != null:
return $default(_that.id,_that.groupId,_that.momentId,_that.position,_that.addedAt,_that.moment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'group_id')  String groupId, @JsonKey(name: 'moment_id')  String momentId,  int position, @JsonKey(name: 'added_at')  DateTime addedAt, @JsonKey(readValue: _readMoment)  Moment moment)  $default,) {final _that = this;
switch (_that) {
case _GroupItem():
return $default(_that.id,_that.groupId,_that.momentId,_that.position,_that.addedAt,_that.moment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'group_id')  String groupId, @JsonKey(name: 'moment_id')  String momentId,  int position, @JsonKey(name: 'added_at')  DateTime addedAt, @JsonKey(readValue: _readMoment)  Moment moment)?  $default,) {final _that = this;
switch (_that) {
case _GroupItem() when $default != null:
return $default(_that.id,_that.groupId,_that.momentId,_that.position,_that.addedAt,_that.moment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupItem implements GroupItem {
  const _GroupItem({required this.id, @JsonKey(name: 'group_id') required this.groupId, @JsonKey(name: 'moment_id') required this.momentId, required this.position, @JsonKey(name: 'added_at') required this.addedAt, @JsonKey(readValue: _readMoment) required this.moment});
  factory _GroupItem.fromJson(Map<String, dynamic> json) => _$GroupItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'group_id') final  String groupId;
@override@JsonKey(name: 'moment_id') final  String momentId;
@override final  int position;
@override@JsonKey(name: 'added_at') final  DateTime addedAt;
@override@JsonKey(readValue: _readMoment) final  Moment moment;

/// Create a copy of GroupItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupItemCopyWith<_GroupItem> get copyWith => __$GroupItemCopyWithImpl<_GroupItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupItem&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.momentId, momentId) || other.momentId == momentId)&&(identical(other.position, position) || other.position == position)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.moment, moment) || other.moment == moment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,momentId,position,addedAt,moment);

@override
String toString() {
  return 'GroupItem(id: $id, groupId: $groupId, momentId: $momentId, position: $position, addedAt: $addedAt, moment: $moment)';
}


}

/// @nodoc
abstract mixin class _$GroupItemCopyWith<$Res> implements $GroupItemCopyWith<$Res> {
  factory _$GroupItemCopyWith(_GroupItem value, $Res Function(_GroupItem) _then) = __$GroupItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'group_id') String groupId,@JsonKey(name: 'moment_id') String momentId, int position,@JsonKey(name: 'added_at') DateTime addedAt,@JsonKey(readValue: _readMoment) Moment moment
});


@override $MomentCopyWith<$Res> get moment;

}
/// @nodoc
class __$GroupItemCopyWithImpl<$Res>
    implements _$GroupItemCopyWith<$Res> {
  __$GroupItemCopyWithImpl(this._self, this._then);

  final _GroupItem _self;
  final $Res Function(_GroupItem) _then;

/// Create a copy of GroupItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? momentId = null,Object? position = null,Object? addedAt = null,Object? moment = null,}) {
  return _then(_GroupItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,momentId: null == momentId ? _self.momentId : momentId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,moment: null == moment ? _self.moment : moment // ignore: cast_nullable_to_non_nullable
as Moment,
  ));
}

/// Create a copy of GroupItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MomentCopyWith<$Res> get moment {
  
  return $MomentCopyWith<$Res>(_self.moment, (value) {
    return _then(_self.copyWith(moment: value));
  });
}
}

// dart format on
