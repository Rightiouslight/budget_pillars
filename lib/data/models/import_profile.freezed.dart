// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ImportProfile _$ImportProfileFromJson(Map<String, dynamic> json) {
  return _ImportProfile.fromJson(json);
}

/// @nodoc
mixin _$ImportProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'csv', 'text', 'sms'
  Map<String, dynamic> get columnMapping =>
      throw _privateConstructorUsedError; // Maps CSV columns to transaction fields
  String? get regex =>
      throw _privateConstructorUsedError; // For text/SMS parsing
  Map<String, String> get categoryMappings =>
      throw _privateConstructorUsedError;

  /// Serializes this ImportProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImportProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImportProfileCopyWith<ImportProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportProfileCopyWith<$Res> {
  factory $ImportProfileCopyWith(
    ImportProfile value,
    $Res Function(ImportProfile) then,
  ) = _$ImportProfileCopyWithImpl<$Res, ImportProfile>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    Map<String, dynamic> columnMapping,
    String? regex,
    Map<String, String> categoryMappings,
  });
}

/// @nodoc
class _$ImportProfileCopyWithImpl<$Res, $Val extends ImportProfile>
    implements $ImportProfileCopyWith<$Res> {
  _$ImportProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImportProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? columnMapping = null,
    Object? regex = freezed,
    Object? categoryMappings = null,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            columnMapping: null == columnMapping
                ? _value.columnMapping
                : columnMapping // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            regex: freezed == regex
                ? _value.regex
                : regex // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryMappings: null == categoryMappings
                ? _value.categoryMappings
                : categoryMappings // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImportProfileImplCopyWith<$Res>
    implements $ImportProfileCopyWith<$Res> {
  factory _$$ImportProfileImplCopyWith(
    _$ImportProfileImpl value,
    $Res Function(_$ImportProfileImpl) then,
  ) = __$$ImportProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    Map<String, dynamic> columnMapping,
    String? regex,
    Map<String, String> categoryMappings,
  });
}

/// @nodoc
class __$$ImportProfileImplCopyWithImpl<$Res>
    extends _$ImportProfileCopyWithImpl<$Res, _$ImportProfileImpl>
    implements _$$ImportProfileImplCopyWith<$Res> {
  __$$ImportProfileImplCopyWithImpl(
    _$ImportProfileImpl _value,
    $Res Function(_$ImportProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImportProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? columnMapping = null,
    Object? regex = freezed,
    Object? categoryMappings = null,
  }) {
    return _then(
      _$ImportProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        columnMapping: null == columnMapping
            ? _value._columnMapping
            : columnMapping // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        regex: freezed == regex
            ? _value.regex
            : regex // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryMappings: null == categoryMappings
            ? _value._categoryMappings
            : categoryMappings // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImportProfileImpl implements _ImportProfile {
  const _$ImportProfileImpl({
    required this.id,
    required this.name,
    this.type = 'csv',
    final Map<String, dynamic> columnMapping = const {},
    this.regex,
    final Map<String, String> categoryMappings = const {},
  }) : _columnMapping = columnMapping,
       _categoryMappings = categoryMappings;

  factory _$ImportProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImportProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String type;
  // 'csv', 'text', 'sms'
  final Map<String, dynamic> _columnMapping;
  // 'csv', 'text', 'sms'
  @override
  @JsonKey()
  Map<String, dynamic> get columnMapping {
    if (_columnMapping is EqualUnmodifiableMapView) return _columnMapping;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_columnMapping);
  }

  // Maps CSV columns to transaction fields
  @override
  final String? regex;
  // For text/SMS parsing
  final Map<String, String> _categoryMappings;
  // For text/SMS parsing
  @override
  @JsonKey()
  Map<String, String> get categoryMappings {
    if (_categoryMappings is EqualUnmodifiableMapView) return _categoryMappings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryMappings);
  }

  @override
  String toString() {
    return 'ImportProfile(id: $id, name: $name, type: $type, columnMapping: $columnMapping, regex: $regex, categoryMappings: $categoryMappings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._columnMapping,
              _columnMapping,
            ) &&
            (identical(other.regex, regex) || other.regex == regex) &&
            const DeepCollectionEquality().equals(
              other._categoryMappings,
              _categoryMappings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    const DeepCollectionEquality().hash(_columnMapping),
    regex,
    const DeepCollectionEquality().hash(_categoryMappings),
  );

  /// Create a copy of ImportProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportProfileImplCopyWith<_$ImportProfileImpl> get copyWith =>
      __$$ImportProfileImplCopyWithImpl<_$ImportProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImportProfileImplToJson(this);
  }
}

abstract class _ImportProfile implements ImportProfile {
  const factory _ImportProfile({
    required final String id,
    required final String name,
    final String type,
    final Map<String, dynamic> columnMapping,
    final String? regex,
    final Map<String, String> categoryMappings,
  }) = _$ImportProfileImpl;

  factory _ImportProfile.fromJson(Map<String, dynamic> json) =
      _$ImportProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type; // 'csv', 'text', 'sms'
  @override
  Map<String, dynamic> get columnMapping; // Maps CSV columns to transaction fields
  @override
  String? get regex; // For text/SMS parsing
  @override
  Map<String, String> get categoryMappings;

  /// Create a copy of ImportProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportProfileImplCopyWith<_$ImportProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
