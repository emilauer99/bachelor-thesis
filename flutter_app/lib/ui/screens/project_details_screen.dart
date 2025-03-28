import 'package:flutter/material.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/ui/widgets/customer_list_tile.dart';
import 'package:flutter_app/ui/widgets/project_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  late ProjectModel currentProject;

  @override
  void initState() {
    super.initState();
    currentProject = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;


    return Scaffold(
      appBar: AppBar(
        // title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedProject = await showProjectModal(
                context: context,
                ref: ref,
                project: currentProject,
              );

              if (updatedProject != null && mounted) {
                setState(() {
                  currentProject = updatedProject;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context),
            const SizedBox(height: 24),
            _buildDetailsSection(textTheme),
            const SizedBox(height: 24),
            _buildCustomerSection(theme),
            const SizedBox(height: 24),
            _buildDatesSection(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                currentProject.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 16),
            _buildStateChip(context),
          ],
        ),
        if (currentProject.description != null) ...[
          const SizedBox(height: 8),
          Text(
            currentProject.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildStateChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String stateText;

    switch (currentProject.state) {
      case EProjectState.planned:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        stateText = 'Planned';
        break;
      case EProjectState.inProgress:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        stateText = 'In Progress';
        break;
      case EProjectState.finished:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        stateText = 'Finished';
        break;
    }

    return Chip(
      backgroundColor: backgroundColor,
      label: Text(
        stateText,
        style: TextStyle(color: textColor),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDetailsSection(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Details', style: textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow('Visibility', currentProject.isPublic ? 'Public' : 'Private'),
            _buildDetailRow('Budget', currentProject.budget != null ? '\$${currentProject.budget?.toStringAsFixed(2)}' : '-'),
            _buildDetailRow('Estimated Hours', currentProject.estimatedHours != null ? '${currentProject.estimatedHours} hrs' : '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer', style: theme.textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 8),
            CustomerListTile(customer: currentProject.customer)
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection(TextTheme textTheme) {
    final dateFormat = DateFormat.yMMMd();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline', style: textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 8),
            if (currentProject.startDate != null)
              _buildDetailRow('Start Date', dateFormat.format(DateTime.parse(currentProject.startDate!))),
            if (currentProject.endDate != null)
              _buildDetailRow('End Date', dateFormat.format(DateTime.parse(currentProject.endDate!))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}