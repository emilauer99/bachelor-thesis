import 'package:flutter/material.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/customer_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectForm extends ConsumerStatefulWidget {
  final ProjectModel? initialProject;
  final Function(ProjectModel) onSubmit;

  const ProjectForm({super.key, this.initialProject, required this.onSubmit});

  @override
  ConsumerState<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _estimatedHoursController;
  late EProjectState _state;
  late bool _isPublic;
  late CustomerModel? _selectedCustomer;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final project = widget.initialProject;
    _nameController = TextEditingController(text: project?.name ?? '');
    _descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    _budgetController = TextEditingController(
      text: project?.budget?.toString() ?? '',
    );
    _estimatedHoursController = TextEditingController(
      text: project?.estimatedHours?.toString() ?? '',
    );
    _state = project?.state ?? EProjectState.planned;
    _isPublic = project?.isPublic ?? false;
    _selectedCustomer = project?.customer;

    if (project?.startDate != null) {
      _startDate = DateTime.parse(project!.startDate!);
    }
    if (project?.endDate != null) {
      _endDate = DateTime.parse(project!.endDate!);
    }

    // Load customers if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customers = ref.read(customerListProvider);
      if (customers is! AsyncData) {
        ref.read(customerListProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EProjectState>(
              value: _state,
              decoration: const InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(),
              ),
              items:
                  EProjectState.values.map((state) {
                    return DropdownMenuItem<EProjectState>(
                      value: state,
                      child: Text(state.name.toUpperCase()),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _state = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public Project'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
            const SizedBox(height: 16),
            customersAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading customers: $error'),
              data: (customers) {
                // Only build the customer dropdown when we have data
                return DropdownButtonFormField<CustomerModel>(
                  value: _selectedCustomer,
                  decoration: const InputDecoration(
                    labelText: 'Customer *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a customer';
                    }
                    return null;
                  },
                  items:
                      customers.map((customer) {
                        return DropdownMenuItem<CustomerModel>(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }).toList(),
                  onChanged:
                      (value) => setState(() => _selectedCustomer = value),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Budget',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _estimatedHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Hours',
                      border: OutlineInputBorder(),
                      suffixText: 'hours',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _startDate == null
                          ? 'Set Start Date'
                          : 'Start: ${_formatDate(_startDate!)}',
                    ),
                    onPressed: () => _pickDate(context, isStartDate: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _endDate == null
                          ? 'Set End Date'
                          : 'End: ${_formatDate(_endDate!)}',
                    ),
                    onPressed: () => _pickDate(context, isStartDate: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    widget.initialProject == null
                        ? 'Create Project'
                        : 'Update Project',
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate =
        isStartDate
            ? DateTime.now().subtract(const Duration(days: 365))
            : _startDate ?? DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365 * 5));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(pickedDate)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _formatDateForApi(DateTime? date) {
    if (date == null) {
      return null;
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCustomer != null) {
      setState(() => _isLoading = true);
      try {
        final budget = double.tryParse(_budgetController.text);
        final project = ProjectModel(
          id: widget.initialProject?.id,
          name: _nameController.text,
          description:
              _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
          state: _state,
          isPublic: _isPublic,
          customer: _selectedCustomer!,
          startDate: _formatDateForApi(_startDate),
          endDate: _formatDateForApi(_endDate),
          budget: budget != null ? budget * 100 : null,
          estimatedHours:
              _estimatedHoursController.text.isNotEmpty
                  ? int.tryParse(_estimatedHoursController.text)
                  : null,
        );
        await widget.onSubmit(project);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false); // Stop loading
        }
      }
    }
  }
}
