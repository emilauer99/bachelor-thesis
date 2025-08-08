import 'package:flutter_app/models/user_model.dart';

abstract class IAuthRepository {
  Future<dynamic> login(String email, String password);
  Future<void> logout();
}
