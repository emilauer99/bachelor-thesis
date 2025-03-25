import 'dart:convert';

import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/states/auth_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  Future<void> authenticate(UserModel user) async {
    final userString = jsonEncode(user.toJson());
    await _storage.write(key: 'user', value: userString);
    state = state.copyWith(user: user);
  }

  Future<void> resetAuthentication() async {
    await _storage.delete(key: 'user');
    state = state.copyWith(user: null);
  }

  Future<void> readAuthentication() async {
    final userString = await _storage.read(key: 'user');
    if (userString != null) {
      final userJson = jsonDecode(userString);
      state = state.copyWith(user: UserModel.fromJson(userJson));
    } else {
      state = state.copyWith(user: null);
    }
  }

}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
