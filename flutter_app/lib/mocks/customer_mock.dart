import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';

class CustomerMock implements ICustomerRepository {
  List<CustomerModel> _data = [];

  CustomerMock() {
    _init();
  }

  Future<void> _init() async {
    final raw = await rootBundle.loadString('assets/mocks/customers.json');
    final list = jsonDecode(raw) as List;
    _data = list.map((j) => CustomerModel.fromJson(j)).toList();
  }

  @override
  Future<dynamic> getAll() async {
    if(_data.isEmpty) {
      await _init();
    }
    return List.of(_data);
  }

  @override
  Future<dynamic> create(String name, String imagePath) async {
    final nextId = (_data.map((c) => c.id).reduce((a,b)=>a>b?a:b))+1;
    final c = CustomerModel(id: nextId, name: name, imagePath: imagePath);
    _data.add(c);
    return c;
  }

  @override
  Future<void> delete(int id) async {
    _data.removeWhere((c) => c.id == id);
  }
}
