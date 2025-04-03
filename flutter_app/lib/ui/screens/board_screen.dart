import 'package:flutter/material.dart';
import 'package:flutter_app/colors.dart';
import 'package:flutter_app/models/project_model.dart';
import 'package:flutter_app/providers/project_list_provider.dart';
import 'package:flutter_app/theme.dart';
import 'package:flutter_app/ui/widgets/notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectStateList{
  EProjectState state;
  List<ProjectModel> projects;

  ProjectStateList({required this.state,required this.projects});
}

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> with AutomaticKeepAliveClientMixin  {

  @override
  bool get wantKeepAlive => true;

  void _projectDroppedOnStateColumn({
    required ProjectModel project,
    required ProjectStateList projectStateList,
  }) async {
    print("DROPPED:");
    print(project);
    print( projectStateList.state);

    if (project.state == projectStateList.state) return;

    try {
      final updatedProject = project.copyWith(state: projectStateList.state);
      await ref.read(projectListProvider.notifier).updateProject(
        project.id!,
        updatedProject,
        newIndex: 0
      );
    } catch (e) {
      showErrorNotification(context, 'Failed to update project: $e');
    }
  }

  final GlobalKey _draggableKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (projects) {
          final projectLists = [
            ProjectStateList(
              state: EProjectState.planned,
              projects: projects.where((p) => p.state == EProjectState.planned).toList(),
            ),
            ProjectStateList(
              state: EProjectState.inProgress,
              projects: projects.where((p) => p.state == EProjectState.inProgress).toList(),
            ),
            ProjectStateList(
              state: EProjectState.finished,
              projects: projects.where((p) => p.state == EProjectState.finished).toList(),
            ),
          ];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: projectLists.map((list) =>
                    _buildStateColumWithDropZone(list, _draggableKey)
                ).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateColumWithDropZone(ProjectStateList projectList, GlobalKey draggableKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 300,
        child: DragTarget<ProjectModel>(
          builder: (context, candidateProjects, rejectedProjects) {
            return ProjectStateColumn(
              hasProjects: projectList.projects.isNotEmpty,
              highlighted: candidateProjects.isNotEmpty,
              projectStateList: projectList,
              draggableKey: draggableKey,
              scrollController: _scrollController,
            );
          },
          onAcceptWithDetails: (details) {
            _projectDroppedOnStateColumn(project: details.data, projectStateList: projectList);
          },
        ),
      ),
    );
  }
}

class ProjectStateColumn extends StatelessWidget {
  const ProjectStateColumn({
    super.key,
    required this.projectStateList,
    required this.draggableKey,
    required this.scrollController,
    this.highlighted = false,
    this.hasProjects = false,
  });

  final ProjectStateList projectStateList;
  final bool highlighted;
  final bool hasProjects;
  final GlobalKey draggableKey;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.getColorByState(projectStateList.state), // Get color based on project state
            width: 4, // Border thickness
          ),
        ),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Material(
        elevation: highlighted ? 8 : 4,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
        color: highlighted ? const Color(0xFFF3F3F3) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getColorByState(projectStateList.state),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  projectStateList.state.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Visibility(
                visible: hasProjects,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${projectStateList.projects.length} project${projectStateList.projects.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _buildProjectList(projectStateList, context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectList(ProjectStateList projectStateList, BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: projectStateList.projects.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = projectStateList.projects[index];
          return _buildProjectItem(project: item, context: context);
        },
      ),
    );
  }

  Widget _buildProjectItem({required ProjectModel project, required BuildContext context}) {
    // Capture the screen width from the current build context.
    final screenWidth = MediaQuery.of(context).size.width;
    DateTime? lastScrollTime;

    return LongPressDraggable<ProjectModel>(
      key: ValueKey(project.id),
      data: project,
      // Auto-scroll while dragging using onDragUpdate.
      onDragUpdate: (details) {
        // final now = DateTime.now();
        // if (lastScrollTime != null && now.difference(lastScrollTime!) < Duration(milliseconds: 50)) {
        //   return;
        // }
        // lastScrollTime = now;
        // Define a threshold in pixels near the left/right edge.
        const edgeThreshold = 65.0;
        // Define how much to scroll per update.
        const scrollSpeed = 15.0;

        // Scroll left if pointer is near the left edge.
        if (details.globalPosition.dx < edgeThreshold &&
            scrollController.offset > 0) {
          scrollController.jumpTo(scrollController.offset - scrollSpeed);
        }
        // Scroll right if pointer is near the right edge.
        else if (details.globalPosition.dx > screenWidth - edgeThreshold &&
            scrollController.offset < scrollController.position.maxScrollExtent) {
          scrollController.jumpTo(scrollController.offset + scrollSpeed);
        }
      },
      feedback: SizedBox(
        width: 200,
        height: 100,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                project.name,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ),

      // (Optional) hide the original item in the list while dragging
      childWhenDragging: const SizedBox.shrink(),

      child: ProjectListItem(project: project),
    );
  }
}

class ProjectListItem extends StatelessWidget {
  const ProjectListItem({
    super.key,
    required this.project
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    project.customer.name,
                    style: theme.textTheme.bodySmall
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}