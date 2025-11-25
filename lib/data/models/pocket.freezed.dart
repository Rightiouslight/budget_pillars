// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pocket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Pocket _$PocketFromJson(Map<String, dynamic> json) {
  return _Pocket.fromJson(json);
}

/// @nodoc
mixin _$Pocket {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;

  /// Serializes this Pocket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pocket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PocketCopyWith<Pocket> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PocketCopyWith<$Res> {
  factory $PocketCopyWith(Pocket value, $Res Function(Pocket) then) =
      _$PocketCopyWithImpl<$Res, Pocket>;
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    double balance,
    String? color,
  });
}

/// @nodoc
class _$PocketCopyWithImpl<$Res, $Val extends Pocket>
    implements $PocketCopyWith<$Res> {
  _$PocketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pocket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? balance = null,
    Object? color = freezed,
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
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as double,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PocketImplCopyWith<$Res> implements $PocketCopyWith<$Res> {
  factory _$$PocketImplCopyWith(
    _$PocketImpl value,
    $Res Function(_$PocketImpl) then,
  ) = __$$PocketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String icon,
    double balance,
    String? color,
  });
}

/// @nodoc
class __$$PocketImplCopyWithImpl<$Res>
    extends _$PocketCopyWithImpl<$Res, _$PocketImpl>
    implements _$$PocketImplCopyWith<$Res> {
  __$$PocketImplCopyWithImpl(
    _$PocketImpl _value,
    $Res Function(_$PocketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Pocket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? balance = null,
    Object? color = freezed,
  }) {
    return _then(
      _$PocketImpl(
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
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as double,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PocketImpl implements _Pocket {
  const _$PocketImpl({
    required this.id,
    required this.name,
    required this.icon,
    required this.balance,
    this.color,
  });

  factory _$PocketImpl.fromJson(Map<String, dynamic> json) =>
      _$$PocketImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  final double balance;
  @override
  final String? color;

  @override
  String toString() {
    return 'Pocket(id: $id, name: $name, icon: $icon, balance: $balance, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PocketImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon, balance, color);

  /// Create a copy of Pocket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PocketImplCopyWith<_$PocketImpl> get copyWith =>
      __$$PocketImplCopyWithImpl<_$PocketImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PocketImplToJson(this);
  }
}

abstract class _Pocket implements Pocket {
  const factory _Pocket({
    required final String id,
    required final String name,
    required final String icon,
    required final double balance,
    final String? color,
  }) = _$PocketImpl;

  factory _Pocket.fromJson(Map<String, dynamic> json) = _$PocketImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  double get balance;
  @override
  String? get color;

  /// Create a copy of Pocket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PocketImplCopyWith<_$PocketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
