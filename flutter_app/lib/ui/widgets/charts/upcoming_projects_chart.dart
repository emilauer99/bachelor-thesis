import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/project_filter_provider.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/providers/project_list_provider.dart';

class UpcomingProjectsChart extends ConsumerWidget {
  const UpcomingProjectsChart({super.key});

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

        final now = DateTime.now();
        final firstMonth = DateTime(now.year, now.month); // next month
        final months = List.generate(12, (i) {
          final date = DateTime(firstMonth.year, firstMonth.month + i);
          return DateFormat('MMM yyyy').format(date);
        });

        // Map month index (0-11) => project count
        final runningProjectsPerMonth = List.generate(12, (_) => 0);

        for (final project in filteredProjects) {
          final start = DateTime.tryParse(project.startDate);
          final end = DateTime.tryParse(project.endDate);
          if (start == null || end == null) continue;

          for (int i = 0; i < 12; i++) {
            final monthDate = DateTime(firstMonth.year, firstMonth.month + i);
            final startOfMonth = DateTime(monthDate.year, monthDate.month);
            final endOfMonth = DateTime(monthDate.year, monthDate.month + 1).subtract(const Duration(days: 1));

            if (start.isBefore(endOfMonth) && end.isAfter(startOfMonth)) {
              runningProjectsPerMonth[i]++;
            }
          }
        }

        final maxY = (runningProjectsPerMonth.reduce((a, b) => a > b ? a : b) + 1).toDouble();

        final minBarWidth = 40.0; // Minimum space per month
        final totalWidth = months.length * minBarWidth;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppVariables.screenPadding / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: (months.length - 1).toDouble() ,
                            minY: 0,
                            maxY: maxY,
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipPadding: EdgeInsets.all(2),
                                tooltipMargin: 5,
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipColor: (LineBarSpot spot) => Colors.white,
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      '${spot.y.toInt()}',
                                      theme.textTheme.titleSmall!
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                spots: runningProjectsPerMonth
                                    .asMap()
                                    .entries
                                    .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                                    .toList(),
                                dotData: FlDotData(show: true),
                                barWidth: 2,
                                color: theme.primaryColor,
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
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
                                  showTitles: true,
                                  reservedSize: 80,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= months.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Text(
                                          months[index],
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: true),
                          ),
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
