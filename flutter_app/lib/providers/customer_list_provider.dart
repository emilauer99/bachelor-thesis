import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/providers/repository_providers.dart';
import 'package:riverpod/riverpod.dart';

import '../repositories/customer_repository.dart';

class CustomerListNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  bool initialLoad = true;
  final ICustomerRepository _repo;

  CustomerListNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await _repo.getAll();
      state = AsyncValue.data(c);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> createCustomer(String name, String imagePath) async {
    try {
      await _repo.create(name, imagePath);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      state.whenData((customers) {
        state = AsyncValue.data(customers.where((p) => p.id != id).toList());
      });

      await _repo.delete(id);
    } catch (e) {
      state.whenData((customers) {
        final customerToRestore = customers.firstWhere((p) => p.id == id);
        state = AsyncValue.data([...customers, customerToRestore]..sort((a, b) => a.id.compareTo(b.id)));
      });
      rethrow;
    }
  }
}

final customerListProvider = StateNotifierProvider<CustomerListNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  return CustomerListNotifier(ref.read(customerRepositoryProvider));
});

