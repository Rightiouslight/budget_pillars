import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_info.dart';

/// Full-screen blocker shown when a mandatory update is required
///
/// This screen prevents users from accessing the app until they update.
class UpdateBlockerScreen extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateBlockerScreen({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Update icon
                Icon(
                  Icons.system_update,
                  size: 120,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Update Required',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Version info
                Text(
                  'Version ${updateInfo.latestVersion} is required to continue',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),

                Text(
                  'Current version: ${updateInfo.currentVersion}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Release notes (if available)
                if (updateInfo.releaseNotes.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What\'s New:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          updateInfo.releaseNotes,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Download button
                FilledButton.icon(
                  icon: const Icon(Icons.download),
                  label: Text(
                    'Download Update${updateInfo.fileSizeBytes != null ? ' (${updateInfo.fileSizeFormatted})' : ''}',
                  ),
                  onPressed: () => _downloadUpdate(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                ),

                const SizedBox(height: 16),

                // Installation instructions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Installation Instructions',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStep(
                          context,
                          '1',
                          'Tap "Download Update" to download the APK',
                        ),
                        const SizedBox(height: 8),
                        _buildStep(
                          context,
                          '2',
                          'Open the downloaded file from your notifications',
                        ),
                        const SizedBox(height: 8),
                        _buildStep(
                          context,
                          '3',
                          'Follow the prompts to install the update',
                        ),
                        const SizedBox(height: 8),
                        _buildStep(
                          context,
                          '4',
                          'You may need to allow installation from unknown sources',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Future<void> _downloadUpdate(BuildContext context) async {
    try {
      final uri = Uri.parse(updateInfo.downloadUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Download started. Please install the update to continue.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
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
