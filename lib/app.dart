import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_dukans_user/core/config/router_config.dart';
import 'package:online_dukans_user/core/config/theme/app_theme.dart';
import 'package:online_dukans_user/provider/auth_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final Future<void> _loadSessionFuture;

  @override
  void initState() {
    super.initState();
    // Load session from secure storage on app start
    _loadSessionFuture = ref.read(authViewModelProvider.notifier).loadSession();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return FutureBuilder<void>(
      future: _loadSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a splash screen or loading indicator while waiting
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // After loadSession is complete, decide initial route:
        // If we have a valid token/user, go directly to dashboard.
        // Otherwise, go to login page.
        final initialLocation =
            (authState.user != null && authState.token != null)
                ? '/dashboard'
                : '/auth';

        final router = createRouter(initialLocation);

        return MaterialApp.router(
          title: 'My App',
          theme: AppTheme.theme, // Apply the defined theme
          routerConfig: router,
        );
      },
    );
  }
}
