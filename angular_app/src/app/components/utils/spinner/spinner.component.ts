import { Component } from '@angular/core';
import {MatProgressSpinner} from '@angular/material/progress-spinner';

@Component({
  selector: 'app-spinner',
  imports: [
    MatProgressSpinner
  ],
  template: `
    <div style="height: 40px" class="d-flex justify-content-center" >
      <mat-progress-spinner mode="indeterminate" class="h-100"></mat-progress-spinner>
    </div>
  `,
  standalone: true,
  styles: []
})
export class SpinnerComponent {

}
