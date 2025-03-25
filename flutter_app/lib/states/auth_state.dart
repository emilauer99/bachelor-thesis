import 'package:flutter_app/models/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    UserModel? user,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => user != null;
}