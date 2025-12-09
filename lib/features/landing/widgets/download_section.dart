import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional import for web-only functionality
import 'download_section_stub.dart'
    if (dart.library.html) 'download_section_web.dart';

/// Download section shown only on mobile browsers
///
/// Offers two options:
/// 1. Download Android APK
/// 2. Continue in browser
class DownloadSection extends StatelessWidget {
  const DownloadSection({super.key});

  static const _githubReleaseUrl =
      'https://github.com/Rightiouslight/budget_pillars/releases/latest';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.android, size: 48, color: theme.colorScheme.onPrimary),
          const SizedBox(height: 16),
          Text(
            'Get the App',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Download Budget Pillars for the best experience',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Download APK Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _downloadAPK(context),
              icon: const Icon(Icons.download),
              label: const Text('Download APK'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Continue in Browser Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/sign-in'),
              icon: const Icon(Icons.web),
              label: const Text('Continue in Browser'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Installation note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You may need to enable "Install from Unknown Sources"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAPK(BuildContext context) async {
    try {
      final uri = Uri.parse(_githubReleaseUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening download page...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          _showDownloadInstructions(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDownloadInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To download Budget Pillars:'),
            const SizedBox(height: 16),
            const Text('1. Go to our GitHub releases page'),
            const SizedBox(height: 8),
            const Text('2. Download the latest APK file'),
            const SizedBox(height: 8),
            const Text('3. Open the file to install'),
            const SizedBox(height: 16),
            SelectableText(
              _githubReleaseUrl,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              openLinkInNewTab(_githubReleaseUrl);
              Navigator.pop(context);
            },
            child: const Text('Open Link'),
          ),
        ],
      ),
    );
  }
}
