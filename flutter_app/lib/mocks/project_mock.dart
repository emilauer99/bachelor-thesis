import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';

class ProjectMock implements IProjectRepository {
  List<ProjectModel> _data = [];

  ProjectMock() {
    _init();
  }

  Future<void> _init() async {
    final raw = await rootBundle.loadString('assets/mocks/projects.json');
    final list = jsonDecode(raw) as List;
    _data = list.map((j) => ProjectModel.fromJson(j)).toList();
  }


  @override
  Future<dynamic> getAll() async {
    if(_data.isEmpty) {
      await _init();
    }
    return List.of(_data);
  }

  @override
  Future<dynamic> create(ProjectModel project) async {
    final nextId = (_data.map((p)=>p.id!).reduce((a,b)=>a>b?a:b))+1;
    final newP = project.copyWith(id: nextId);
    _data.add(newP);
    return newP;
  }

  @override
  Future<dynamic> update(int id, ProjectModel project) async {
    _data.removeWhere((p) => p.id == id);
    _data.add(project);
    return project;
  }

  @override
  Future<void> delete(int id) async {
    _data.removeWhere((p) => p.id == id);
  }

  @override
  Future<dynamic> setStateOfAll(EProjectState state) async {
    if (_data.isEmpty) await _init();
    _data = _data.map((p) => p.copyWith(state: state)).toList();
    return List.of(_data);
  }
}
