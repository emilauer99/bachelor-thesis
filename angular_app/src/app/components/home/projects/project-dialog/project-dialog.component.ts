import {Component, Inject} from '@angular/core';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material/dialog';
import {DialogComponent} from '../../../utils/dialog/dialog.component';
import {ProjectModel} from '../../../../models/project.model';
import {ProjectFormComponent} from '../project-form/project-form.component';
import {FormGroup} from '@angular/forms';
import {ProjectService} from '../../../../services/project.service';
import {finalize} from 'rxjs';
import {DatePipe} from '@angular/common';

@Component({
  selector: 'app-project-dialog',
  imports: [
    DialogComponent,
    ProjectFormComponent
  ],
  templateUrl: './project-dialog.component.html',
  standalone: true,
  styleUrl: './project-dialog.component.sass'
})
export class ProjectDialogComponent {
  loading: boolean = false
  formGroup: FormGroup | undefined

  constructor(
    private projectService: ProjectService,
    private datePipe: DatePipe,
    public dialogRef: MatDialogRef<DialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: {
      title: string;
      project?: ProjectModel;
      confirmText: string,
    }
  ) {}

  onConfirmClicked() {
    this.formGroup!.markAllAsTouched()
    if (this.formGroup!.invalid) return

    this.loading = true
    const data: ProjectModel = {
      ...this.data.project,
      ...this.formGroup!.value,
      startDate: this.datePipe.transform(this.formGroup!.value.startDate, 'yyyy-MM-dd'),
      endDate: this.datePipe.transform(this.formGroup!.value.endDate, 'yyyy-MM-dd'),
    }
    if(this.data.project) {
      // do update
      this.projectService.update(this.data.project.id!, data)
        .pipe(finalize(() => this.loading = false))
        .subscribe({
          next: (project: ProjectModel) => {
            this.dialogRef.close(project)
          }
        })
    } else {
      // do create
      this.projectService.create(data)
        .pipe(finalize(() => this.loading = false))
        .subscribe({
          next: (project: ProjectModel) => {
            this.dialogRef.close(project)
          }
        })
    }
  }
}
