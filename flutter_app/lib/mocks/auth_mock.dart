import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthMock implements IAuthRepository {
  late final List<UserModel> _users;

  AuthMock() {
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/mocks/users.json');
    final list = jsonDecode(raw) as List;
    _users = list.map((j) => UserModel.fromJson(j)).toList();
  }

  @override
  Future<dynamic> login(String email, String password) async {
    final u = _users.firstWhere(
          (u) => u.email == email && u.password == password /* or store password field in JSON */,
      orElse: () => throw Exception('Invalid credentials'),
    );
    return u;
  }

  @override
  Future<void> logout() async {
  }
}
