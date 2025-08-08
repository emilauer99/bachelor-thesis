import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

@freezed
abstract class CustomerModel with _$CustomerModel {
  const factory CustomerModel({
    required int id,
    required String name,
    String? imagePath,
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
}
