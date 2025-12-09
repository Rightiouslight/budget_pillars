import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/update_info.dart';
import '../services/version_check_service.dart';
import '../widgets/update_blocker_screen.dart';
import '../widgets/update_dialog.dart';

/// Provider for version checking service
final versionCheckServiceProvider = Provider<VersionCheckService>((ref) {
  return VersionCheckService();
});

/// Check for updates on app launch and resume
class VersionCheckObserver extends StatefulWidget {
  final Widget child;

  const VersionCheckObserver({super.key, required this.child});

  @override
  State<VersionCheckObserver> createState() => _VersionCheckObserverState();
}

class _VersionCheckObserverState extends State<VersionCheckObserver>
    with WidgetsBindingObserver {
  bool _hasCheckedOnLaunch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check for updates after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCheckedOnLaunch) {
        _checkForUpdate();
        _hasCheckedOnLaunch = true;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check for updates when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _checkForUpdate();
    }
  }

  Future<void> _checkForUpdate() async {
    // Only check on mobile platforms
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }

    // Don't check in debug mode
    if (kDebugMode) {
      return;
    }

    try {
      final container = ProviderScope.containerOf(context);
      final service = container.read(versionCheckServiceProvider);
      final updateInfo = await service.checkForUpdate();

      if (!mounted) return;

      _handleUpdateInfo(updateInfo);
    } catch (e) {
      // Silently fail - don't interrupt user experience
      debugPrint('Version check failed: $e');
    }
  }

  void _handleUpdateInfo(UpdateInfo updateInfo) {
    if (!updateInfo.hasUpdate) {
      // No update available
      return;
    }

    if (updateInfo.isBlocked || updateInfo.isMandatory) {
      // Show blocker screen for mandatory updates
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => UpdateBlockerScreen(updateInfo: updateInfo),
        ),
      );
    } else {
      // Show dialog for optional updates
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => UpdateDialog(updateInfo: updateInfo),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
