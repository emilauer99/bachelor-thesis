import 'package:flutter/material.dart';
import 'package:flutter_app/providers/mobile_provider.dart';
import 'package:flutter_app/providers/repository_providers.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/ui/screens/board_screen.dart';
import 'package:flutter_app/ui/screens/customers_screen.dart';
import 'package:flutter_app/ui/screens/dashboard_screen.dart' show DashboardScreen;
import 'package:flutter_app/ui/screens/home_screen.dart';
import 'package:flutter_app/ui/screens/login_screen.dart';
import 'package:flutter_app/ui/screens/others_screen.dart';
import 'package:flutter_app/ui/screens/projects_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'env_config.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder:
            (context, state, child) => HomeScreen(child: child, state: state),
        routes: [
          // Nested routes for tabs
          GoRoute(
            path: '/home',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/projects',
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/home/board',
            name: 'board',
            builder: (context, state) => const BoardScreen(),
          ),
          GoRoute(
            path: '/home/customers',
            name: 'customers',
            builder: (context, state) => const CustomersScreen(),
          ),
          GoRoute(
            path: '/home/others',
            name: 'others',
            builder: (context, state) => const OthersScreen(),
          ),
        ],
      ),
    ],
  );
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    if (EnvironmentConfig.mockData) {
      ref.read(authRepositoryProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      title: 'PMT',
      theme: theme,
      builder:
          (context, child) => LayoutBuilder(
            builder: (context, constraints) {
              return ProviderScope(
                overrides: [
                  mobileLayoutProvider.overrideWithValue(constraints.maxWidth),
                ],
                child: child!,
              );
            },
          ),
    );
  }
}
