import 'package:flutter/material.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/project_list_provider.dart';
import 'package:flutter_app/ui/screens/project_details_screen.dart';
import 'package:flutter_app/ui/widgets/project_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  List<ProjectModel>? currentProjects;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProjectModal(
          context: context,
          ref: ref,
        ),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectListProvider.notifier).refresh(),
        child: projectsAsync.when(
          loading: () {
            if (ref.read(projectListProvider.notifier).initialLoad) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildProjectList(currentProjects ?? []);
          },
          error: (error, stack) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(child: Text('Error: $error')),
            ),
          ),
          data: (projects) {
            currentProjects = projects;
            return _buildProjectList(projects);
          },
        ),
      ),
    );
  }

  Widget _buildProjectList(List<ProjectModel> projects) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(projects[index].name),
        subtitle: Text(projects[index].customer.name),
        trailing: _buildStateIndicator(projects[index].state),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: projects[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateIndicator(EProjectState state) {
    Color color;
    String tooltip;

    switch (state) {
      case EProjectState.planned:
        color = Colors.blue;
        tooltip = 'Project is in planning phase';
        break;
      case EProjectState.inProgress:
        color = Colors.orange;
        tooltip = 'Project is currently in progress';
        break;
      case EProjectState.finished:
        color = Colors.green;
        tooltip = 'Project has been completed';
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showStateTooltip(context, state),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      )
    );
  }

  void _showStateTooltip(BuildContext context, EProjectState state) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    String message;
    Color backgroundColor;

    switch (state) {
      case EProjectState.planned:
        message = 'Planned Project\n\nThis project is in the planning phase and hasn\'t started yet.';
        backgroundColor = Colors.blue.shade100;
        break;
      case EProjectState.inProgress:
        message = 'Project in Progress\n\nThis project is currently being worked on by the team.';
        backgroundColor = Colors.orange.shade100;
        break;
      case EProjectState.finished:
        message = 'Completed Project\n\nThis project has been successfully finished.';
        backgroundColor = Colors.green.shade100;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}