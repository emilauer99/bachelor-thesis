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
    int? id,
    required String name,
    String? description,
    required EProjectState state,
    required bool isPublic,
    required String startDate,
    required String endDate,
    double? budget,
    int? estimatedHours,
    required CustomerModel customer,
    int? customerId
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
}
