// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UpdateInfo {
  /// Whether an update is available
  bool get hasUpdate => throw _privateConstructorUsedError;

  /// Whether the update is mandatory (blocks app usage)
  bool get isMandatory => throw _privateConstructorUsedError;

  /// Whether the current version is below minimum required version
  bool get isBlocked => throw _privateConstructorUsedError;

  /// The latest available version
  String get latestVersion => throw _privateConstructorUsedError;

  /// The current installed version
  String get currentVersion => throw _privateConstructorUsedError;

  /// Direct download URL for the APK
  String get downloadUrl => throw _privateConstructorUsedError;

  /// Release notes for the update
  String get releaseNotes => throw _privateConstructorUsedError;

  /// Release date
  DateTime get publishedAt => throw _privateConstructorUsedError;

  /// File size in bytes
  int? get fileSizeBytes => throw _privateConstructorUsedError;

  /// Create a copy of UpdateInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateInfoCopyWith<UpdateInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateInfoCopyWith<$Res> {
  factory $UpdateInfoCopyWith(
    UpdateInfo value,
    $Res Function(UpdateInfo) then,
  ) = _$UpdateInfoCopyWithImpl<$Res, UpdateInfo>;
  @useResult
  $Res call({
    bool hasUpdate,
    bool isMandatory,
    bool isBlocked,
    String latestVersion,
    String currentVersion,
    String downloadUrl,
    String releaseNotes,
    DateTime publishedAt,
    int? fileSizeBytes,
  });
}

