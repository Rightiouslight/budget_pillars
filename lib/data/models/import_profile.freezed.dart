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

ColumnMapping _$ColumnMappingFromJson(Map<String, dynamic> json) {
  return _ColumnMapping.fromJson(json);
}

/// @nodoc
mixin _$ColumnMapping {
  String? get date => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get amount => throw _privateConstructorUsedError;

  /// Serializes this ColumnMapping to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ColumnMapping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColumnMappingCopyWith<ColumnMapping> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColumnMappingCopyWith<$Res> {
  factory $ColumnMappingCopyWith(
    ColumnMapping value,
    $Res Function(ColumnMapping) then,
  ) = _$ColumnMappingCopyWithImpl<$Res, ColumnMapping>;
  @useResult
  $Res call({String? date, String? description, String? amount});
}

/// @nodoc
class _$ColumnMappingCopyWithImpl<$Res, $Val extends ColumnMapping>
    implements $ColumnMappingCopyWith<$Res> {
  _$ColumnMappingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColumnMapping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? description = freezed,
    Object? amount = freezed,
  }) {
    return _then(
      _value.copyWith(
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            amount: freezed == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ColumnMappingImplCopyWith<$Res>
    implements $ColumnMappingCopyWith<$Res> {
  factory _$$ColumnMappingImplCopyWith(
    _$ColumnMappingImpl value,
    $Res Function(_$ColumnMappingImpl) then,
  ) = __$$ColumnMappingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? date, String? description, String? amount});
}

/// @nodoc
class __$$ColumnMappingImplCopyWithImpl<$Res>
    extends _$ColumnMappingCopyWithImpl<$Res, _$ColumnMappingImpl>
    implements _$$ColumnMappingImplCopyWith<$Res> {
  __$$ColumnMappingImplCopyWithImpl(
    _$ColumnMappingImpl _value,
    $Res Function(_$ColumnMappingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ColumnMapping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? description = freezed,
    Object? amount = freezed,
  }) {
    return _then(
      _$ColumnMappingImpl(
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        amount: freezed == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ColumnMappingImpl implements _ColumnMapping {
  const _$ColumnMappingImpl({this.date, this.description, this.amount});

  factory _$ColumnMappingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColumnMappingImplFromJson(json);

  @override
  final String? date;
  @override
  final String? description;
  @override
  final String? amount;

  @override
  String toString() {
    return 'ColumnMapping(date: $date, description: $description, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColumnMappingImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, description, amount);

  /// Create a copy of ColumnMapping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColumnMappingImplCopyWith<_$ColumnMappingImpl> get copyWith =>
      __$$ColumnMappingImplCopyWithImpl<_$ColumnMappingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColumnMappingImplToJson(this);
  }
}

abstract class _ColumnMapping implements ColumnMapping {
  const factory _ColumnMapping({
    final String? date,
    final String? description,
    final String? amount,
  }) = _$ColumnMappingImpl;

  factory _ColumnMapping.fromJson(Map<String, dynamic> json) =
      _$ColumnMappingImpl.fromJson;

  @override
  String? get date;
  @override
  String? get description;
  @override
  String? get amount;

  /// Create a copy of ColumnMapping
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColumnMappingImplCopyWith<_$ColumnMappingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImportProfile _$ImportProfileFromJson(Map<String, dynamic> json) {
  return _ImportProfile.fromJson(json);
}

/// @nodoc
mixin _$ImportProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get hasHeader => throw _privateConstructorUsedError;
  String get dateFormat => throw _privateConstructorUsedError;
  ColumnMapping get columnMapping => throw _privateConstructorUsedError;
  int? get columnCount => throw _privateConstructorUsedError;
  String get smsStartWords => throw _privateConstructorUsedError;
  String get smsStopWords => throw _privateConstructorUsedError;

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
    bool hasHeader,
    String dateFormat,
    ColumnMapping columnMapping,
    int? columnCount,
    String smsStartWords,
    String smsStopWords,
  });

  $ColumnMappingCopyWith<$Res> get columnMapping;
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
    Object? hasHeader = null,
    Object? dateFormat = null,
    Object? columnMapping = null,
    Object? columnCount = freezed,
    Object? smsStartWords = null,
    Object? smsStopWords = null,
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
            hasHeader: null == hasHeader
                ? _value.hasHeader
                : hasHeader // ignore: cast_nullable_to_non_nullable
                      as bool,
            dateFormat: null == dateFormat
                ? _value.dateFormat
                : dateFormat // ignore: cast_nullable_to_non_nullable
                      as String,
            columnMapping: null == columnMapping
                ? _value.columnMapping
                : columnMapping // ignore: cast_nullable_to_non_nullable
                      as ColumnMapping,
            columnCount: freezed == columnCount
                ? _value.columnCount
                : columnCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            smsStartWords: null == smsStartWords
                ? _value.smsStartWords
                : smsStartWords // ignore: cast_nullable_to_non_nullable
                      as String,
            smsStopWords: null == smsStopWords
                ? _value.smsStopWords
                : smsStopWords // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ImportProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ColumnMappingCopyWith<$Res> get columnMapping {
    return $ColumnMappingCopyWith<$Res>(_value.columnMapping, (value) {
      return _then(_value.copyWith(columnMapping: value) as $Val);
    });
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
    bool hasHeader,
    String dateFormat,
    ColumnMapping columnMapping,
    int? columnCount,
    String smsStartWords,
    String smsStopWords,
  });

  @override
  $ColumnMappingCopyWith<$Res> get columnMapping;
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
    Object? hasHeader = null,
    Object? dateFormat = null,
    Object? columnMapping = null,
    Object? columnCount = freezed,
    Object? smsStartWords = null,
    Object? smsStopWords = null,
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
        hasHeader: null == hasHeader
            ? _value.hasHeader
            : hasHeader // ignore: cast_nullable_to_non_nullable
                  as bool,
        dateFormat: null == dateFormat
            ? _value.dateFormat
            : dateFormat // ignore: cast_nullable_to_non_nullable
                  as String,
        columnMapping: null == columnMapping
            ? _value.columnMapping
            : columnMapping // ignore: cast_nullable_to_non_nullable
                  as ColumnMapping,
        columnCount: freezed == columnCount
            ? _value.columnCount
            : columnCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        smsStartWords: null == smsStartWords
            ? _value.smsStartWords
            : smsStartWords // ignore: cast_nullable_to_non_nullable
                  as String,
        smsStopWords: null == smsStopWords
            ? _value.smsStopWords
            : smsStopWords // ignore: cast_nullable_to_non_nullable
                  as String,
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
    this.hasHeader = true,
    this.dateFormat = 'M/d/yyyy',
    this.columnMapping = const ColumnMapping(),
    this.columnCount,
    this.smsStartWords = '',
    this.smsStopWords = '',
  });

  factory _$ImportProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImportProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final bool hasHeader;
  @override
  @JsonKey()
  final String dateFormat;
  @override
  @JsonKey()
  final ColumnMapping columnMapping;
  @override
  final int? columnCount;
  @override
  @JsonKey()
  final String smsStartWords;
  @override
  @JsonKey()
  final String smsStopWords;

  @override
  String toString() {
    return 'ImportProfile(id: $id, name: $name, hasHeader: $hasHeader, dateFormat: $dateFormat, columnMapping: $columnMapping, columnCount: $columnCount, smsStartWords: $smsStartWords, smsStopWords: $smsStopWords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.hasHeader, hasHeader) ||
                other.hasHeader == hasHeader) &&
            (identical(other.dateFormat, dateFormat) ||
                other.dateFormat == dateFormat) &&
            (identical(other.columnMapping, columnMapping) ||
                other.columnMapping == columnMapping) &&
            (identical(other.columnCount, columnCount) ||
                other.columnCount == columnCount) &&
            (identical(other.smsStartWords, smsStartWords) ||
                other.smsStartWords == smsStartWords) &&
            (identical(other.smsStopWords, smsStopWords) ||
                other.smsStopWords == smsStopWords));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    hasHeader,
    dateFormat,
    columnMapping,
    columnCount,
    smsStartWords,
    smsStopWords,
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
    final bool hasHeader,
    final String dateFormat,
    final ColumnMapping columnMapping,
    final int? columnCount,
    final String smsStartWords,
    final String smsStopWords,
  }) = _$ImportProfileImpl;

  factory _ImportProfile.fromJson(Map<String, dynamic> json) =
      _$ImportProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get hasHeader;
  @override
  String get dateFormat;
  @override
  ColumnMapping get columnMapping;
  @override
  int? get columnCount;
  @override
  String get smsStartWords;
  @override
  String get smsStopWords;

  /// Create a copy of ImportProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportProfileImplCopyWith<_$ImportProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
