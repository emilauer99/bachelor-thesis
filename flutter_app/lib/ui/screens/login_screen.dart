import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/auth_api.dart';
import 'package:flutter_app/env_config.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/repository_providers.dart';
import 'package:flutter_app/repositories/auth_repository.dart';
import 'package:flutter_app/ui/widgets/notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final IAuthRepository repo = ref.read(authRepositoryProvider);

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);

      try {
        final response = await repo.login(_emailController.text, _passwordController.text);
        final user = EnvironmentConfig.mockData ? response : UserModel.fromJson(response);
        await ref.read(authStateProvider.notifier).authenticate(user);

        if (mounted) {
          context.go('/home', extra: {'freshLogin': true});
        }
      } on DioException catch (dioError) {
        final data = dioError.response?.data;
        if (dioError.response?.statusCode == 401) {
          showErrorNotification(context, "Credentials incorrect.");
        } else if (data is Map<String, dynamic> &&
            data.containsKey('message') &&
            data['message'] != null) {

          showErrorNotification(context, "${data['message']}");
        } else {
          showErrorNotification(context, "Unknown error.");
        }
      } on Exception catch (e) {
        showErrorNotification(context, "Credentials incorrect.");
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'PMT',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'A project management tool',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address.';
                          }
                          final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please enter a password.'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child:
                            _loading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text('Login'),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
