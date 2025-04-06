import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/colors.dart';
import 'package:flutter_app/providers/project_filter_provider.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/project_list_provider.dart';

class StatusProjectsChart extends ConsumerWidget {
  const StatusProjectsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final selectedCustomer = ref.watch(customerFilterProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading projects')),
      data: (projects) {
        final filteredProjects = selectedCustomer != null
            ? projects.where((p) => p.customer.id == selectedCustomer.id).toList()
            : projects;

        if (filteredProjects.isEmpty) {
          return const Center(child: Text('No projects found'));
        }

        final statusCounts = {
          EProjectState.planned: 0,
          EProjectState.inProgress: 0,
          EProjectState.finished: 0,
        };

        for (final project in filteredProjects) {
          statusCounts[project.state] = statusCounts[project.state]! + 1;
        }

        final total = statusCounts.values.reduce((a, b) => a + b);

        final sections =
            statusCounts.entries.map((entry) {
              final percentage = ((entry.value / total) * 100).toStringAsFixed(1);
              final label = '${entry.value}\n($percentage%)';

              return PieChartSectionData(
                color: AppColors.getColorByState(entry.key),
                value: entry.value.toDouble(),
                title: label,
                radius: 65,
                titleStyle: theme.textTheme.titleSmall!.copyWith(color: Colors.white)
              );
            }).toList();

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppVariables.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 45,
                      sectionsSpace: 5,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: AppVariables.screenPadding),
                _buildLegend(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(AppColors.getColorByState(EProjectState.planned), 'Planned'),
        _legendItem(AppColors.getColorByState(EProjectState.inProgress), 'In Progress'),
        _legendItem(AppColors.getColorByState(EProjectState.finished), 'Finished'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
