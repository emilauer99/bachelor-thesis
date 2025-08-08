import 'package:flutter_app/models/customer_model.dart';

abstract class ICustomerRepository {
  Future<dynamic> getAll();
  Future<dynamic> create(String name, String imagePath);
  Future<void> delete(int id);
}
