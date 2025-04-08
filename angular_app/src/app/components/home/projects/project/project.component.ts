import {Component, effect, signal} from '@angular/core';
import {ProjectModel} from '../../../../models/project.model';
import {ProjectService} from '../../../../services/project.service';
import {CustomNotificationService} from '../../../../services/custom-notification.service';
import {Router} from '@angular/router';
import {MatDialog} from '@angular/material/dialog';
import {ConfirmDialogComponent} from '../../../utils/confirm-dialog/confirm-dialog.component';
import {MatToolbar} from '@angular/material/toolbar';
import {MatChip} from '@angular/material/chips';
import {getStateColor, getStateLabel} from '../../../../enums/e-project-state';
import {DatePipe} from '@angular/common';
import {MatDivider} from '@angular/material/divider';
import {MatCard, MatCardContent, MatCardHeader, MatCardTitle} from '@angular/material/card';
import {MatIconButton} from '@angular/material/button';
import {MatIcon} from '@angular/material/icon';
import {SpinnerComponent} from '../../../utils/spinner/spinner.component';
import {ProjectDialogComponent} from '../project-dialog/project-dialog.component';
import {finalize} from 'rxjs';
import {MatProgressSpinner} from '@angular/material/progress-spinner';

@Component({
  selector: 'app-project',
  imports: [
    MatToolbar,
    MatIconButton,
    MatIcon,
    MatChip,
    DatePipe,
    MatDivider,
    MatCardTitle,
    MatCard,
    SpinnerComponent,
    MatCardHeader,
    MatCardContent,
    MatProgressSpinner
  ],
  templateUrl: './project.component.html',
  standalone: true,
  styleUrl: './project.component.sass'
})
export class ProjectComponent {
  project = signal<ProjectModel|undefined>(undefined)
  projectId: number
  deleteLoading: boolean = false

  constructor(
    private projectService: ProjectService,
    private notificationService: CustomNotificationService,
    private router: Router,
    private dialog: MatDialog
  ) {
    const currentUrl = this.router.url;
    const urlSegments = currentUrl.split('/');
    this.projectId = +urlSegments[urlSegments.length - 1];

    effect(() => {
      if(this.project())
        return

      if(!this.projectService.projects())
        return

      const project = this.projectService.projects()?.find(p => p.id === this.projectId)
      if(!project) {
        this.notificationService.error("Project not found.")
        this.router.navigate(['/projects'])
        return;
      }
      this.project.set(project)
    });
  }

  confirmDelete(): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Delete Project',
        message: `Are you sure you want to delete "${this.project()!.name}"?`,
        confirmText: 'Delete'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.deleteLoading = true
        this.projectService.delete(this.project()!.id!)
          .pipe(finalize(() => this.deleteLoading = false))
          .subscribe({
          next: () => {
            this.notificationService.success(`Project "${this.project()!.name}" deleted`);
            this.router.navigate(['/projects'])
          },
          error: () => {
            this.notificationService.error(`Failed to delete "${this.project()!.name}"`);
          }
        });
      }
    });
  }

  editProject(): void {
    const dialogRef = this.dialog.open(ProjectDialogComponent, {
      data: {
        title: 'Update Project',
        confirmText: 'Update',
        project: this.project(),
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.notificationService.success("Project was updated.");
      }
    });
  }

  protected readonly getStateLabel = getStateLabel;
  protected readonly getStateColor = getStateColor;
}
