import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/env_config.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/providers/customer_list_provider.dart';
import 'package:flutter_app/ui/widgets/customer_list_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  List<CustomerModel>? currentCustomers;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerModal(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(customerListProvider.notifier).refresh(),
        child: customersAsync.when(
          loading: () {
            if (ref.read(customerListProvider.notifier).initialLoad) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildCustomerList(currentCustomers ?? []);
          },
          error: (error, stack) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(child: Text('Error: $error')),
            ),
          ),
          data: (customers) {
            currentCustomers = customers;
            return _buildCustomerList(customers);
          },
        ),
      ),
    );
  }

  void _showAddCustomerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setModalState(() {
                            _selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: const Text('Select Image from Gallery'),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImage != null)
                      SizedBox(
                        height: 100,
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _createNewCustomer(context),
                      child: const Text('Create Customer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createNewCustomer(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Call API to create customer
        await ref.read(customerListProvider.notifier).createCustomer(
          _nameController.text,
          _selectedImage!.path,
        );

        // Clear form and close modal
        _nameController.clear();
        setState(() => _selectedImage = null);
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Close modal

        // Refresh the list
        ref.read(customerListProvider.notifier).refresh();
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating customer: $e')),
        );
      }
    }
  }

  Widget _buildCustomerList(List<CustomerModel> customers) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: customers.length,
      itemBuilder: (context, index) => CustomerListTile(
        customer: customers[index],
        isDismissible: true,  // Enable dismissible here
        onDelete: (id) => _deleteCustomer(id, context),
      ),
    );
  }

  Future<void> _deleteCustomer(int id, BuildContext context) async {
    try {
      await ref.read(customerListProvider.notifier).delete(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}