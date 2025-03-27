import 'package:flutter_app/api/customer_api.dart';
import 'package:flutter_app/api/project_api.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:riverpod/riverpod.dart';

class ProjectListNotifier extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final Ref _ref;
  bool initialLoad = true;

  ProjectListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final response = await ProjectApi(_ref).getAll();
      final projects = (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
      state = AsyncValue.data(projects);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      initialLoad = false;
    }
  }

  Future<void> refresh() async {
    await _loadProjects();
  }

  Future<void> createProject(Map<String, dynamic> projectData) async {
    try {
      await ProjectApi(_ref).create(projectData);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

final projectListProvider = StateNotifierProvider<ProjectListNotifier, AsyncValue<List<ProjectModel>>>((ref) {
  return ProjectListNotifier(ref);
});