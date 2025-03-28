import 'package:flutter_app/api/project_api.dart';
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

  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      final response = await ProjectApi(_ref).create(project);
      final newProject = ProjectModel.fromJson(response);

      state.whenData((projects) {
        state = AsyncValue.data([...projects, newProject]);
      });

      return newProject;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<ProjectModel> updateProject(int id, ProjectModel project) async {
    try {
      final response = await ProjectApi(_ref).update(id, project);
      final updatedProject = ProjectModel.fromJson(response);

      state.whenData((projects) {
        state = AsyncValue.data(
            projects.map((p) => p.id == id ? updatedProject : p).toList()
        );
      });

      return updatedProject;
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}

final projectListProvider = StateNotifierProvider<ProjectListNotifier, AsyncValue<List<ProjectModel>>>((ref) {
  return ProjectListNotifier(ref);
});