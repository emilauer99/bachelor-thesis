import 'package:flutter_app/api/customer_api.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:riverpod/riverpod.dart';

class CustomerListNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  final Ref _ref;
  bool initialLoad = true;

  CustomerListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      final response = await CustomerApi(_ref).getAll();
      final customers = (response as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();
      state = AsyncValue.data(customers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      initialLoad = false;
    }
  }

  Future<void> refresh() async {
    await _loadCustomers();
  }

  Future<void> createCustomer(String name, String imagePath) async {
    try {
      await CustomerApi(_ref).create(name, imagePath);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      state.whenData((customers) {
        state = AsyncValue.data(customers.where((p) => p.id != id).toList());
      });

      await CustomerApi(_ref).delete(id);
    } catch (e, stackTrace) {
      state.whenData((customers) {
        final customerToRestore = customers.firstWhere((p) => p.id == id);
        state = AsyncValue.data([...customers, customerToRestore]..sort((a, b) => a.id!.compareTo(b.id!)));
      });
      rethrow;
    }
  }
}

final customerListProvider = StateNotifierProvider<CustomerListNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  return CustomerListNotifier(ref);
});

