import 'package:flutter/material.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/project_filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerFilter extends ConsumerWidget {
  const CustomerFilter({super.key, required this.projectsAsync});

  final AsyncValue<List<ProjectModel>> projectsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCustomer = ref.watch(customerFilterProvider);

    return projectsAsync.when(
      loading: () {
        return AbsorbPointer(
          child: DropdownButtonFormField<CustomerModel>(
            value: selectedCustomer,
            decoration: InputDecoration(
              labelText: 'Filter Customer',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              if (selectedCustomer != null)
                DropdownMenuItem<CustomerModel>(
                  value: selectedCustomer,
                  child: Text(selectedCustomer.name),
                ),
              DropdownMenuItem<CustomerModel>(
                value: null,
                child: Text('All Customers'),
              ),
            ],
            onChanged: null,
          ),
        );
      },
      error: (error, stack) => const Text('Error loading customers'),
      data: (projects) {
        // Get all unique customers
        final customers = <CustomerModel>{};
        for (final project in projects) {
          customers.add(project.customer);
        }
        final customerList = customers.toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return DropdownButtonFormField<CustomerModel>(
          value: selectedCustomer,
          decoration: InputDecoration(
            labelText: 'Filter Customer',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            DropdownMenuItem<CustomerModel>(
              value: null,
              child: Text('All Customers'),
            ),
            ...customerList.map((customer) {
              return DropdownMenuItem<CustomerModel>(
                value: customer,
                child: Text(customer.name),
              );
            }),
          ],
          onChanged: (customer) {
            ref.read(customerFilterProvider.notifier).state = customer;
          },
        );
      },
    );
  }
}