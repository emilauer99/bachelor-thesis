import 'package:flutter/material.dart';
import 'package:flutter_app/colors.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/project_filter_provider.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/ui/widgets/filters/state_filter.dart';
import 'package:flutter_app/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'customer_filter.dart';

class ProjectFilters extends ConsumerWidget {
  const ProjectFilters({
    super.key,
    required this.projectsAsync,
    this.showCustomerFilter = true,
    this.showStateFilter = true,
  });

  final AsyncValue<List<ProjectModel>> projectsAsync;
  final bool showCustomerFilter;
  final bool showStateFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCustomer = ref.watch(customerFilterProvider);
    final selectedState = ref.watch(stateFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Use different layouts based on available width
            if (constraints.maxWidth > 600) {
              // Wide layout - filters side by side
              return Column(
                children: [
                  Row(
                    children: [
                      if (showCustomerFilter) Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CustomerFilter(projectsAsync: projectsAsync),
                        ),
                      ),
                      if (showStateFilter) Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: StateFilter(),
                        ),
                      ),
                    ],
                  ),
                  _buildFilterChips(selectedCustomer, selectedState, ref),
                ],
              );
            } else {
              // Narrow layout - filters stacked
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCustomerFilter) CustomerFilter(projectsAsync: projectsAsync),
                  if (showCustomerFilter && showStateFilter)
                    SizedBox(height: AppVariables.screenPadding/2),
                  if (showStateFilter) StateFilter(),
                  _buildFilterChips(selectedCustomer, selectedState, ref),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFilterChips(CustomerModel? selectedCustomer, EProjectState? selectedState, WidgetRef ref) {
    final selectedStateColors = selectedState != null ? AppColors.getColorsByState(selectedState) : null;
    return Wrap(
      spacing: AppVariables.screenPadding/2,
      children: [
        if (selectedCustomer != null && showCustomerFilter)
          InputChip(
            label: Text(selectedCustomer.name),
            onDeleted: () => ref.read(customerFilterProvider.notifier).state = null,
            deleteIcon: const Icon(Icons.close, size: 18),
            backgroundColor: theme.colorScheme.primaryContainer,
          ),
        if (selectedState != null && showStateFilter)
          InputChip(
            label: Text(selectedState.toString().split('.').last),
            onDeleted: () => ref.read(stateFilterProvider.notifier).state = null,
            deleteIcon: const Icon(Icons.close, size: 18),
            backgroundColor: selectedStateColors!.light,
          ),
      ],
    );
  }
}