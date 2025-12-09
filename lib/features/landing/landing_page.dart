import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/feature_card.dart';
import 'widgets/download_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/footer_section.dart';

/// Landing page shown to unauthenticated users
///
/// Features:
/// - Hero section with app introduction
/// - Feature showcase
/// - Mobile-specific download section
/// - Sign In / Register buttons
/// - Responsive design
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar with Sign In/Register
          SliverAppBar(
            floating: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            title: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Budget Pillars',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              // Sign In or Register Button
              FilledButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text('Sign In or Register'),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Hero Section
          const SliverToBoxAdapter(child: HeroSection()),

          // Download Section (Mobile Only)
          if (kIsWeb && isMobile)
            const SliverToBoxAdapter(child: DownloadSection()),

          // Features Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 48,
                vertical: 48,
              ),
              child: Column(
                children: [
                  Text(
                    'Powerful Budget Management',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Everything you need to take control of your finances',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Features Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900
                          ? 3
                          : constraints.maxWidth > 600
                          ? 2
                          : 1;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 1.2,
                        children: const [
                          FeatureCard(
                            icon: Icons.category,
                            title: 'Smart Categories',
                            description:
                                'Organize expenses with customizable categories and automatic recurring allocations',
                          ),
                          FeatureCard(
                            icon: Icons.savings,
                            title: 'Sinking Funds',
                            description:
                                'Save for future goals with automated monthly allocations to dedicated pockets',
                          ),
                          FeatureCard(
                            icon: Icons.repeat,
                            title: 'Recurring Income',
                            description:
                                'Set up automatic monthly income processing to designated pockets',
                          ),
                          FeatureCard(
                            icon: Icons.show_chart,
                            title: 'Visual Analytics',
                            description:
                                'Track spending patterns with beautiful charts and insights',
                          ),
                          FeatureCard(
                            icon: Icons.cloud_sync,
                            title: 'Cloud Sync',
                            description:
                                'Your data syncs across devices with Firebase cloud storage',
                          ),
                          FeatureCard(
                            icon: Icons.palette,
                            title: 'Customizable',
                            description:
                                'Choose from light, dark, or black themes with custom category colors',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Call to Action
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 48,
                vertical: 48,
              ),
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Ready to Take Control?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join thousands managing their budgets smarter',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(
                        0.8,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.go('/sign-in'),
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Get Started Free'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}
