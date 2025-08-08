import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/providers/repository_providers.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/ui/screens/board_screen.dart';
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
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(
          freshLogin: (state.extra as Map<String, dynamic>?)?['freshLogin'] ?? false,
        ),
        routes: [
          // Nested routes for tabs
          GoRoute(
            path: 'projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: 'board',
            builder: (context, state) => const BoardScreen(),
          ),
          GoRoute(
            path: 'others',
            builder: (context, state) => const OthersScreen(),
          ),
        ]
      ),
    ],
  );
});

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
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

      // unawaited(ref.read(customerRepositoryProvider).getAll());
      // unawaited(ref.read(projectRepositoryProvider).getAll());
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
      theme: theme
    );
  }
}
