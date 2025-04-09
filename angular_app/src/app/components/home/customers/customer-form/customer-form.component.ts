import {Component, effect, model, output, signal} from '@angular/core';
import {FormBuilder, FormGroup, ReactiveFormsModule, Validators} from '@angular/forms';
import {KeyValuePipe} from '@angular/common';
import {MatCheckbox} from '@angular/material/checkbox';
import {MatDatepicker, MatDatepickerInput, MatDatepickerToggle} from '@angular/material/datepicker';
import {MatError, MatFormField, MatInput, MatLabel, MatSuffix} from '@angular/material/input';
import {MatButton} from '@angular/material/button';

@Component({
  selector: 'app-customer-form',
  imports: [
    KeyValuePipe,
    MatCheckbox,
    MatDatepicker,
    MatDatepickerInput,
    MatDatepickerToggle,
    MatError,
    MatFormField,
    MatInput,
    MatLabel,
    MatSuffix,
    ReactiveFormsModule,
    MatFormField,
    MatButton
  ],
  templateUrl: './customer-form.component.html',
  standalone: true,
  styleUrl: './customer-form.component.sass'
})
export class CustomerFormComponent {
  loading = model<boolean>(false)

  formGroupOutput = output<FormGroup>()
  formGroup = signal<FormGroup|undefined>(undefined)
  previewUrl = signal<string | undefined>(undefined);

  constructor(
    private formBuilder: FormBuilder
  ) {
    this.formGroup.set(this.formBuilder.group({
      name: [null, Validators.required],
      image: [null, Validators.required]
    }))
    effect(() => {
      if(this.formGroup())
        this.formGroupOutput.emit(this.formGroup()!)
    })
  }

  selectImage(fileInputEvent: any) {
    const file = (fileInputEvent.target as HTMLInputElement)?.files?.[0];
    if (file) {
      this.formGroup()?.get('image')?.setValue(file);
      console.log(this.formGroup()?.value)

      const reader = new FileReader();
      reader.onload = () => {
        this.previewUrl.set(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }
}
