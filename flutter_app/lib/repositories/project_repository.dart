import 'package:flutter_app/models/project_model.dart';

abstract class IProjectRepository {
  Future<dynamic> getAll();
  Future<dynamic> create(ProjectModel project);
  Future<dynamic> update(int id, ProjectModel project);
  Future<void> delete(int id);
  Future<dynamic> setStateOfAll(EProjectState state);
}
