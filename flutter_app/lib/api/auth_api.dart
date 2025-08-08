import 'package:flutter_app/api/api_delegate.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

final class AuthApi with DioDelegate implements IAuthRepository {
  AuthApi(var ref) {
    initializeDio(ref);
  }

  Future<dynamic> login(String email, String password) async {
    const apiUrl = '/login';
    final body = {'email': email, 'password': password};
    return await postRequest(apiUrl, requestBody: body);
  }

  Future<dynamic> logout() async {
    const apiUrl = '/logout';
    return await postRequest(apiUrl);
  }

  Future<dynamic> getUser() async {
    const apiUrl = '/user';
    return await getRequest(apiUrl);
  }

}
