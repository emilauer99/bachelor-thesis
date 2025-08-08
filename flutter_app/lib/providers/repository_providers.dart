import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../env_config.dart';
import '../repositories/auth_repository.dart';
import '../api/auth_api.dart';
import '../mocks/auth_mock.dart';
import '../repositories/customer_repository.dart';
import '../api/customer_api.dart';
import '../mocks/customer_mock.dart';
import '../repositories/project_repository.dart';
import '../api/project_api.dart';
import '../mocks/project_mock.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return EnvironmentConfig.mockData
      ? AuthMock()
      : AuthApi(ref);
});

final customerRepositoryProvider = Provider<ICustomerRepository>((ref) {
  return EnvironmentConfig.mockData
      ? CustomerMock()
      : CustomerApi(ref);
});

final projectRepositoryProvider = Provider<IProjectRepository>((ref) {
  return EnvironmentConfig.mockData
      ? ProjectMock()
      : ProjectApi(ref);
});
