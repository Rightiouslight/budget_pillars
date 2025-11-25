// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyBudget _$MonthlyBudgetFromJson(Map<String, dynamic> json) {
  return _MonthlyBudget.fromJson(json);
}

/// @nodoc
mixin _$MonthlyBudget {
  List<Account> get accounts => throw _privateConstructorUsedError;
  List<Transaction> get transactions => throw _privateConstructorUsedError;
  List<RecurringIncome> get recurringIncomes =>
      throw _privateConstructorUsedError;
  Map<String, bool> get autoTransactionsProcessed =>
      throw _privateConstructorUsedError;
  Map<String, bool> get processedRecurringIncomes =>
      throw _privateConstructorUsedError;

  /// Serializes this MonthlyBudget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyBudgetCopyWith<MonthlyBudget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyBudgetCopyWith<$Res> {
  factory $MonthlyBudgetCopyWith(
    MonthlyBudget value,
    $Res Function(MonthlyBudget) then,
  ) = _$MonthlyBudgetCopyWithImpl<$Res, MonthlyBudget>;
  @useResult
  $Res call({
    List<Account> accounts,
    List<Transaction> transactions,
    List<RecurringIncome> recurringIncomes,
    Map<String, bool> autoTransactionsProcessed,
    Map<String, bool> processedRecurringIncomes,
  });
}

