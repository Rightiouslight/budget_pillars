// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_income.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurringIncome _$RecurringIncomeFromJson(Map<String, dynamic> json) {
  return _RecurringIncome.fromJson(json);
}

/// @nodoc
mixin _$RecurringIncome {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description =>
      throw _privateConstructorUsedError; // Firestore uses 'description' instead of 'name'
  double get amount => throw _privateConstructorUsedError;
  String? get accountId => throw _privateConstructorUsedError;
  String? get pocketId => throw _privateConstructorUsedError;
  int get dayOfMonth => throw _privateConstructorUsedError;

  /// Serializes this RecurringIncome to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurringIncomeCopyWith<RecurringIncome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringIncomeCopyWith<$Res> {
  factory $RecurringIncomeCopyWith(
    RecurringIncome value,
    $Res Function(RecurringIncome) then,
  ) = _$RecurringIncomeCopyWithImpl<$Res, RecurringIncome>;
  @useResult
  $Res call({
    String id,
    String? name,
    String? description,
    double amount,
    String? accountId,
    String? pocketId,
    int dayOfMonth,
  });
}

/// @nodoc
class _$RecurringIncomeCopyWithImpl<$Res, $Val extends RecurringIncome>
    implements $RecurringIncomeCopyWith<$Res> {
  _$RecurringIncomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? amount = null,
    Object? accountId = freezed,
    Object? pocketId = freezed,
    Object? dayOfMonth = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            accountId: freezed == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String?,
            pocketId: freezed == pocketId
                ? _value.pocketId
                : pocketId // ignore: cast_nullable_to_non_nullable
                      as String?,
            dayOfMonth: null == dayOfMonth
                ? _value.dayOfMonth
                : dayOfMonth // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurringIncomeImplCopyWith<$Res>
    implements $RecurringIncomeCopyWith<$Res> {
  factory _$$RecurringIncomeImplCopyWith(
    _$RecurringIncomeImpl value,
    $Res Function(_$RecurringIncomeImpl) then,
  ) = __$$RecurringIncomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? name,
    String? description,
    double amount,
    String? accountId,
    String? pocketId,
    int dayOfMonth,
  });
}

/// @nodoc
class __$$RecurringIncomeImplCopyWithImpl<$Res>
    extends _$RecurringIncomeCopyWithImpl<$Res, _$RecurringIncomeImpl>
    implements _$$RecurringIncomeImplCopyWith<$Res> {
  __$$RecurringIncomeImplCopyWithImpl(
    _$RecurringIncomeImpl _value,
    $Res Function(_$RecurringIncomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? amount = null,
    Object? accountId = freezed,
    Object? pocketId = freezed,
    Object? dayOfMonth = null,
  }) {
    return _then(
      _$RecurringIncomeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        accountId: freezed == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String?,
        pocketId: freezed == pocketId
            ? _value.pocketId
            : pocketId // ignore: cast_nullable_to_non_nullable
                  as String?,
        dayOfMonth: null == dayOfMonth
            ? _value.dayOfMonth
            : dayOfMonth // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurringIncomeImpl implements _RecurringIncome {
  const _$RecurringIncomeImpl({
    required this.id,
    this.name,
    this.description,
    required this.amount,
    this.accountId,
    this.pocketId,
    required this.dayOfMonth,
  });

  factory _$RecurringIncomeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringIncomeImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? description;
  // Firestore uses 'description' instead of 'name'
  @override
  final double amount;
  @override
  final String? accountId;
  @override
  final String? pocketId;
  @override
  final int dayOfMonth;

  @override
  String toString() {
    return 'RecurringIncome(id: $id, name: $name, description: $description, amount: $amount, accountId: $accountId, pocketId: $pocketId, dayOfMonth: $dayOfMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringIncomeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.pocketId, pocketId) ||
                other.pocketId == pocketId) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    amount,
    accountId,
    pocketId,
    dayOfMonth,
  );

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringIncomeImplCopyWith<_$RecurringIncomeImpl> get copyWith =>
      __$$RecurringIncomeImplCopyWithImpl<_$RecurringIncomeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringIncomeImplToJson(this);
  }
}

abstract class _RecurringIncome implements RecurringIncome {
  const factory _RecurringIncome({
    required final String id,
    final String? name,
    final String? description,
    required final double amount,
    final String? accountId,
    final String? pocketId,
    required final int dayOfMonth,
  }) = _$RecurringIncomeImpl;

  factory _RecurringIncome.fromJson(Map<String, dynamic> json) =
      _$RecurringIncomeImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get description; // Firestore uses 'description' instead of 'name'
  @override
  double get amount;
  @override
  String? get accountId;
  @override
  String? get pocketId;
  @override
  int get dayOfMonth;

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurringIncomeImplCopyWith<_$RecurringIncomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
