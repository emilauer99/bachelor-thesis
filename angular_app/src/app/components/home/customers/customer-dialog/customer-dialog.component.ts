import {Component, Inject} from '@angular/core';
import {FormGroup} from '@angular/forms';
import {MAT_DIALOG_DATA, MatDialogRef} from '@angular/material/dialog';
import {DialogComponent} from '../../../utils/dialog/dialog.component';
import {finalize} from 'rxjs';
import {CustomerService} from '../../../../services/customer.service';
import {CustomerModel} from '../../../../models/customer.model';
import {CustomerFormComponent} from '../customer-form/customer-form.component';
import {HttpHeaders} from '@angular/common/http';

@Component({
  selector: 'app-customer-dialog',
  imports: [
    DialogComponent,
    CustomerFormComponent
  ],
  templateUrl: './customer-dialog.component.html',
  standalone: true,
  styleUrl: './customer-dialog.component.sass'
})
export class CustomerDialogComponent {
  loading: boolean = false
  formGroup: FormGroup | undefined

  constructor(
    private customerService: CustomerService,
    public dialogRef: MatDialogRef<DialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: {
      title: string;
      confirmText: string,
    }
  ) {
  }

  onConfirmClicked() {
    this.formGroup!.markAllAsTouched()
    if (this.formGroup!.invalid) return

    this.loading = true
    const data: CustomerModel = {
      ...this.formGroup!.value
    }
    let formData = new FormData();
    formData.append('name', data.name);
    formData.append('image', data.image);
    this.customerService.create(
      formData,
      new HttpHeaders({
        'Content-Type': 'application/x-www-form-urlencoded',
      }),
    )
      .pipe(finalize(() => this.loading = false))
      .subscribe({
        next: (customer: CustomerModel) => {
          this.dialogRef.close(customer)
        }
      })
  }
}
