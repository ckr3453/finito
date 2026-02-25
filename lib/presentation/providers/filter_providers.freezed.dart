// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskFilter {

 TaskStatus? get status; Priority? get priority; String? get categoryId; String? get searchQuery; TaskSortBy get sortBy;
/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskFilterCopyWith<TaskFilter> get copyWith => _$TaskFilterCopyWithImpl<TaskFilter>(this as TaskFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}


@override
int get hashCode => Object.hash(runtimeType,status,priority,categoryId,searchQuery,sortBy);

@override
String toString() {
  return 'TaskFilter(status: $status, priority: $priority, categoryId: $categoryId, searchQuery: $searchQuery, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class $TaskFilterCopyWith<$Res>  {
  factory $TaskFilterCopyWith(TaskFilter value, $Res Function(TaskFilter) _then) = _$TaskFilterCopyWithImpl;
@useResult
$Res call({
 TaskStatus? status, Priority? priority, String? categoryId, String? searchQuery, TaskSortBy sortBy
});




}
/// @nodoc
class _$TaskFilterCopyWithImpl<$Res>
    implements $TaskFilterCopyWith<$Res> {
  _$TaskFilterCopyWithImpl(this._self, this._then);

  final TaskFilter _self;
  final $Res Function(TaskFilter) _then;

/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? priority = freezed,Object? categoryId = freezed,Object? searchQuery = freezed,Object? sortBy = null,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as TaskSortBy,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskFilter].
extension TaskFilterPatterns on TaskFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskFilter value)  $default,){
final _that = this;
switch (_that) {
case _TaskFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskFilter value)?  $default,){
final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TaskStatus? status,  Priority? priority,  String? categoryId,  String? searchQuery,  TaskSortBy sortBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
return $default(_that.status,_that.priority,_that.categoryId,_that.searchQuery,_that.sortBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TaskStatus? status,  Priority? priority,  String? categoryId,  String? searchQuery,  TaskSortBy sortBy)  $default,) {final _that = this;
switch (_that) {
case _TaskFilter():
return $default(_that.status,_that.priority,_that.categoryId,_that.searchQuery,_that.sortBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TaskStatus? status,  Priority? priority,  String? categoryId,  String? searchQuery,  TaskSortBy sortBy)?  $default,) {final _that = this;
switch (_that) {
case _TaskFilter() when $default != null:
return $default(_that.status,_that.priority,_that.categoryId,_that.searchQuery,_that.sortBy);case _:
  return null;

}
}

}

/// @nodoc


class _TaskFilter implements TaskFilter {
  const _TaskFilter({this.status, this.priority, this.categoryId, this.searchQuery, this.sortBy = TaskSortBy.dueDate});
  

@override final  TaskStatus? status;
@override final  Priority? priority;
@override final  String? categoryId;
@override final  String? searchQuery;
@override@JsonKey() final  TaskSortBy sortBy;

/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskFilterCopyWith<_TaskFilter> get copyWith => __$TaskFilterCopyWithImpl<_TaskFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}


@override
int get hashCode => Object.hash(runtimeType,status,priority,categoryId,searchQuery,sortBy);

@override
String toString() {
  return 'TaskFilter(status: $status, priority: $priority, categoryId: $categoryId, searchQuery: $searchQuery, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class _$TaskFilterCopyWith<$Res> implements $TaskFilterCopyWith<$Res> {
  factory _$TaskFilterCopyWith(_TaskFilter value, $Res Function(_TaskFilter) _then) = __$TaskFilterCopyWithImpl;
@override @useResult
$Res call({
 TaskStatus? status, Priority? priority, String? categoryId, String? searchQuery, TaskSortBy sortBy
});




}
/// @nodoc
class __$TaskFilterCopyWithImpl<$Res>
    implements _$TaskFilterCopyWith<$Res> {
  __$TaskFilterCopyWithImpl(this._self, this._then);

  final _TaskFilter _self;
  final $Res Function(_TaskFilter) _then;

/// Create a copy of TaskFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? priority = freezed,Object? categoryId = freezed,Object? searchQuery = freezed,Object? sortBy = null,}) {
  return _then(_TaskFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as TaskSortBy,
  ));
}


}

// dart format on
