import {Component, input, output} from '@angular/core';
import {MatDialogModule, MatDialogRef} from '@angular/material/dialog';
import {MatButtonModule} from '@angular/material/button';
import {MatProgressSpinner} from '@angular/material/progress-spinner';

@Component({
  selector: 'app-dialog',
  standalone: true,
  template: `
    <h2 mat-dialog-title>{{ title() }}</h2>
    <mat-dialog-content>
      <div class="py-2">
        <ng-content></ng-content>
      </div>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close(false)">Cancel</button>
      <button mat-button color="warn" (click)="confirmClicked.emit()">
        @if(loading()) {
          <mat-progress-spinner diameter="20" mode="indeterminate"></mat-progress-spinner>
        } @else {
          <span>{{ confirmText() }}</span>
        }
      </button>
    </mat-dialog-actions>
  `,
  imports: [MatDialogModule, MatButtonModule, MatProgressSpinner]
})
export class DialogComponent {
  confirmClicked = output();
  loading = input(false);
  title = input('');
  confirmText = input('Confirm');

  constructor(
    public dialogRef: MatDialogRef<DialogComponent>
  ) {
  }
}
