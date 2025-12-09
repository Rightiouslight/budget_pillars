import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/firebase/auth_repository.dart';
import '../features/auth/auth_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/landing/landing_page.dart';
import '../features/settings/settings_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/import_export/import_export_screen.dart';
import '../features/import/import_screen.dart';
import '../features/guide/guide_screen.dart';

/// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute =
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/auth';
      final isLandingRoute = state.matchedLocation == '/';

      // If authenticated, allow access to all routes except landing and auth
      if (isAuthenticated) {
        if (isLandingRoute || isAuthRoute) {
          return '/dashboard';
        }
        return null; // Allow access to other routes
      }

      // If not authenticated, only allow landing page and auth routes
      if (!isAuthenticated) {
        if (isLandingRoute || isAuthRoute) {
          return null; // Allow access to landing and auth
        }
        return '/'; // Redirect to landing page
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/import',
        name: 'import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/guide',
        name: 'guide',
        builder: (context, state) => const GuideScreen(),
      ),
      GoRoute(
        path: '/import-export',
        name: 'import-export',
        builder: (context, state) => const ImportExportScreen(),
      ),
    ],
  );
});
