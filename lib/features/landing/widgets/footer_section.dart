import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Footer section with links and copyright
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          // Links
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildLink(
                context,
                'GitHub',
                'https://github.com/Rightiouslight/budget_pillars',
              ),
              _buildLink(
                context,
                'Releases',
                'https://github.com/Rightiouslight/budget_pillars/releases',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Copyright
          Text(
            '© $year Budget Pillars. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),

          // Made with Flutter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made with ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Icon(Icons.favorite, size: 14, color: Colors.red.shade400),
              Text(
                ' using Flutter',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String label, String url) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _launchUrl(url),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.startsWith('#')) {
      // Internal anchor - handle if needed
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
