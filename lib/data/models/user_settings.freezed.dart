// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return _UserSettings.fromJson(json);
}

/// @nodoc
mixin _$UserSettings {
  Currency? get currency => throw _privateConstructorUsedError;
  int get monthStartDate =>
      throw _privateConstructorUsedError; // Day of month when budget period starts (1-28)
  Theme? get theme => throw _privateConstructorUsedError;
  bool get isCompactView =>
      throw _privateConstructorUsedError; // Deprecated - use viewPreferences instead
  List<ImportProfile> get importProfiles => throw _privateConstructorUsedError;
  ViewPreferences? get viewPreferences => throw _privateConstructorUsedError;
  String get smsImportNumber => throw _privateConstructorUsedError;

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
    UserSettings value,
    $Res Function(UserSettings) then,
  ) = _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call({
    Currency? currency,
    int monthStartDate,
    Theme? theme,
    bool isCompactView,
    List<ImportProfile> importProfiles,
    ViewPreferences? viewPreferences,
    String smsImportNumber,
  });

  $CurrencyCopyWith<$Res>? get currency;
  $ThemeCopyWith<$Res>? get theme;
  $ViewPreferencesCopyWith<$Res>? get viewPreferences;
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currency = freezed,
    Object? monthStartDate = null,
    Object? theme = freezed,
    Object? isCompactView = null,
    Object? importProfiles = null,
    Object? viewPreferences = freezed,
    Object? smsImportNumber = null,
  }) {
    return _then(
      _value.copyWith(
            currency: freezed == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as Currency?,
            monthStartDate: null == monthStartDate
                ? _value.monthStartDate
                : monthStartDate // ignore: cast_nullable_to_non_nullable
                      as int,
            theme: freezed == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as Theme?,
            isCompactView: null == isCompactView
                ? _value.isCompactView
                : isCompactView // ignore: cast_nullable_to_non_nullable
                      as bool,
            importProfiles: null == importProfiles
                ? _value.importProfiles
                : importProfiles // ignore: cast_nullable_to_non_nullable
                      as List<ImportProfile>,
            viewPreferences: freezed == viewPreferences
                ? _value.viewPreferences
                : viewPreferences // ignore: cast_nullable_to_non_nullable
                      as ViewPreferences?,
            smsImportNumber: null == smsImportNumber
                ? _value.smsImportNumber
                : smsImportNumber // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CurrencyCopyWith<$Res>? get currency {
    if (_value.currency == null) {
      return null;
    }

    return $CurrencyCopyWith<$Res>(_value.currency!, (value) {
      return _then(_value.copyWith(currency: value) as $Val);
    });
  }

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ThemeCopyWith<$Res>? get theme {
    if (_value.theme == null) {
      return null;
    }

    return $ThemeCopyWith<$Res>(_value.theme!, (value) {
      return _then(_value.copyWith(theme: value) as $Val);
    });
  }

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ViewPreferencesCopyWith<$Res>? get viewPreferences {
    if (_value.viewPreferences == null) {
      return null;
    }

    return $ViewPreferencesCopyWith<$Res>(_value.viewPreferences!, (value) {
      return _then(_value.copyWith(viewPreferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
    _$UserSettingsImpl value,
    $Res Function(_$UserSettingsImpl) then,
  ) = __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Currency? currency,
    int monthStartDate,
    Theme? theme,
    bool isCompactView,
    List<ImportProfile> importProfiles,
    ViewPreferences? viewPreferences,
    String smsImportNumber,
  });

  @override
  $CurrencyCopyWith<$Res>? get currency;
  @override
  $ThemeCopyWith<$Res>? get theme;
  @override
  $ViewPreferencesCopyWith<$Res>? get viewPreferences;
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
    _$UserSettingsImpl _value,
    $Res Function(_$UserSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currency = freezed,
    Object? monthStartDate = null,
    Object? theme = freezed,
    Object? isCompactView = null,
    Object? importProfiles = null,
    Object? viewPreferences = freezed,
    Object? smsImportNumber = null,
  }) {
    return _then(
      _$UserSettingsImpl(
        currency: freezed == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as Currency?,
        monthStartDate: null == monthStartDate
            ? _value.monthStartDate
            : monthStartDate // ignore: cast_nullable_to_non_nullable
                  as int,
        theme: freezed == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as Theme?,
        isCompactView: null == isCompactView
            ? _value.isCompactView
            : isCompactView // ignore: cast_nullable_to_non_nullable
                  as bool,
        importProfiles: null == importProfiles
            ? _value._importProfiles
            : importProfiles // ignore: cast_nullable_to_non_nullable
                  as List<ImportProfile>,
        viewPreferences: freezed == viewPreferences
            ? _value.viewPreferences
            : viewPreferences // ignore: cast_nullable_to_non_nullable
                  as ViewPreferences?,
        smsImportNumber: null == smsImportNumber
            ? _value.smsImportNumber
            : smsImportNumber // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsImpl implements _UserSettings {
  const _$UserSettingsImpl({
    this.currency,
    this.monthStartDate = 1,
    this.theme,
    this.isCompactView = false,
    final List<ImportProfile> importProfiles = const [],
    this.viewPreferences,
    this.smsImportNumber = '',
  }) : _importProfiles = importProfiles;

  factory _$UserSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsImplFromJson(json);

  @override
  final Currency? currency;
  @override
  @JsonKey()
  final int monthStartDate;
  // Day of month when budget period starts (1-28)
  @override
  final Theme? theme;
  @override
  @JsonKey()
  final bool isCompactView;
  // Deprecated - use viewPreferences instead
  final List<ImportProfile> _importProfiles;
  // Deprecated - use viewPreferences instead
  @override
  @JsonKey()
  List<ImportProfile> get importProfiles {
    if (_importProfiles is EqualUnmodifiableListView) return _importProfiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_importProfiles);
  }

  @override
  final ViewPreferences? viewPreferences;
  @override
  @JsonKey()
  final String smsImportNumber;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.monthStartDate, monthStartDate) ||
                other.monthStartDate == monthStartDate) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.isCompactView, isCompactView) ||
                other.isCompactView == isCompactView) &&
            const DeepCollectionEquality().equals(
              other._importProfiles,
              _importProfiles,
            ) &&
            (identical(other.viewPreferences, viewPreferences) ||
                other.viewPreferences == viewPreferences) &&
            (identical(other.smsImportNumber, smsImportNumber) ||
                other.smsImportNumber == smsImportNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currency,
    monthStartDate,
    theme,
    isCompactView,
    const DeepCollectionEquality().hash(_importProfiles),
    viewPreferences,
    smsImportNumber,
  );

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsImplToJson(this);
  }
}

abstract class _UserSettings implements UserSettings {
  const factory _UserSettings({
    final Currency? currency,
    final int monthStartDate,
    final Theme? theme,
    final bool isCompactView,
    final List<ImportProfile> importProfiles,
    final ViewPreferences? viewPreferences,
    final String smsImportNumber,
  }) = _$UserSettingsImpl;

  factory _UserSettings.fromJson(Map<String, dynamic> json) =
      _$UserSettingsImpl.fromJson;

  @override
  Currency? get currency;
  @override
  int get monthStartDate; // Day of month when budget period starts (1-28)
  @override
  Theme? get theme;
  @override
  bool get isCompactView; // Deprecated - use viewPreferences instead
  @override
  List<ImportProfile> get importProfiles;
  @override
  ViewPreferences? get viewPreferences;
  @override
  String get smsImportNumber;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
