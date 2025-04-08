import {Component} from '@angular/core';
import {ProjectService} from '../../../services/project.service';
import {ProjectModel} from '../../../models/project.model';
import {MatList, MatListItem} from '@angular/material/list';
import {EProjectState, getStateColor} from '../../../enums/e-project-state';
import {MatButton, MatFabButton, MatIconButton} from '@angular/material/button';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {MatIcon} from '@angular/material/icon';
import {CustomNotificationService} from '../../../services/custom-notification.service';
import {MatDialog} from '@angular/material/dialog';
import {ConfirmDialogComponent} from '../../utils/confirm-dialog/confirm-dialog.component';
import {SpinnerComponent} from '../../utils/spinner/spinner.component';
import {RouterLink} from '@angular/router';
import {ProjectDialogComponent} from './project-dialog/project-dialog.component';

@Component({
  selector: 'app-projects',
  imports: [
    MatButton,
    MatProgressSpinner,
    MatList,
    MatListItem,
    MatFabButton,
    MatIcon,
    MatIconButton,
    SpinnerComponent,
    RouterLink
  ],
  templateUrl: './projects.component.html',
  standalone: true,
  styleUrl: './projects.component.sass'
})
export class ProjectsComponent {
  constructor(public projectService: ProjectService,
              private notificationService: CustomNotificationService,
              private dialog: MatDialog) {
  }

  showStateTooltip(state: EProjectState): void {
    let tooltip = '';
    switch (state) {
      case EProjectState.PLANNED:
        tooltip = 'Planned Project\nThis project is in the planning phase and hasn\'t started yet.';
        break;
      case EProjectState.IN_PROGRESS:
        tooltip = 'Project in Progress\nThis project is currently being worked on by the team.';
        break;
      case EProjectState.FINISHED:
        tooltip = 'Completed Project\nThis project has been successfully finished.';
        break;
    }
    this.notificationService.success(tooltip, state)
  }

  confirmDelete(project: ProjectModel): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Delete Project',
        message: `Are you sure you want to delete "${project.name}"?`,
        confirmText: 'Delete'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.projectService.delete(project.id!).subscribe({
          next: () => {
            this.notificationService.success(`Project "${project.name}" deleted`);
          },
          error: () => {
            this.notificationService.error(`Failed to delete "${project.name}"`);
          }
        });
      }
    });
  }

  createProject(): void {
    const dialogRef = this.dialog.open(ProjectDialogComponent, {
      data: {
        title: 'Create Project',
        confirmText: 'Create'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.notificationService.success("Project was created.");
      }
    });
  }

  protected readonly getStateColor = getStateColor;
}
