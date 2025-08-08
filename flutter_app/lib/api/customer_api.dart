import 'package:dio/dio.dart';
import 'package:flutter_app/api/api_delegate.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/repositories/customer_repository.dart';

final class CustomerApi with DioDelegate implements ICustomerRepository {
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

  Future<dynamic> delete(int id) async {
    final apiUrl = '/customers/$id';
    return await deleteRequest(apiUrl);
  }
}