/// @nodoc
class _$MonthlyBudgetCopyWithImpl<$Res, $Val extends MonthlyBudget>
    implements $MonthlyBudgetCopyWith<$Res> {
  _$MonthlyBudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accounts = null,
    Object? transactions = null,
    Object? recurringIncomes = null,
    Object? autoTransactionsProcessed = null,
    Object? processedRecurringIncomes = null,
  }) {
    return _then(
      _value.copyWith(
            accounts: null == accounts
                ? _value.accounts
                : accounts // ignore: cast_nullable_to_non_nullable
                      as List<Account>,
            transactions: null == transactions
                ? _value.transactions
                : transactions // ignore: cast_nullable_to_non_nullable
                      as List<Transaction>,
            recurringIncomes: null == recurringIncomes
                ? _value.recurringIncomes
                : recurringIncomes // ignore: cast_nullable_to_non_nullable
                      as List<RecurringIncome>,
            autoTransactionsProcessed: null == autoTransactionsProcessed
                ? _value.autoTransactionsProcessed
                : autoTransactionsProcessed // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
            processedRecurringIncomes: null == processedRecurringIncomes
                ? _value.processedRecurringIncomes
                : processedRecurringIncomes // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyBudgetImplCopyWith<$Res>
    implements $MonthlyBudgetCopyWith<$Res> {
  factory _$$MonthlyBudgetImplCopyWith(
    _$MonthlyBudgetImpl value,
    $Res Function(_$MonthlyBudgetImpl) then,
  ) = __$$MonthlyBudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Account> accounts,
    List<Transaction> transactions,
    List<RecurringIncome> recurringIncomes,
    Map<String, bool> autoTransactionsProcessed,
    Map<String, bool> processedRecurringIncomes,
  });
}

/// @nodoc
class __$$MonthlyBudgetImplCopyWithImpl<$Res>
    extends _$MonthlyBudgetCopyWithImpl<$Res, _$MonthlyBudgetImpl>
    implements _$$MonthlyBudgetImplCopyWith<$Res> {
  __$$MonthlyBudgetImplCopyWithImpl(
    _$MonthlyBudgetImpl _value,
    $Res Function(_$MonthlyBudgetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accounts = null,
    Object? transactions = null,
    Object? recurringIncomes = null,
    Object? autoTransactionsProcessed = null,
    Object? processedRecurringIncomes = null,
  }) {
    return _then(
      _$MonthlyBudgetImpl(
        accounts: null == accounts
            ? _value._accounts
            : accounts // ignore: cast_nullable_to_non_nullable
                  as List<Account>,
        transactions: null == transactions
            ? _value._transactions
            : transactions // ignore: cast_nullable_to_non_nullable
                  as List<Transaction>,
        recurringIncomes: null == recurringIncomes
            ? _value._recurringIncomes
            : recurringIncomes // ignore: cast_nullable_to_non_nullable
                  as List<RecurringIncome>,
        autoTransactionsProcessed: null == autoTransactionsProcessed
            ? _value._autoTransactionsProcessed
            : autoTransactionsProcessed // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
        processedRecurringIncomes: null == processedRecurringIncomes
            ? _value._processedRecurringIncomes
            : processedRecurringIncomes // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyBudgetImpl implements _MonthlyBudget {
  const _$MonthlyBudgetImpl({
    required final List<Account> accounts,
    required final List<Transaction> transactions,
    final List<RecurringIncome> recurringIncomes = const [],
    final Map<String, bool> autoTransactionsProcessed = const {},
    final Map<String, bool> processedRecurringIncomes = const {},
  }) : _accounts = accounts,
       _transactions = transactions,
       _recurringIncomes = recurringIncomes,
       _autoTransactionsProcessed = autoTransactionsProcessed,
       _processedRecurringIncomes = processedRecurringIncomes;

  factory _$MonthlyBudgetImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyBudgetImplFromJson(json);

  final List<Account> _accounts;
  @override
  List<Account> get accounts {
    if (_accounts is EqualUnmodifiableListView) return _accounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accounts);
  }

  final List<Transaction> _transactions;
  @override
  List<Transaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  final List<RecurringIncome> _recurringIncomes;
  @override
  @JsonKey()
  List<RecurringIncome> get recurringIncomes {
    if (_recurringIncomes is EqualUnmodifiableListView)
      return _recurringIncomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recurringIncomes);
  }

  final Map<String, bool> _autoTransactionsProcessed;
  @override
  @JsonKey()
  Map<String, bool> get autoTransactionsProcessed {
    if (_autoTransactionsProcessed is EqualUnmodifiableMapView)
      return _autoTransactionsProcessed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_autoTransactionsProcessed);
  }

  final Map<String, bool> _processedRecurringIncomes;
  @override
  @JsonKey()
  Map<String, bool> get processedRecurringIncomes {
    if (_processedRecurringIncomes is EqualUnmodifiableMapView)
      return _processedRecurringIncomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_processedRecurringIncomes);
  }

  @override
  String toString() {
    return 'MonthlyBudget(accounts: $accounts, transactions: $transactions, recurringIncomes: $recurringIncomes, autoTransactionsProcessed: $autoTransactionsProcessed, processedRecurringIncomes: $processedRecurringIncomes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyBudgetImpl &&
            const DeepCollectionEquality().equals(other._accounts, _accounts) &&
            const DeepCollectionEquality().equals(
              other._transactions,
              _transactions,
            ) &&
            const DeepCollectionEquality().equals(
              other._recurringIncomes,
              _recurringIncomes,
            ) &&
            const DeepCollectionEquality().equals(
              other._autoTransactionsProcessed,
              _autoTransactionsProcessed,
            ) &&
            const DeepCollectionEquality().equals(
              other._processedRecurringIncomes,
              _processedRecurringIncomes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_accounts),
    const DeepCollectionEquality().hash(_transactions),
    const DeepCollectionEquality().hash(_recurringIncomes),
    const DeepCollectionEquality().hash(_autoTransactionsProcessed),
    const DeepCollectionEquality().hash(_processedRecurringIncomes),
  );

  /// Create a copy of MonthlyBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyBudgetImplCopyWith<_$MonthlyBudgetImpl> get copyWith =>
      __$$MonthlyBudgetImplCopyWithImpl<_$MonthlyBudgetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyBudgetImplToJson(this);
  }
}

abstract class _MonthlyBudget implements MonthlyBudget {
  const factory _MonthlyBudget({
    required final List<Account> accounts,
    required final List<Transaction> transactions,
    final List<RecurringIncome> recurringIncomes,
    final Map<String, bool> autoTransactionsProcessed,
    final Map<String, bool> processedRecurringIncomes,
  }) = _$MonthlyBudgetImpl;

  factory _MonthlyBudget.fromJson(Map<String, dynamic> json) =
      _$MonthlyBudgetImpl.fromJson;

  @override
  List<Account> get accounts;
  @override
  List<Transaction> get transactions;
  @override
  List<RecurringIncome> get recurringIncomes;
  @override
  Map<String, bool> get autoTransactionsProcessed;
  @override
  Map<String, bool> get processedRecurringIncomes;

  /// Create a copy of MonthlyBudget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyBudgetImplCopyWith<_$MonthlyBudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
