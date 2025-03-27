import 'package:dio/dio.dart';
import 'package:flutter_app/api/api_delegate.dart';

final class CustomerApi with DioDelegate {
  CustomerApi(var ref) {
    initializeDio(ref);
  }

  Future<dynamic> getAll() async {
    const apiUrl = '/customers';
    return await getRequest(apiUrl);
  }

  Future<dynamic> create(String name, String filePath) async {
    const apiUrl = '/customers';

    FormData formData = FormData.fromMap({
      'name': name,
      'image': await MultipartFile.fromFile(filePath),
    });

    return await postRequest(
      apiUrl,
      requestBody: formData,
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    );
  }
}
