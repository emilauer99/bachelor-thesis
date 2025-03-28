import 'package:flutter/material.dart';
import 'package:flutter_app/ui/widgets/notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/project_list_provider.dart';
import 'package:flutter_app/ui/widgets/project_form.dart';

Future<ProjectModel?> showProjectModal({
  required BuildContext context,
  required WidgetRef ref,
  ProjectModel? project,
}) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: true,
    builder: (context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(project == null ? 'New Project' : 'Edit Project'),
      ),
      body: ProjectForm(
        initialProject: project,
        onSubmit: (updatedProject) async {
          try {
            ProjectModel result;
            if (project == null) {
              result = await ref.read(projectListProvider.notifier)
                  .createProject(updatedProject);
              showSuccessNotification(context, 'Project created successfully!');
            } else {
              result = await ref.read(projectListProvider.notifier)
                  .updateProject(updatedProject.id!, updatedProject);
              showSuccessNotification(context, 'Project updated successfully!');
            }

            if (context.mounted) {
              Navigator.pop(context, result);
            }
          } catch (e) {
            if (context.mounted) {
              showErrorNotification(context, 'Error: ${e.toString()}');
            }
            rethrow;
          }
        },
      ),
    ),
  );
}