// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  String get accountName => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String? get targetAccountId => throw _privateConstructorUsedError;
  String? get targetPocketId => throw _privateConstructorUsedError;
  String? get targetPocketName => throw _privateConstructorUsedError;
  String? get sourcePocketId => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
    Transaction value,
    $Res Function(Transaction) then,
  ) = _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call({
    String id,
    double amount,
    String description,
    @TimestampConverter() DateTime date,
    String accountId,
    String accountName,
    String categoryId,
    String categoryName,
    String? targetAccountId,
    String? targetPocketId,
    String? targetPocketName,
    String? sourcePocketId,
  });
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? description = null,
    Object? date = null,
    Object? accountId = null,
    Object? accountName = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? targetAccountId = freezed,
    Object? targetPocketId = freezed,
    Object? targetPocketName = freezed,
    Object? sourcePocketId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String,
            accountName: null == accountName
                ? _value.accountName
                : accountName // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            targetAccountId: freezed == targetAccountId
                ? _value.targetAccountId
                : targetAccountId // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetPocketId: freezed == targetPocketId
                ? _value.targetPocketId
                : targetPocketId // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetPocketName: freezed == targetPocketName
                ? _value.targetPocketName
                : targetPocketName // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourcePocketId: freezed == sourcePocketId
                ? _value.sourcePocketId
                : sourcePocketId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
    _$TransactionImpl value,
    $Res Function(_$TransactionImpl) then,
  ) = __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double amount,
    String description,
    @TimestampConverter() DateTime date,
    String accountId,
    String accountName,
    String categoryId,
    String categoryName,
    String? targetAccountId,
    String? targetPocketId,
    String? targetPocketName,
    String? sourcePocketId,
  });
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
    _$TransactionImpl _value,
    $Res Function(_$TransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? description = null,
    Object? date = null,
    Object? accountId = null,
    Object? accountName = null,
    Object? categoryId = null,
    Object? categoryName = null,
    Object? targetAccountId = freezed,
    Object? targetPocketId = freezed,
    Object? targetPocketName = freezed,
    Object? sourcePocketId = freezed,
  }) {
    return _then(
      _$TransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String,
        accountName: null == accountName
            ? _value.accountName
            : accountName // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        targetAccountId: freezed == targetAccountId
            ? _value.targetAccountId
            : targetAccountId // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetPocketId: freezed == targetPocketId
            ? _value.targetPocketId
            : targetPocketId // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetPocketName: freezed == targetPocketName
            ? _value.targetPocketName
            : targetPocketName // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourcePocketId: freezed == sourcePocketId
            ? _value.sourcePocketId
            : sourcePocketId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl({
    required this.id,
    required this.amount,
    required this.description,
    @TimestampConverter() required this.date,
    required this.accountId,
    required this.accountName,
    required this.categoryId,
    required this.categoryName,
    this.targetAccountId,
    this.targetPocketId,
    this.targetPocketName,
    this.sourcePocketId,
  });

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final double amount;
  @override
  final String description;
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final String accountId;
  @override
  final String accountName;
  @override
  final String categoryId;
  @override
  final String categoryName;
  @override
  final String? targetAccountId;
  @override
  final String? targetPocketId;
  @override
  final String? targetPocketName;
  @override
  final String? sourcePocketId;

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, description: $description, date: $date, accountId: $accountId, accountName: $accountName, categoryId: $categoryId, categoryName: $categoryName, targetAccountId: $targetAccountId, targetPocketId: $targetPocketId, targetPocketName: $targetPocketName, sourcePocketId: $sourcePocketId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.targetAccountId, targetAccountId) ||
                other.targetAccountId == targetAccountId) &&
            (identical(other.targetPocketId, targetPocketId) ||
                other.targetPocketId == targetPocketId) &&
            (identical(other.targetPocketName, targetPocketName) ||
                other.targetPocketName == targetPocketName) &&
            (identical(other.sourcePocketId, sourcePocketId) ||
                other.sourcePocketId == sourcePocketId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    amount,
    description,
    date,
    accountId,
    accountName,
    categoryId,
    categoryName,
    targetAccountId,
    targetPocketId,
    targetPocketName,
    sourcePocketId,
  );

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(this);
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction({
    required final String id,
    required final double amount,
    required final String description,
    @TimestampConverter() required final DateTime date,
    required final String accountId,
    required final String accountName,
    required final String categoryId,
    required final String categoryName,
    final String? targetAccountId,
    final String? targetPocketId,
    final String? targetPocketName,
    final String? sourcePocketId,
  }) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  double get amount;
  @override
  String get description;
  @override
  @TimestampConverter()
  DateTime get date;
  @override
  String get accountId;
  @override
  String get accountName;
  @override
  String get categoryId;
  @override
  String get categoryName;
  @override
  String? get targetAccountId;
  @override
  String? get targetPocketId;
  @override
  String? get targetPocketName;
  @override
  String? get sourcePocketId;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
