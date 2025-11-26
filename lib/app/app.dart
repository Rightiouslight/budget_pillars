import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firebase/auth_repository.dart';
import '../providers/profile_picture_cache_provider.dart';
import '../providers/theme_provider.dart';
import 'app_router.dart';

class BudgetPillarsApp extends ConsumerWidget {
  const BudgetPillarsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final blackTheme = ref.watch(blackThemeProvider);
    final useBlackTheme = ref.watch(useBlackThemeProvider);

    // Listen for auth state changes and cache profile picture when user signs in
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && previous?.value == null) {
        // User just signed in, cache their profile picture
        ref.read(profilePictureCacheProvider).cacheProfilePictureIfNeeded();
      }
    });

    return MaterialApp.router(
      title: 'Budget Pillars',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: useBlackTheme ? blackTheme : darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
