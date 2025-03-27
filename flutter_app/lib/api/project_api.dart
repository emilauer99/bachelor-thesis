import 'package:flutter_app/api/api_delegate.dart';

final class ProjectApi with DioDelegate {
  ProjectApi(var ref) {
    initializeDio(ref);
  }

  Future<dynamic> getAll() async {
    const apiUrl = '/projects';
    return await getRequest(apiUrl);
  }

  Future<dynamic> create(Map<String, dynamic> projectData) async {
    const apiUrl = '/projects';
    return await postRequest(apiUrl, requestBody: projectData);
  }
}
