// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planner_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlannerCategory _$PlannerCategoryFromJson(Map<String, dynamic> json) {
  return _PlannerCategory.fromJson(json);
}

/// @nodoc
mixin _$PlannerCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  double get originalValue => throw _privateConstructorUsedError;
  double get budgetValue => throw _privateConstructorUsedError;

  /// Serializes this PlannerCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlannerCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlannerCategoryCopyWith<PlannerCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlannerCategoryCopyWith<$Res> {
  factory $PlannerCategoryCopyWith(
    PlannerCategory value,
    $Res Function(PlannerCategory) then,
  ) = _$PlannerCategoryCopyWithImpl<$Res, PlannerCategory>;
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    String accountId,
    double originalValue,
    double budgetValue,
  });
}

/// @nodoc
class _$PlannerCategoryCopyWithImpl<$Res, $Val extends PlannerCategory>
    implements $PlannerCategoryCopyWith<$Res> {
  _$PlannerCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlannerCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? accountId = null,
    Object? originalValue = null,
    Object? budgetValue = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String,
            originalValue: null == originalValue
                ? _value.originalValue
                : originalValue // ignore: cast_nullable_to_non_nullable
                      as double,
            budgetValue: null == budgetValue
                ? _value.budgetValue
                : budgetValue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlannerCategoryImplCopyWith<$Res>
    implements $PlannerCategoryCopyWith<$Res> {
  factory _$$PlannerCategoryImplCopyWith(
    _$PlannerCategoryImpl value,
    $Res Function(_$PlannerCategoryImpl) then,
  ) = __$$PlannerCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    String accountId,
    double originalValue,
    double budgetValue,
  });
}

/// @nodoc
class __$$PlannerCategoryImplCopyWithImpl<$Res>
    extends _$PlannerCategoryCopyWithImpl<$Res, _$PlannerCategoryImpl>
    implements _$$PlannerCategoryImplCopyWith<$Res> {
  __$$PlannerCategoryImplCopyWithImpl(
    _$PlannerCategoryImpl _value,
    $Res Function(_$PlannerCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlannerCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? accountId = null,
    Object? originalValue = null,
    Object? budgetValue = null,
  }) {
    return _then(
      _$PlannerCategoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String,
        originalValue: null == originalValue
            ? _value.originalValue
            : originalValue // ignore: cast_nullable_to_non_nullable
                  as double,
        budgetValue: null == budgetValue
            ? _value.budgetValue
            : budgetValue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlannerCategoryImpl implements _PlannerCategory {
  const _$PlannerCategoryImpl({
    required this.id,
    required this.name,
    required this.icon,
    required this.accountId,
    required this.originalValue,
    required this.budgetValue,
  });

  factory _$PlannerCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlannerCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  final String accountId;
  @override
  final double originalValue;
  @override
  final double budgetValue;

  @override
  String toString() {
    return 'PlannerCategory(id: $id, name: $name, icon: $icon, accountId: $accountId, originalValue: $originalValue, budgetValue: $budgetValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlannerCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.originalValue, originalValue) ||
                other.originalValue == originalValue) &&
            (identical(other.budgetValue, budgetValue) ||
                other.budgetValue == budgetValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    icon,
    accountId,
    originalValue,
    budgetValue,
  );

  /// Create a copy of PlannerCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlannerCategoryImplCopyWith<_$PlannerCategoryImpl> get copyWith =>
      __$$PlannerCategoryImplCopyWithImpl<_$PlannerCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlannerCategoryImplToJson(this);
  }
}

abstract class _PlannerCategory implements PlannerCategory {
  const factory _PlannerCategory({
    required final String id,
    required final String name,
    required final String icon,
    required final String accountId,
    required final double originalValue,
    required final double budgetValue,
  }) = _$PlannerCategoryImpl;

  factory _PlannerCategory.fromJson(Map<String, dynamic> json) =
      _$PlannerCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  String get accountId;
  @override
  double get originalValue;
  @override
  double get budgetValue;

  /// Create a copy of PlannerCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlannerCategoryImplCopyWith<_$PlannerCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
