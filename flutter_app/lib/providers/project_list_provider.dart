import 'package:flutter_app/env_config.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/repository_providers.dart';
import 'package:flutter_app/repositories/project_repository.dart';
import 'package:riverpod/riverpod.dart';

class ProjectListNotifier extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final IProjectRepository _repo;
  bool initialLoad = true;
  ProjectModel? currentlyUpdatingProject;

  ProjectListNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repo.getAll();
      final projects = EnvironmentConfig.mockData ? response : (response as List)
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
    await _load();
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      final response = await _repo.create(project);
      final newProject = EnvironmentConfig.mockData ? response : ProjectModel.fromJson(response);

      state.whenData((projects) {
        state = AsyncValue.data([...projects, newProject]);
      });

      return newProject;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<ProjectModel> updateProject(
      int id,
      ProjectModel project, {
        int? newIndex, // Add optional index parameter
      }) async {
    try {
      // Optimistically update in list
      state.whenData((projects) {
        currentlyUpdatingProject = projects.firstWhere((p) => p.id == id);
        final newProjects = List<ProjectModel>.from(projects);

        // Remove from old position
        newProjects.removeWhere((p) => p.id == id);

        // Insert at new position if specified
        if (newIndex != null && newIndex <= newProjects.length) {
          newProjects.insert(newIndex, project);
        } else {
          newProjects.add(project);
        }

        state = AsyncValue.data(newProjects);
      });

      final response = await _repo.update(id, project);
      final updatedProject = EnvironmentConfig.mockData ? response : ProjectModel.fromJson(response);

      // Ensure server response matches our update
      state.whenData((projects) {
        final newProjects = List<ProjectModel>.from(projects);
        newProjects.removeWhere((p) => p.id == id);

        if (newIndex != null && newIndex <= newProjects.length) {
          newProjects.insert(newIndex, updatedProject);
        } else {
          newProjects.add(updatedProject);
        }

        state = AsyncValue.data(newProjects);
      });

      return updatedProject;
    } catch (e, stackTrace) {
      // Revert on error
      state.whenData((projects) {
        if (currentlyUpdatingProject != null) {
          final newProjects = List<ProjectModel>.from(projects);
          newProjects.removeWhere((p) => p.id == id);

          // Find original index if available
          final originalIndex = projects.indexWhere((p) => p.id == id);
          if (originalIndex != -1) {
            newProjects.insert(originalIndex, currentlyUpdatingProject!);
          } else {
            newProjects.add(currentlyUpdatingProject!);
          }

          state = AsyncValue.data(newProjects);
        }
      });
      rethrow;
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      state.whenData((projects) {
        state = AsyncValue.data(projects.where((p) => p.id != id).toList());
      });

      await _repo.delete(id);
    } catch (e, stackTrace) {
      state.whenData((projects) {
        final projectToRestore = projects.firstWhere((p) => p.id == id);
        state = AsyncValue.data([...projects, projectToRestore]..sort((a, b) => a.id!.compareTo(b.id!)));
      });
      rethrow;
    }
  }
}

final projectListProvider = StateNotifierProvider<ProjectListNotifier, AsyncValue<List<ProjectModel>>>((ref) {
  return ProjectListNotifier(ref.read(projectRepositoryProvider));
});