import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/env_config.dart';
import 'package:flutter_app/states/auth_state.dart';

import '../providers/auth_provider.dart';

mixin DioDelegate {
  late final Dio _dio;

  void initializeDio(var ref) {
    _dio = Dio(BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseURL,
        connectTimeout: const Duration(seconds: 50),
        headers: {'Accept': "application/json"}));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // add token to api requests
        final isNotLogin = !options.path.contains('/login');
        final authState = ref.read(authStateProvider);
        if (authState.isAuthenticated && isNotLogin) {
          options.headers['Authorization'] = 'Bearer ${authState.user!.token}';
        }

        if (kDebugMode) {
          debugPrint(
              "Request[${options.method}] => PATH: ${options.uri} HEADER: ${options.headers} DATA: ${options.data}");
        }
        return handler.next(options); // continue
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
              "Response[${response.statusCode}] => DATA: ${response.data}");
        }
        return handler.next(response); // continue
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          debugPrint(
              "Error[${e.response?.statusCode}] => MESSAGE: ${e.message}");
          debugPrint(
              'Error [${e.response?.statusCode}] ${e.requestOptions.path}');
          debugPrint('Message: ${e.message}');
          if (e.response?.data != null) {
            debugPrint('Data: ${e.response?.data}');
          }
        }

        // reset authentication
        if (e.response?.statusCode == 401) {
          ref.read(authStateProvider.notifier).resetAuthentication();
        }

        return handler.next(e); // continue
      },
    ));
  }

  //GET request
  Future<dynamic> getRequest(String apiUrl,
      {Map<String, String>? headers,
        Map<String, dynamic>? queryParameters}) async {
    final apiResponse = await _dio.get(apiUrl,
        options: Options(headers: headers),
        queryParameters: queryParameters);
    return apiResponse;
  }

  //POST request
  Future<dynamic> postRequest(String apiUrl,
      {dynamic requestBody,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters}) async {
    final apiResponse = await _dio.post(apiUrl,
        data: requestBody,
        options: Options(headers: headers),
        queryParameters: queryParameters);
    return apiResponse.data;
  }


  //PUT request
  Future<dynamic> putRequest(String apiUrl,
      {dynamic requestBody,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters}) async {

    final apiResponse = await _dio.put(apiUrl,
        data: requestBody,
        options: Options(contentType: Headers.formUrlEncodedContentType),
        queryParameters: queryParameters);

    return apiResponse.data;
  }

  // PATCH request
  Future<dynamic> patchRequest(String apiUrl,
      {dynamic requestBody,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters}) async {
    final apiResponse = await _dio.patch(apiUrl,
        data: requestBody,
        options: Options(headers: headers),
        queryParameters: queryParameters);

    return apiResponse.data;
  }

  //DELETE request
  Future<dynamic> deleteRequest(String apiUrl,
      {Map<String, dynamic>? requestBody,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters}) async {
    final apiResponse = await _dio.delete(apiUrl,
        data: requestBody,
        options: Options(headers: headers),
        queryParameters: queryParameters);

    return apiResponse.data;
  }
}