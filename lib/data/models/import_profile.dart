import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_profile.freezed.dart';
part 'import_profile.g.dart';

@freezed
class ImportProfile with _$ImportProfile {
  const factory ImportProfile({
    required String id,
    required String name,
    @Default('csv') String type, // 'csv', 'text', 'sms'
    @Default({})
    Map<String, dynamic>
    columnMapping, // Maps CSV columns to transaction fields
    String? regex, // For text/SMS parsing
    @Default({})
    Map<String, String> categoryMappings, // Auto-categorization rules
  }) = _ImportProfile;

  factory ImportProfile.fromJson(Map<String, dynamic> json) =>
      _$ImportProfileFromJson(json);
}
