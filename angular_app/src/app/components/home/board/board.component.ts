import {Component, signal} from '@angular/core';
import {ProjectFiltersComponent} from '../../utils/project-filters/project-filters.component';
import {
  CdkDrag,
  CdkDragDrop,
  CdkDropList,
  CdkDropListGroup, DragDrop,
  moveItemInArray,
  transferArrayItem
} from '@angular/cdk/drag-drop';
import {SpinnerComponent} from '../../utils/spinner/spinner.component';
import {EProjectState} from '../../../enums/e-project-state';
import {ProjectService} from '../../../services/project.service';
import {CustomNotificationService} from '../../../services/custom-notification.service';
import {ProjectModel, ProjectStateList} from '../../../models/project.model';
import {TitleCasePipe} from '@angular/common';
import {finalize} from 'rxjs';

@Component({
  selector: 'app-board',
  imports: [
    ProjectFiltersComponent,
    CdkDropList,
    SpinnerComponent,
    CdkDrag,
    TitleCasePipe,
    CdkDropListGroup
  ],
  templateUrl: './board.component.html',
  styleUrl: './board.component.sass'
})
export class BoardComponent {
  customerFilterId: number | null = null;
  currentlyLoadingIds = signal<number[]>([])

  constructor(
    public projectService: ProjectService,
    private notificationService: CustomNotificationService,
  ) {
    if (!this.projectService.projects()) {
      this.projectService.getAll();
    }
  }

  get filteredProjects(): ProjectModel[] {
    const projects = this.projectService.projects() || [];
    return projects.filter(p => {
      let customerOk = true;
      if (this.customerFilterId != null) {
        customerOk = p.customer.id === this.customerFilterId;
      }
      return customerOk
    });
  }

  getProjectStateList(state: EProjectState): ProjectStateList {
    const filtered = this.filteredProjects;
    const projects = filtered.filter(p => p.state === state)
      .sort((a, b) => a.index - b.index)
    return { state, projects };
  }

  getColor(state: EProjectState): string {
    switch (state) {
      case EProjectState.PLANNED:
        return '#2196F3'
      case EProjectState.IN_PROGRESS:
        return '#FF9800'
      case EProjectState.FINISHED:
        return '#4CAF50'
      default:
        return '#CCCCCC'
    }
  }

  drop(event: CdkDragDrop<ProjectModel[]>, targetState: EProjectState): void {
    const project = event.item.data as ProjectModel;

    if (event.previousContainer === event.container) {
      moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);
      this.updateIndexesForColumn(event.container.data);
    } else {
      transferArrayItem(
        event.previousContainer.data,
        event.container.data,
        event.previousIndex,
        event.currentIndex
      );
      project.state = targetState;
      this.updateIndexesForColumn(event.previousContainer.data);
      this.updateIndexesForColumn(event.container.data);

      this.currentlyLoadingIds.update((ids) => {
        return [...ids, project.id!]
      })
      this.projectService.update(project.id!, project, true)
        .pipe(
          finalize(() => {
            this.currentlyLoadingIds.update((ids) => {
              return ids.filter(i => i !== project.id)
            })
          })
        )
        .subscribe({
          next: () => {
            // this.notificationService.success(`Project "${project.name}" updated`);
          },
          error: (err) => {
            // Revert on error
            const revertedProjects = this.projectService.projects()!.map(p =>
              p.id === project.id ? project : p
            );
            this.projectService.projects.set(revertedProjects);
            this.notificationService.error(`Failed to update project: ${err}`);
          }
        });
    }
  }

  private updateIndexesForColumn(projects: ProjectModel[]): void {
    projects.forEach((p, index) => {
      p.index = index;
      this.projectService.projects.update((proj) => {
        return proj?.map(pr => pr.id === p.id ? p : pr)
      })
    });
  }

  isLoading(project: ProjectModel) {
    return this.currentlyLoadingIds().find(i => i === project.id) !== undefined
  }

  protected readonly EProjectState = EProjectState;
}
