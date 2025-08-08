import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum EUserRole {
  admin,
  employee;
}

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String email,
    required EUserRole role,
    String? token,
    String? password
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
