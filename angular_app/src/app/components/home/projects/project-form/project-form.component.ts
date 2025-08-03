import {Component, effect, Inject, input, model, OnInit, output, signal, Signal} from '@angular/core';
import {ProjectModel} from '../../../../models/project.model';
import {FormBuilder, FormGroup, ReactiveFormsModule, Validators} from '@angular/forms';
import {EProjectState, getStateLabel} from '../../../../enums/e-project-state';
import {CustomerService} from '../../../../services/customer.service';
import {MatFormFieldModule} from '@angular/material/form-field';
import {MatInput} from '@angular/material/input';
import {MatSelectModule} from '@angular/material/select';
import {MatCheckbox} from '@angular/material/checkbox';
import {KeyValuePipe} from '@angular/common';
import {MatDatepicker, MatDatepickerInput, MatDatepickerToggle} from '@angular/material/datepicker';
import {MatButton} from '@angular/material/button';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {CUSTOMER_DATA, ICustomerDataProvider} from '../../../../services/providers/customers.provider';

@Component({
  selector: 'app-project-form',
  imports: [
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInput,
    MatSelectModule,
    MatCheckbox,
    KeyValuePipe,
    MatDatepickerInput,
    MatDatepickerToggle,
    MatDatepicker,
    MatButton,
    MatProgressSpinner
  ],
  templateUrl: './project-form.component.html',
  standalone: true,
  styleUrl: './project-form.component.sass'
})
export class ProjectFormComponent implements OnInit {
  project = input<ProjectModel|undefined>(undefined)
  loading = model<boolean>(false)

  formGroupOutput = output<FormGroup>()
  formGroup = signal<FormGroup|undefined>(undefined)

  readonly states = Object.values(EProjectState)

  constructor(
    private formBuilder: FormBuilder,
    @Inject(CUSTOMER_DATA) public customerService: ICustomerDataProvider
  ) {
    effect(() => {
      if(this.formGroup())
        this.formGroupOutput.emit(this.formGroup()!)
    })

    if(!this.customerService.customers())
      this.customerService.getAll()
  }

  ngOnInit(): void {
    this.formGroup.set(this.formBuilder.group({
      name: [this.project()?.name, Validators.required],
      description: [this.project()?.description],
      state: [this.project()?.state ?? EProjectState.PLANNED, Validators.required],
      isPublic: [this.project()?.isPublic ?? false],
      customer: [this.project()?.customer, Validators.required],
      budget: [this.project()?.budget],
      estimatedHours: [this.project()?.estimatedHours],
      startDate: [this.project()?.startDate, Validators.required],
      endDate: [this.project()?.endDate, Validators.required]
    }))
  }

  protected readonly getStateLabel = getStateLabel;
  protected readonly EProjectState = EProjectState;
}
