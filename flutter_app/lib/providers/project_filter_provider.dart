import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/customer_model.dart';

final customerFilterProvider = StateProvider<CustomerModel?>((ref) => null);
final stateFilterProvider = StateProvider<EProjectState?>((ref) => null);
