import 'package:flutter/material.dart';
import 'package:flutter_app/providers/project_list_provider.dart';
import 'package:flutter_app/ui/widgets/charts/customer_projects_chart.dart';
import 'package:flutter_app/ui/widgets/charts/status_projects_chart.dart';
import 'package:flutter_app/ui/widgets/charts/upcoming_projects_chart.dart';
import 'package:flutter_app/ui/widgets/filters/projects_filters.dart';
import 'package:flutter_app/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);


    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppVariables.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProjectFilters(projectsAsync: projectsAsync, showStateFilter: false,),
                const SizedBox(height: AppVariables.screenPadding),
                if(projectsAsync.isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                if(!projectsAsync.isLoading) ...[
                  Text(
                    'Projects by Customer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CustomerProjectsChart(),
                  SizedBox(height: AppVariables.screenPadding),
                  Text(
                    'Projects by State',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  StatusProjectsChart(),
                  SizedBox(height: AppVariables.screenPadding),
                  Text(
                    'Projects per Month',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  UpcomingProjectsChart()
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
