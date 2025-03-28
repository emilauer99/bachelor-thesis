// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) =>
    _ProjectModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      state: $enumDecode(_$EProjectStateEnumMap, json['state']),
      isPublic: json['isPublic'] as bool,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      estimatedHours: (json['estimatedHours'] as num?)?.toInt(),
      customer: CustomerModel.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
      customerId: (json['customerId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProjectModelToJson(_ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'state': _$EProjectStateEnumMap[instance.state]!,
      'isPublic': instance.isPublic,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'budget': instance.budget,
      'estimatedHours': instance.estimatedHours,
      'customer': instance.customer,
      'customerId': instance.customerId,
    };

const _$EProjectStateEnumMap = {
  EProjectState.planned: 'planned',
  EProjectState.inProgress: 'inProgress',
  EProjectState.finished: 'finished',
};
