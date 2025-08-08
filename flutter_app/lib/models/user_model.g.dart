// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  role: $enumDecode(_$EUserRoleEnumMap, json['role']),
  token: json['token'] as String?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$EUserRoleEnumMap[instance.role]!,
      'token': instance.token,
      'password': instance.password,
    };

const _$EUserRoleEnumMap = {
  EUserRole.admin: 'admin',
  EUserRole.employee: 'employee',
};
