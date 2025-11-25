// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShareInvitation _$ShareInvitationFromJson(Map<String, dynamic> json) {
  return _ShareInvitation.fromJson(json);
}

/// @nodoc
mixin _$ShareInvitation {
  String get id => throw _privateConstructorUsedError;
  String get fromUserId => throw _privateConstructorUsedError;
  String get fromUserEmail => throw _privateConstructorUsedError;
  String get toUserEmail => throw _privateConstructorUsedError;
  String get budgetMonthKey => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, accepted, rejected
  bool get canWrite => throw _privateConstructorUsedError;

  /// Serializes this ShareInvitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareInvitationCopyWith<ShareInvitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareInvitationCopyWith<$Res> {
  factory $ShareInvitationCopyWith(
    ShareInvitation value,
    $Res Function(ShareInvitation) then,
  ) = _$ShareInvitationCopyWithImpl<$Res, ShareInvitation>;
  @useResult
  $Res call({
    String id,
    String fromUserId,
    String fromUserEmail,
    String toUserEmail,
    String budgetMonthKey,
    DateTime createdAt,
    String status,
    bool canWrite,
  });
}

/// @nodoc
class _$ShareInvitationCopyWithImpl<$Res, $Val extends ShareInvitation>
    implements $ShareInvitationCopyWith<$Res> {
  _$ShareInvitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? fromUserEmail = null,
    Object? toUserEmail = null,
    Object? budgetMonthKey = null,
    Object? createdAt = null,
    Object? status = null,
    Object? canWrite = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fromUserId: null == fromUserId
                ? _value.fromUserId
                : fromUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            fromUserEmail: null == fromUserEmail
                ? _value.fromUserEmail
                : fromUserEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            toUserEmail: null == toUserEmail
                ? _value.toUserEmail
                : toUserEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            budgetMonthKey: null == budgetMonthKey
                ? _value.budgetMonthKey
                : budgetMonthKey // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ShareInvitationImplCopyWith<$Res>
    implements $ShareInvitationCopyWith<$Res> {
  factory _$$ShareInvitationImplCopyWith(
    _$ShareInvitationImpl value,
    $Res Function(_$ShareInvitationImpl) then,
  ) = __$$ShareInvitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fromUserId,
    String fromUserEmail,
    String toUserEmail,
    String budgetMonthKey,
    DateTime createdAt,
    String status,
    bool canWrite,
  });
}

/// @nodoc
class __$$ShareInvitationImplCopyWithImpl<$Res>
    extends _$ShareInvitationCopyWithImpl<$Res, _$ShareInvitationImpl>
    implements _$$ShareInvitationImplCopyWith<$Res> {
  __$$ShareInvitationImplCopyWithImpl(
    _$ShareInvitationImpl _value,
    $Res Function(_$ShareInvitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShareInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? fromUserEmail = null,
    Object? toUserEmail = null,
    Object? budgetMonthKey = null,
    Object? createdAt = null,
    Object? status = null,
    Object? canWrite = null,
  }) {
    return _then(
      _$ShareInvitationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fromUserId: null == fromUserId
            ? _value.fromUserId
            : fromUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        fromUserEmail: null == fromUserEmail
            ? _value.fromUserEmail
            : fromUserEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        toUserEmail: null == toUserEmail
            ? _value.toUserEmail
            : toUserEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        budgetMonthKey: null == budgetMonthKey
            ? _value.budgetMonthKey
            : budgetMonthKey // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
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
class _$ShareInvitationImpl implements _ShareInvitation {
  const _$ShareInvitationImpl({
    required this.id,
    required this.fromUserId,
    required this.fromUserEmail,
    required this.toUserEmail,
    required this.budgetMonthKey,
    required this.createdAt,
    this.status = 'pending',
    this.canWrite = false,
  });

  factory _$ShareInvitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareInvitationImplFromJson(json);

  @override
  final String id;
  @override
  final String fromUserId;
  @override
  final String fromUserEmail;
  @override
  final String toUserEmail;
  @override
  final String budgetMonthKey;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String status;
  // pending, accepted, rejected
  @override
  @JsonKey()
  final bool canWrite;

  @override
  String toString() {
    return 'ShareInvitation(id: $id, fromUserId: $fromUserId, fromUserEmail: $fromUserEmail, toUserEmail: $toUserEmail, budgetMonthKey: $budgetMonthKey, createdAt: $createdAt, status: $status, canWrite: $canWrite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareInvitationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.fromUserEmail, fromUserEmail) ||
                other.fromUserEmail == fromUserEmail) &&
            (identical(other.toUserEmail, toUserEmail) ||
                other.toUserEmail == toUserEmail) &&
            (identical(other.budgetMonthKey, budgetMonthKey) ||
                other.budgetMonthKey == budgetMonthKey) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.canWrite, canWrite) ||
                other.canWrite == canWrite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fromUserId,
    fromUserEmail,
    toUserEmail,
    budgetMonthKey,
    createdAt,
    status,
    canWrite,
  );

  /// Create a copy of ShareInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareInvitationImplCopyWith<_$ShareInvitationImpl> get copyWith =>
      __$$ShareInvitationImplCopyWithImpl<_$ShareInvitationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareInvitationImplToJson(this);
  }
}

abstract class _ShareInvitation implements ShareInvitation {
  const factory _ShareInvitation({
    required final String id,
    required final String fromUserId,
    required final String fromUserEmail,
    required final String toUserEmail,
    required final String budgetMonthKey,
    required final DateTime createdAt,
    final String status,
    final bool canWrite,
  }) = _$ShareInvitationImpl;

  factory _ShareInvitation.fromJson(Map<String, dynamic> json) =
      _$ShareInvitationImpl.fromJson;

  @override
  String get id;
  @override
  String get fromUserId;
  @override
  String get fromUserEmail;
  @override
  String get toUserEmail;
  @override
  String get budgetMonthKey;
  @override
  DateTime get createdAt;
  @override
  String get status; // pending, accepted, rejected
  @override
  bool get canWrite;

  /// Create a copy of ShareInvitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareInvitationImplCopyWith<_$ShareInvitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
