import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_info.freezed.dart';

/// Information about an available app update from GitHub Releases
@freezed
class UpdateInfo with _$UpdateInfo {
  const factory UpdateInfo({
    /// Whether an update is available
    required bool hasUpdate,

    /// Whether the update is mandatory (blocks app usage)
    required bool isMandatory,

    /// Whether the current version is below minimum required version
    required bool isBlocked,

    /// The latest available version
    required String latestVersion,

    /// The current installed version
    required String currentVersion,

    /// Direct download URL for the APK
    required String downloadUrl,

    /// Release notes for the update
    required String releaseNotes,

    /// Release date
    required DateTime publishedAt,

    /// File size in bytes
    int? fileSizeBytes,
  }) = _UpdateInfo;

  const UpdateInfo._();

  /// Human-readable file size
  String get fileSizeFormatted {
    if (fileSizeBytes == null) return '';
    final mb = fileSizeBytes! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Whether user can skip this update
  bool get canSkip => hasUpdate && !isMandatory && !isBlocked;
}
