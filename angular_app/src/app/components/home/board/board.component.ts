import {Component, ElementRef, Inject, signal, ViewChild} from '@angular/core';
import {ProjectFiltersComponent} from '../../utils/project-filters/project-filters.component';
import {
  CdkDrag,
  CdkDragDrop, CdkDragMove,
  CdkDropList,
  CdkDropListGroup,
  moveItemInArray,
  transferArrayItem
} from '@angular/cdk/drag-drop';
import {SpinnerComponent} from '../../utils/spinner/spinner.component';
import {EProjectState} from '../../../enums/e-project-state';
import {CustomNotificationService} from '../../../services/custom-notification.service';
import {ProjectModel, ProjectStateList} from '../../../models/project.model';
import {TitleCasePipe} from '@angular/common';
import {finalize} from 'rxjs';
import {IProjectDataProvider, PROJECT_DATA} from '../../../services/providers/projects.provider';
import {MatButton} from '@angular/material/button';
import {MatIcon} from '@angular/material/icon';

@Component({
  selector: 'app-board',
  imports: [
    ProjectFiltersComponent,
    CdkDropList,
    SpinnerComponent,
    CdkDrag,
    TitleCasePipe,
    CdkDropListGroup,
    MatButton,
    MatIcon
  ],
  templateUrl: './board.component.html',
  styleUrl: './board.component.sass'
})
export class BoardComponent {
  customerFilterId: number | null = null;
  currentlyLoadingIds = signal<number[]>([])

  constructor(
    @Inject(PROJECT_DATA) public projectService: IProjectDataProvider,
    private notificationService: CustomNotificationService,
  ) {
    if (!this.projectService.projects()) {
      this.projectService.getAll();
    }
  }

  @ViewChild('scrollContainer') scrollContainer!: ElementRef<HTMLElement>;

  // Add this to your component
  onDragMoved(event: CdkDragMove<ProjectModel>) {
    console.log(event)
    const scrollContainer = this.scrollContainer.nativeElement;
    const { left, right } = scrollContainer.getBoundingClientRect();
    const pointerPosition = event.pointerPosition.x;
    const scrollThreshold = 50; // Pixels from edge to start scrolling
    const scrollSpeed = 10; // Pixels per frame

    // Scroll right if dragging near right edge
    console.log(pointerPosition, right - scrollThreshold)
    if (pointerPosition > right - scrollThreshold) {
      scrollContainer.scrollLeft += scrollSpeed;
    }
    // Scroll left if dragging near left edge
    else if (pointerPosition < left + scrollThreshold) {
      scrollContainer.scrollLeft -= scrollSpeed;
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

  setStateOfAll(state: EProjectState) {
    this.projectService.setStateOfAll(state)
      .subscribe({
          next: () => {
            // this.notificationService.success("All projects set to finished.");
          },
          error: () => {
            this.notificationService.error("Failed to set all projects to finished.");
          }
        }
      )
  }

  protected readonly EProjectState = EProjectState;
}
