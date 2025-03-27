import 'package:freezed_annotation/freezed_annotation.dart';

import 'customer_model.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

enum EProjectState {
  planned,
  inProgress,
  finished;
}

@freezed
abstract class ProjectModel with _$ProjectModel {
  const factory ProjectModel({
    required String name,
    String? description,
    required EProjectState state,
    required bool isPublic,
    String? startDate,
    String? endDate,
    double? budget,
    int? estimatedHours,
    required CustomerModel customer
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
}
