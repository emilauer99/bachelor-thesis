import 'package:flutter_app/api/auth_api.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/states/auth_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    // _checkAndFetchUserIfTokenPresent();
  }

  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  // Future<void> _checkAndFetchUserIfTokenPresent() async {
  //   final token = await _storage.read(key: 'api_token');
  //
  //   if (token == null)
  //     return;
  //
  //   state = state.copyWith(isLoading: true);
  //
  //   try {
  //     final responseData = await AuthApi(_ref).getUser();
  //     final user = UserModel.fromJson(responseData);
  //
  //     state = state.copyWith(isLoading: false, user: user);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, user: null);
  //     await resetAuthentication();
  //   }
  // }

  Future<void> authenticate(UserModel user) async {
    await _storage.write(key: 'api_token', value: user.token);
    state = state.copyWith(user: user);
  }

  Future<void> resetAuthentication() async {
    await _storage.delete(key: 'api_token');
    state = state.copyWith(user: null);
  }


  // Future<void> login(String email, String password) async {
  //   state = state.copyWith(isLoading: true, errorMessage: null);
  //
  //   try {
  //     print('XXXXXXXXX');
  //     final responseData = await AuthApi(_ref).login(email, password);
  //     print('YYYY');
  //
  //     final user = UserModel.fromJson(responseData);
  //
  //     state = state.copyWith(isLoading: false, user: user);
  //
  //     await _storage.write(key: 'api_token', value: user.token);
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       errorMessage: 'Login failed: ${e.toString()}',
  //     );
  //   }
  // }
  //
  // Future<void> logout() async {
  //   state = state.copyWith(isLoading: true, errorMessage: null);
  //
  //   try {
  //     await AuthApi(_ref).logout();
  //     await resetAuthentication();
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       user: null,
  //       errorMessage: 'Logout failed: ${e.toString()}',
  //     );
  //   }
  // }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
