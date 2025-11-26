import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_profile.freezed.dart';
part 'import_profile.g.dart';

@freezed
class ColumnMapping with _$ColumnMapping {
  const factory ColumnMapping({
    String? date,
    String? description,
    String? amount,
  }) = _ColumnMapping;

  factory ColumnMapping.fromJson(Map<String, dynamic> json) =>
      _$ColumnMappingFromJson(json);
}

@freezed
class ImportProfile with _$ImportProfile {
  const factory ImportProfile({
    required String id,
    required String name,
    @Default(true) bool hasHeader,
    @Default('M/d/yyyy') String dateFormat,
    @Default(ColumnMapping()) ColumnMapping columnMapping,
    int? columnCount,
    @Default('') String smsStartWords,
    @Default('') String smsStopWords,
  }) = _ImportProfile;

  factory ImportProfile.fromJson(Map<String, dynamic> json) =>
      _$ImportProfileFromJson(json);
}
