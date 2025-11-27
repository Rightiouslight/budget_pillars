// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BudgetNotification _$BudgetNotificationFromJson(Map<String, dynamic> json) {
  return _BudgetNotification.fromJson(json);
}

/// @nodoc
mixin _$BudgetNotification {
  String get id => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get relatedTransactionId => throw _privateConstructorUsedError;

  /// Serializes this BudgetNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BudgetNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetNotificationCopyWith<BudgetNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetNotificationCopyWith<$Res> {
  factory $BudgetNotificationCopyWith(
    BudgetNotification value,
    $Res Function(BudgetNotification) then,
  ) = _$BudgetNotificationCopyWithImpl<$Res, BudgetNotification>;
  @useResult
  $Res call({
    String id,
    NotificationType type,
    String title,
    String message,
    DateTime timestamp,
    bool isRead,
    String? relatedTransactionId,
  });
}

/// @nodoc
class _$BudgetNotificationCopyWithImpl<$Res, $Val extends BudgetNotification>
    implements $BudgetNotificationCopyWith<$Res> {
  _$BudgetNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BudgetNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? timestamp = null,
    Object? isRead = null,
    Object? relatedTransactionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            relatedTransactionId: freezed == relatedTransactionId
                ? _value.relatedTransactionId
                : relatedTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BudgetNotificationImplCopyWith<$Res>
    implements $BudgetNotificationCopyWith<$Res> {
  factory _$$BudgetNotificationImplCopyWith(
    _$BudgetNotificationImpl value,
    $Res Function(_$BudgetNotificationImpl) then,
  ) = __$$BudgetNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    NotificationType type,
    String title,
    String message,
    DateTime timestamp,
    bool isRead,
    String? relatedTransactionId,
  });
}

/// @nodoc
class __$$BudgetNotificationImplCopyWithImpl<$Res>
    extends _$BudgetNotificationCopyWithImpl<$Res, _$BudgetNotificationImpl>
    implements _$$BudgetNotificationImplCopyWith<$Res> {
  __$$BudgetNotificationImplCopyWithImpl(
    _$BudgetNotificationImpl _value,
    $Res Function(_$BudgetNotificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BudgetNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? timestamp = null,
    Object? isRead = null,
    Object? relatedTransactionId = freezed,
  }) {
    return _then(
      _$BudgetNotificationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        relatedTransactionId: freezed == relatedTransactionId
            ? _value.relatedTransactionId
            : relatedTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BudgetNotificationImpl implements _BudgetNotification {
  const _$BudgetNotificationImpl({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedTransactionId,
  });

  factory _$BudgetNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetNotificationImplFromJson(json);

  @override
  final String id;
  @override
  final NotificationType type;
  @override
  final String title;
  @override
  final String message;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? relatedTransactionId;

  @override
  String toString() {
    return 'BudgetNotification(id: $id, type: $type, title: $title, message: $message, timestamp: $timestamp, isRead: $isRead, relatedTransactionId: $relatedTransactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.relatedTransactionId, relatedTransactionId) ||
                other.relatedTransactionId == relatedTransactionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    title,
    message,
    timestamp,
    isRead,
    relatedTransactionId,
  );

  /// Create a copy of BudgetNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetNotificationImplCopyWith<_$BudgetNotificationImpl> get copyWith =>
      __$$BudgetNotificationImplCopyWithImpl<_$BudgetNotificationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetNotificationImplToJson(this);
  }
}

abstract class _BudgetNotification implements BudgetNotification {
  const factory _BudgetNotification({
    required final String id,
    required final NotificationType type,
    required final String title,
    required final String message,
    required final DateTime timestamp,
    final bool isRead,
    final String? relatedTransactionId,
  }) = _$BudgetNotificationImpl;

  factory _BudgetNotification.fromJson(Map<String, dynamic> json) =
      _$BudgetNotificationImpl.fromJson;

  @override
  String get id;
  @override
  NotificationType get type;
  @override
  String get title;
  @override
  String get message;
  @override
  DateTime get timestamp;
  @override
  bool get isRead;
  @override
  String? get relatedTransactionId;

  /// Create a copy of BudgetNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetNotificationImplCopyWith<_$BudgetNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
