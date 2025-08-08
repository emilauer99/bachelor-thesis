import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/auth_api.dart';
import 'package:flutter_app/env_config.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/mobile_provider.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/ui/screens/board_screen.dart';
import 'package:flutter_app/ui/screens/customers_screen.dart';
import 'package:flutter_app/ui/screens/dashboard_screen.dart';
import 'package:flutter_app/ui/screens/projects_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/repository_providers.dart';
import '../../repositories/auth_repository.dart';
import '../../variables.dart';
import 'board_screen.dart';
import 'others_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.child, required this.state});

  final Widget child;
  final GoRouterState state;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isValidatingToken = true;

  @override
  void initState() {
    super.initState();
    final freshLogin = widget.state.uri.queryParameters['fresh'] == '1';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!freshLogin) {
        _validateAuthState();
      } else {
        setState(() => _isValidatingToken = false);
      }
    });
  }

  Future<void> _validateAuthState() async {
    await ref.read(authStateProvider.notifier).readAuthentication();
    final authState = ref.read(authStateProvider);

    if (!authState.isAuthenticated) {
      if (mounted) context.go('/login');
      return;
    }

    if (!EnvironmentConfig.mockData) {
      try {
        final response = await AuthApi(ref).getUser();
        final user = UserModel.fromJson(response);
        // Update auth state with fresh user data
        await ref.read(authStateProvider.notifier).authenticate(user);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        // Token is invalid or request failed
        await ref.read(authStateProvider.notifier).resetAuthentication();
        if (mounted) context.go('/login');
      } finally {
        if (mounted) {
          setState(() => _isValidatingToken = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _isValidatingToken = false);
      }
    }
  }

  // Map current URL → selected index
  int _indexFromLocation(String location, bool mobile) {
    if (location.startsWith('/home/projects')) return 1;
    if (location.startsWith('/home/board')) return 2;
    if (mobile) {
      if (location.startsWith('/home/others')) return 3;
    } else {
      if (location.startsWith('/home/customers')) return 3;
    }
    return 0; // /home => Dashboard
  }

  // Map index → route to go to
  String _locationFromIndex(int i, bool mobile) {
    switch (i) {
      case 1: return '/home/projects';
      case 2: return '/home/board';
      case 3: return mobile ? '/home/others' : '/home/customers';
      default: return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidatingToken) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mobileLayout = ref.watch(isMobileLayoutProvider);
    final location = GoRouterState.of(context).uri.toString();
    print(location);
    final selectedIndex = _indexFromLocation(location, mobileLayout);
    print(selectedIndex);

    final List<Widget> tabs = [
      const DashboardScreen(),
      const ProjectsScreen(),
      const BoardScreen(),
      mobileLayout ? OthersScreen() : CustomersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('PMT'), centerTitle: true),
      backgroundColor: Colors.white,
      body:
          mobileLayout
              ? widget.child
              : Row(
                children: [
                  NavigationRail(
                    extended: true,
                    selectedIndex: selectedIndex,
                    onDestinationSelected:
                        (i) => context.go(_locationFromIndex(i, mobileLayout)),
                    leading: const SizedBox(height: 8),
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text(
                          'Dashboard',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.list_outlined),
                        selectedIcon: Icon(Icons.list),
                        label: Text(
                          'Projects',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.view_column_outlined),
                        selectedIcon: Icon(Icons.view_column),
                        label: Text('Board', style: theme.textTheme.bodySmall),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(Icons.people),
                        label: Text(
                          'Customers',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: AppVariables.screenPadding),
                          child: GestureDetector(
                            onTap: () => _logout(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.logout, size: 20,),
                                SizedBox(width: 15,),
                                Text("Logout", style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: widget.child),
                ],
              ),
      bottomNavigationBar:
          mobileLayout
              ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: selectedIndex,
                onTap: (i) => context.go(_locationFromIndex(i, mobileLayout)),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'Projects',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.view_column),
                    label: 'Board',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz),
                    label: 'More',
                  ),
                ],
              )
              : null,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final IAuthRepository repo = ref.read(authRepositoryProvider);

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await Future.wait([
        repo.logout(),
        ref.read(authStateProvider.notifier).resetAuthentication(),
      ]);

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
    }
  }
}
