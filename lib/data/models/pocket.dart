import 'package:freezed_annotation/freezed_annotation.dart';

part 'pocket.freezed.dart';
part 'pocket.g.dart';

@freezed
class Pocket with _$Pocket {
  const factory Pocket({
    required String id,
    required String name,
    required String icon,
    required double balance,
    String? color,
  }) = _Pocket;

  factory Pocket.fromJson(Map<String, dynamic> json) => _$PocketFromJson(json);
}
