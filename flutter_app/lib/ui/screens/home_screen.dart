import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/auth_api.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/ui/screens/board_screen.dart';
import 'package:flutter_app/ui/screens/dashboard_screen.dart';
import 'package:flutter_app/ui/screens/projects_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'board_screen.dart';
import 'others_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.freshLogin = false});
  final bool freshLogin;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _isValidatingToken = true;

  final List<Widget> _tabs = [
    const DashboardScreen(),
    const ProjectsScreen(),
    const BoardScreen(),
    const OthersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.freshLogin) {
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

    try {
      final response = await AuthApi(ref).getUser();
      final user = UserModel.fromJson(response);
      // Update auth state with fresh user data
      await ref.read(authStateProvider.notifier).authenticate(user);
    } catch (e) {
      if(kDebugMode) {
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
  }


  @override
  Widget build(BuildContext context) {
    if (_isValidatingToken) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PMT'),
        centerTitle: true,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
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
      ),
    );
  }
}
