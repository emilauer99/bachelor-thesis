import {Component, input, output} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { ProjectModel } from '../../../models/project.model';
import { EProjectState } from '../../../enums/e-project-state';

@Component({
  selector: 'app-project-filters',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatSelectModule
  ],
  template: `
    <div class="d-flex flex-column gap-3">
      @if (projects() && projects()!.length) {
        <div class="d-flex gap-3">
          <mat-form-field appearance="outline" class="flex-fill">
            <mat-label>Customer Filter</mat-label>
            <mat-select [formControl]="customerControl">
              <mat-option [value]="null">All Customers</mat-option>
              <mat-option *ngFor="let customer of uniqueCustomers" [value]="customer.id">
                {{ customer.name }}
              </mat-option>
            </mat-select>
          </mat-form-field>

          @if (!hideStatusFilter()) {
            <mat-form-field appearance="outline" class="flex-fill">
              <mat-label>Status Filter</mat-label>
              <mat-select [formControl]="stateControl">
                <mat-option [value]="null">All States</mat-option>
                <mat-option *ngFor="let state of states" [value]="state">
                  {{ state }}
                </mat-option>
              </mat-select>
            </mat-form-field>
          }
        </div>
      }
    </div>
  `
})
export class ProjectFiltersComponent {
  projects = input<ProjectModel[] | undefined>();
  hideStatusFilter = input<boolean>(false)
  customerFilterChange = output<number | null>();
  stateFilterChange = output<EProjectState | null>();

  customerControl = new FormControl(null);
  stateControl = new FormControl(null);

  states = Object.values(EProjectState);

  get uniqueCustomers() {
    if (!this.projects) return [];
    const map: { [id: number]: any } = {};
    this.projects()?.forEach(project => {
      map[project.customer.id!] = project.customer;
    });
    return Object.values(map);
  }

  constructor() {
    this.customerControl.valueChanges.subscribe(value => {
      this.customerFilterChange.emit(value);
    });
    this.stateControl.valueChanges.subscribe(value => {
      this.stateFilterChange.emit(value);
    });
  }
}
