// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_budget_access.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SharedBudgetAccess _$SharedBudgetAccessFromJson(Map<String, dynamic> json) {
  return _SharedBudgetAccess.fromJson(json);
}

/// @nodoc
mixin _$SharedBudgetAccess {
  String get ownerId => throw _privateConstructorUsedError;
  String get ownerEmail => throw _privateConstructorUsedError;
  String get monthKey => throw _privateConstructorUsedError;
  bool get canWrite => throw _privateConstructorUsedError;

  /// Serializes this SharedBudgetAccess to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharedBudgetAccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedBudgetAccessCopyWith<SharedBudgetAccess> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedBudgetAccessCopyWith<$Res> {
  factory $SharedBudgetAccessCopyWith(
    SharedBudgetAccess value,
    $Res Function(SharedBudgetAccess) then,
  ) = _$SharedBudgetAccessCopyWithImpl<$Res, SharedBudgetAccess>;
  @useResult
  $Res call({
    String ownerId,
    String ownerEmail,
    String monthKey,
    bool canWrite,
  });
}

/// @nodoc
class _$SharedBudgetAccessCopyWithImpl<$Res, $Val extends SharedBudgetAccess>
    implements $SharedBudgetAccessCopyWith<$Res> {
  _$SharedBudgetAccessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedBudgetAccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ownerId = null,
    Object? ownerEmail = null,
    Object? monthKey = null,
    Object? canWrite = null,
  }) {
    return _then(
      _value.copyWith(
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerEmail: null == ownerEmail
                ? _value.ownerEmail
                : ownerEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            monthKey: null == monthKey
                ? _value.monthKey
                : monthKey // ignore: cast_nullable_to_non_nullable
                      as String,
            canWrite: null == canWrite
                ? _value.canWrite
                : canWrite // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SharedBudgetAccessImplCopyWith<$Res>
    implements $SharedBudgetAccessCopyWith<$Res> {
  factory _$$SharedBudgetAccessImplCopyWith(
    _$SharedBudgetAccessImpl value,
    $Res Function(_$SharedBudgetAccessImpl) then,
  ) = __$$SharedBudgetAccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ownerId,
    String ownerEmail,
    String monthKey,
    bool canWrite,
  });
}

/// @nodoc
class __$$SharedBudgetAccessImplCopyWithImpl<$Res>
    extends _$SharedBudgetAccessCopyWithImpl<$Res, _$SharedBudgetAccessImpl>
    implements _$$SharedBudgetAccessImplCopyWith<$Res> {
  __$$SharedBudgetAccessImplCopyWithImpl(
    _$SharedBudgetAccessImpl _value,
    $Res Function(_$SharedBudgetAccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SharedBudgetAccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ownerId = null,
    Object? ownerEmail = null,
    Object? monthKey = null,
    Object? canWrite = null,
  }) {
    return _then(
      _$SharedBudgetAccessImpl(
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerEmail: null == ownerEmail
            ? _value.ownerEmail
            : ownerEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        monthKey: null == monthKey
            ? _value.monthKey
            : monthKey // ignore: cast_nullable_to_non_nullable
                  as String,
        canWrite: null == canWrite
            ? _value.canWrite
            : canWrite // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedBudgetAccessImpl implements _SharedBudgetAccess {
  const _$SharedBudgetAccessImpl({
    required this.ownerId,
    required this.ownerEmail,
    required this.monthKey,
    this.canWrite = false,
  });

  factory _$SharedBudgetAccessImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedBudgetAccessImplFromJson(json);

  @override
  final String ownerId;
  @override
  final String ownerEmail;
  @override
  final String monthKey;
  @override
  @JsonKey()
  final bool canWrite;

  @override
  String toString() {
    return 'SharedBudgetAccess(ownerId: $ownerId, ownerEmail: $ownerEmail, monthKey: $monthKey, canWrite: $canWrite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedBudgetAccessImpl &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.ownerEmail, ownerEmail) ||
                other.ownerEmail == ownerEmail) &&
            (identical(other.monthKey, monthKey) ||
                other.monthKey == monthKey) &&
            (identical(other.canWrite, canWrite) ||
                other.canWrite == canWrite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, ownerId, ownerEmail, monthKey, canWrite);

  /// Create a copy of SharedBudgetAccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedBudgetAccessImplCopyWith<_$SharedBudgetAccessImpl> get copyWith =>
      __$$SharedBudgetAccessImplCopyWithImpl<_$SharedBudgetAccessImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedBudgetAccessImplToJson(this);
  }
}

abstract class _SharedBudgetAccess implements SharedBudgetAccess {
  const factory _SharedBudgetAccess({
    required final String ownerId,
    required final String ownerEmail,
    required final String monthKey,
    final bool canWrite,
  }) = _$SharedBudgetAccessImpl;

  factory _SharedBudgetAccess.fromJson(Map<String, dynamic> json) =
      _$SharedBudgetAccessImpl.fromJson;

  @override
  String get ownerId;
  @override
  String get ownerEmail;
  @override
  String get monthKey;
  @override
  bool get canWrite;

  /// Create a copy of SharedBudgetAccess
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedBudgetAccessImplCopyWith<_$SharedBudgetAccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
