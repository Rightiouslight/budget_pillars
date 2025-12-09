import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../models/update_info.dart';

/// Service to check for app updates from GitHub Releases
class VersionCheckService {
  /// GitHub repository owner and name
  /// TODO: Replace with your actual GitHub username/org and repo name
  static const _githubOwner = 'Rightiouslight';
  static const _githubRepo = 'budget_pillars';

  /// GitHub API endpoint for latest release
  static String get _apiUrl =>
      'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  /// Check for available updates
  ///
  /// Returns [UpdateInfo] with details about the latest release.
  /// If no update is available, [hasUpdate] will be false.
  ///
  /// Throws:
  /// - [SocketException] if no internet connection
  /// - [HttpException] if GitHub API fails
  /// - [FormatException] if response is invalid
  Future<UpdateInfo> checkForUpdate() async {
    try {
      // Fetch latest release from GitHub
      final response = await http
          .get(
            Uri.parse(_apiUrl),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw HttpException('No releases found in GitHub repository');
      }

      if (response.statusCode != 200) {
        throw HttpException(
          'GitHub API error: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Extract release information
      final latestVersion = _extractVersion(data['tag_name'] as String);
      final currentVersion = await _getCurrentVersion();
      final downloadUrl = _extractDownloadUrl(data);
      final releaseNotes =
          data['body'] as String? ?? 'No release notes available';
      final publishedAt = DateTime.parse(data['published_at'] as String);
      final fileSizeBytes = _extractFileSize(data);

      // Compare versions
      final current = Version.parse(currentVersion);
      final latest = Version.parse(latestVersion);

      final hasUpdate = latest > current;
      final isMandatory = hasUpdate && _isMandatoryUpdate(current, latest);
      final isBlocked = false; // Can be implemented with minimumVersion logic

      return UpdateInfo(
        hasUpdate: hasUpdate,
        isMandatory: isMandatory,
        isBlocked: isBlocked,
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
        publishedAt: publishedAt,
        fileSizeBytes: fileSizeBytes,
      );
    } on SocketException {
      rethrow; // No internet connection
    } on HttpException {
      rethrow; // GitHub API error
    } on FormatException {
      rethrow; // Invalid response
    } catch (e) {
      throw Exception('Failed to check for updates: $e');
    }
  }

  /// Extract version from GitHub tag name
  ///
  /// Handles tags like 'v1.0.0' or '1.0.0'
  String _extractVersion(String tagName) {
    // Remove 'v' prefix if present
    final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

    // Validate version format
    try {
      Version.parse(version);
      return version;
    } catch (e) {
      throw FormatException('Invalid version format: $tagName');
    }
  }

  /// Extract APK download URL from release assets
  String _extractDownloadUrl(Map<String, dynamic> data) {
    final assets = data['assets'] as List<dynamic>? ?? [];

    // Find APK file
    final apkAsset = assets.firstWhere(
      (asset) {
        final name = asset['name'] as String;
        return name.endsWith('.apk');
      },
      orElse: () =>
          throw FormatException('No APK file found in release assets'),
    );

    return apkAsset['browser_download_url'] as String;
  }

  /// Extract file size from release assets
  int? _extractFileSize(Map<String, dynamic> data) {
    try {
      final assets = data['assets'] as List<dynamic>? ?? [];
      final apkAsset = assets.firstWhere(
        (asset) => (asset['name'] as String).endsWith('.apk'),
        orElse: () => null,
      );

      return apkAsset?['size'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Determine if update is mandatory based on version change
  ///
  /// Rules:
  /// - MAJOR version change (X.0.0) → Mandatory
  /// - MINOR version change (x.X.0) → Mandatory
  /// - PATCH version change (x.x.X) → Optional
  bool _isMandatoryUpdate(Version current, Version latest) {
    // Mandatory if MAJOR or MINOR version changed
    return latest.major > current.major || latest.minor > current.minor;
  }

  /// Get current installed app version
  Future<String> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
