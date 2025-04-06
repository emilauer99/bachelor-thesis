import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/project_filter_provider.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/project_list_provider.dart';

class CustomerProjectsChart extends ConsumerWidget {
  const CustomerProjectsChart({super.key});

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

        // Group projects by customer and count them
        final customerProjectCounts = <String, int>{};
        for (final project in filteredProjects) {
          final customerName = project.customer.name;
          customerProjectCounts[customerName] =
              (customerProjectCounts[customerName] ?? 0) + 1;
        }

        final sortedCustomers = customerProjectCounts.keys.toList()..sort();

        final maxCount =
            customerProjectCounts.values.isNotEmpty
                ? customerProjectCounts.values.reduce((a, b) => a > b ? a : b)
                : 1;
        var maxY = (maxCount + 2).toDouble();

        final barWidth = 20.0;
        final groupSpace = 20.0;
        final requiredWidth =
            sortedCustomers.length * (barWidth + groupSpace) + 100;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppVariables.screenPadding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300, // Fixed height for the chart area
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: requiredWidth,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          minY: 0,
                          groupsSpace: groupSpace,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipPadding: EdgeInsets.all(0),
                              getTooltipColor:
                                  (BarChartGroupData group) =>
                                      Colors.transparent,
                              tooltipMargin: 0,
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                final customer =
                                    sortedCustomers[group.x.toInt()];
                                final value = rod.toY.toInt();
                                return BarTooltipItem(
                                  '$value',
                                  theme.textTheme.bodySmall!,
                                );
                              },
                            ),
                          ),
                          barGroups:
                              sortedCustomers.asMap().entries.map((entry) {
                                final index = entry.key;
                                final customer = entry.value;
                                final count =
                                    customerProjectCounts[customer]!.toDouble();

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY:
                                          customerProjectCounts[customer]!
                                              .toDouble(),
                                      color: theme.primaryColor,
                                      width: barWidth,
                                      borderRadius: BorderRadius.circular(4),
                                      rodStackItems: [],
                                    ),
                                  ],
                                  showingTooltipIndicators: [0],
                                  barsSpace: 0,
                                );
                              }).toList(),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  // Skip showing the maxY value
                                  if (value == maxY) return const SizedBox.shrink();
                                  return Text(
                                    value.toInt().toString(),
                                    style: theme.textTheme.bodySmall,
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 100,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 ||
                                      index >= sortedCustomers.length) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Text(
                                        sortedCustomers[index],
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
