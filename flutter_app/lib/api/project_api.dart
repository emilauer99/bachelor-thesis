import 'package:flutter_app/api/api_delegate.dart';
import 'package:flutter_app/models/project_model.dart';

final class ProjectApi with DioDelegate {
  ProjectApi(var ref) {
    initializeDio(ref);
  }

  Future<dynamic> getAll() async {
    const apiUrl = '/projects';
    return await getRequest(apiUrl);
  }

  Future<dynamic> create(ProjectModel project) async {
    const apiUrl = '/projects';
    project = project.copyWith(customerId: project.customer.id);
    return await postRequest(apiUrl, requestBody: project.toJson());
  }

  Future<dynamic> update(int id, ProjectModel newProject) async {
    var apiUrl = '/projects/$id';
    newProject = newProject.copyWith(customerId: newProject.customer.id);
    return await putRequest(
      apiUrl,
      requestBody: newProject.toJson(),
    );
  }
}
