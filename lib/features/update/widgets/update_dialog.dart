import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_info.dart';

/// Dialog shown when an optional or mandatory update is available
class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            updateInfo.isMandatory ? Icons.warning : Icons.system_update,
            color: updateInfo.isMandatory
                ? Colors.orange
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              updateInfo.isMandatory ? 'Update Required' : 'Update Available',
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version info
            Text(
              'Version ${updateInfo.latestVersion} is available',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Current version: ${updateInfo.currentVersion}',
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 16),

            // File size
            if (updateInfo.fileSizeBytes != null) ...[
              Text(
                'Size: ${updateInfo.fileSizeFormatted}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],

            // Release notes
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              Text(
                'What\'s New:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  updateInfo.releaseNotes,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],

            if (updateInfo.isMandatory) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This update contains important changes and must be installed to continue using the app.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // Later button (only for optional updates)
        if (updateInfo.canSkip)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),

        // Download button
        FilledButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Download'),
          onPressed: () => _downloadUpdate(context),
        ),
      ],
    );
  }

  Future<void> _downloadUpdate(BuildContext context) async {
    try {
      final uri = Uri.parse(updateInfo.downloadUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          // Show installation instructions
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Download started. Once complete, open the APK to install.',
              ),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(label: 'OK', onPressed: () {}),
            ),
          );

          // Close dialog if optional update
          if (updateInfo.canSkip && context.mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open download link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to download: $e');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