/// @nodoc
class _$UpdateInfoCopyWithImpl<$Res, $Val extends UpdateInfo>
    implements $UpdateInfoCopyWith<$Res> {
  _$UpdateInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasUpdate = null,
    Object? isMandatory = null,
    Object? isBlocked = null,
    Object? latestVersion = null,
    Object? currentVersion = null,
    Object? downloadUrl = null,
    Object? releaseNotes = null,
    Object? publishedAt = null,
    Object? fileSizeBytes = freezed,
  }) {
    return _then(
      _value.copyWith(
            hasUpdate: null == hasUpdate
                ? _value.hasUpdate
                : hasUpdate // ignore: cast_nullable_to_non_nullable
                      as bool,
            isMandatory: null == isMandatory
                ? _value.isMandatory
                : isMandatory // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBlocked: null == isBlocked
                ? _value.isBlocked
                : isBlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            latestVersion: null == latestVersion
                ? _value.latestVersion
                : latestVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            currentVersion: null == currentVersion
                ? _value.currentVersion
                : currentVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            downloadUrl: null == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            releaseNotes: null == releaseNotes
                ? _value.releaseNotes
                : releaseNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            publishedAt: null == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fileSizeBytes: freezed == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateInfoImplCopyWith<$Res>
    implements $UpdateInfoCopyWith<$Res> {
  factory _$$UpdateInfoImplCopyWith(
    _$UpdateInfoImpl value,
    $Res Function(_$UpdateInfoImpl) then,
  ) = __$$UpdateInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool hasUpdate,
    bool isMandatory,
    bool isBlocked,
    String latestVersion,
    String currentVersion,
    String downloadUrl,
    String releaseNotes,
    DateTime publishedAt,
    int? fileSizeBytes,
  });
}

/// @nodoc
class __$$UpdateInfoImplCopyWithImpl<$Res>
    extends _$UpdateInfoCopyWithImpl<$Res, _$UpdateInfoImpl>
    implements _$$UpdateInfoImplCopyWith<$Res> {
  __$$UpdateInfoImplCopyWithImpl(
    _$UpdateInfoImpl _value,
    $Res Function(_$UpdateInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasUpdate = null,
    Object? isMandatory = null,
    Object? isBlocked = null,
    Object? latestVersion = null,
    Object? currentVersion = null,
    Object? downloadUrl = null,
    Object? releaseNotes = null,
    Object? publishedAt = null,
    Object? fileSizeBytes = freezed,
  }) {
    return _then(
      _$UpdateInfoImpl(
        hasUpdate: null == hasUpdate
            ? _value.hasUpdate
            : hasUpdate // ignore: cast_nullable_to_non_nullable
                  as bool,
        isMandatory: null == isMandatory
            ? _value.isMandatory
            : isMandatory // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBlocked: null == isBlocked
            ? _value.isBlocked
            : isBlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        latestVersion: null == latestVersion
            ? _value.latestVersion
            : latestVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        currentVersion: null == currentVersion
            ? _value.currentVersion
            : currentVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        downloadUrl: null == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        releaseNotes: null == releaseNotes
            ? _value.releaseNotes
            : releaseNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        publishedAt: null == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fileSizeBytes: freezed == fileSizeBytes
            ? _value.fileSizeBytes
            : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$UpdateInfoImpl extends _UpdateInfo {
  const _$UpdateInfoImpl({
    required this.hasUpdate,
    required this.isMandatory,
    required this.isBlocked,
    required this.latestVersion,
    required this.currentVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
    this.fileSizeBytes,
  }) : super._();

  /// Whether an update is available
  @override
  final bool hasUpdate;

  /// Whether the update is mandatory (blocks app usage)
  @override
  final bool isMandatory;

  /// Whether the current version is below minimum required version
  @override
  final bool isBlocked;

  /// The latest available version
  @override
  final String latestVersion;

  /// The current installed version
  @override
  final String currentVersion;

  /// Direct download URL for the APK
  @override
  final String downloadUrl;

  /// Release notes for the update
  @override
  final String releaseNotes;

  /// Release date
  @override
  final DateTime publishedAt;

  /// File size in bytes
  @override
  final int? fileSizeBytes;

  @override
  String toString() {
    return 'UpdateInfo(hasUpdate: $hasUpdate, isMandatory: $isMandatory, isBlocked: $isBlocked, latestVersion: $latestVersion, currentVersion: $currentVersion, downloadUrl: $downloadUrl, releaseNotes: $releaseNotes, publishedAt: $publishedAt, fileSizeBytes: $fileSizeBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateInfoImpl &&
            (identical(other.hasUpdate, hasUpdate) ||
                other.hasUpdate == hasUpdate) &&
            (identical(other.isMandatory, isMandatory) ||
                other.isMandatory == isMandatory) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.latestVersion, latestVersion) ||
                other.latestVersion == latestVersion) &&
            (identical(other.currentVersion, currentVersion) ||
                other.currentVersion == currentVersion) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.releaseNotes, releaseNotes) ||
                other.releaseNotes == releaseNotes) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    hasUpdate,
    isMandatory,
    isBlocked,
    latestVersion,
    currentVersion,
    downloadUrl,
    releaseNotes,
    publishedAt,
    fileSizeBytes,
  );

  /// Create a copy of UpdateInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateInfoImplCopyWith<_$UpdateInfoImpl> get copyWith =>
      __$$UpdateInfoImplCopyWithImpl<_$UpdateInfoImpl>(this, _$identity);
}

abstract class _UpdateInfo extends UpdateInfo {
  const factory _UpdateInfo({
    required final bool hasUpdate,
    required final bool isMandatory,
    required final bool isBlocked,
    required final String latestVersion,
    required final String currentVersion,
    required final String downloadUrl,
    required final String releaseNotes,
    required final DateTime publishedAt,
    final int? fileSizeBytes,
  }) = _$UpdateInfoImpl;
  const _UpdateInfo._() : super._();

  /// Whether an update is available
  @override
  bool get hasUpdate;

  /// Whether the update is mandatory (blocks app usage)
  @override
  bool get isMandatory;

  /// Whether the current version is below minimum required version
  @override
  bool get isBlocked;

  /// The latest available version
  @override
  String get latestVersion;

  /// The current installed version
  @override
  String get currentVersion;

  /// Direct download URL for the APK
  @override
  String get downloadUrl;

  /// Release notes for the update
  @override
  String get releaseNotes;

  /// Release date
  @override
  DateTime get publishedAt;

  /// File size in bytes
  @override
  int? get fileSizeBytes;

  /// Create a copy of UpdateInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateInfoImplCopyWith<_$UpdateInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
