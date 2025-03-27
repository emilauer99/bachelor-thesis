import 'package:flutter/material.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/ui/widgets/customer_list_tile.dart';
import 'package:intl/intl.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

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
            onPressed: () {
              // TODO: Implement edit functionality
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
                project.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 16),
            _buildStateChip(context),
          ],
        ),
        if (project.description != null) ...[
          const SizedBox(height: 8),
          Text(
            project.description!,
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

    switch (project.state) {
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
            _buildDetailRow('Visibility', project.isPublic ? 'Public' : 'Private'),
            _buildDetailRow('Budget', project.budget != null ? '\$${project.budget?.toStringAsFixed(2)}' : '-'),
            _buildDetailRow('Estimated Hours', project.estimatedHours != null ? '${project.estimatedHours} hrs' : '-'),
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
            CustomerListTile(customer: project.customer)
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
            if (project.startDate != null)
              _buildDetailRow('Start Date', dateFormat.format(DateTime.parse(project.startDate!))),
            if (project.endDate != null)
              _buildDetailRow('End Date', dateFormat.format(DateTime.parse(project.endDate!))),
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