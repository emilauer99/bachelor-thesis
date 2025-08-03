import {Component, Inject} from '@angular/core';
import {CustomerService} from '../../../services/customer.service';
import {ProjectModel} from '../../../models/project.model';
import {ConfirmDialogComponent} from '../../utils/confirm-dialog/confirm-dialog.component';
import {MatDialog} from '@angular/material/dialog';
import {CustomerModel} from '../../../models/customer.model';
import {CustomNotificationService} from '../../../services/custom-notification.service';
import {CustomerDialogComponent} from './customer-dialog/customer-dialog.component';
import {MatList, MatListItem} from '@angular/material/list';
import {SpinnerComponent} from '../../utils/spinner/spinner.component';
import {MatButton, MatFabButton, MatIconButton} from '@angular/material/button';
import {MatIcon} from '@angular/material/icon';
import {environment} from '../../../../environments/environment';
import {IProjectDataProvider, PROJECT_DATA} from '../../../services/providers/projects.provider';
import {CUSTOMER_DATA, ICustomerDataProvider} from '../../../services/providers/customers.provider';
import {MobileService} from '../../../services/mobile.service';

@Component({
  selector: 'app-customers',
  imports: [
    MatButton,
    MatIcon,
    MatIconButton,
    MatList,
    MatListItem,
    SpinnerComponent,
    MatFabButton,
  ],
  templateUrl: './customers.component.html',
  standalone: true,
  styleUrl: './customers.component.sass'
})
export class CustomersComponent {
  constructor(@Inject(CUSTOMER_DATA) public customerService: ICustomerDataProvider,
              private notificationService: CustomNotificationService,
              public mobileService: MobileService,
              private dialog: MatDialog) {
    if(!this.customerService.customers())
      this.customerService.getAll()
  }

  confirmDelete(customer: CustomerModel): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Delete Customer',
        message: `Are you sure you want to delete "${customer.name}"? All projects of this customer will be deleted too.`,
        confirmText: 'Delete'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.customerService.delete(customer.id!).subscribe({
          next: () => {
            this.notificationService.success(`Customer "${customer.name}" deleted`);
          },
          error: () => {
            this.notificationService.error(`Failed to delete "${customer.name}"`);
          }
        });
      }
    });
  }

  createCustomer(): void {
    const dialogRef = this.dialog.open(CustomerDialogComponent, {
      data: {
        title: 'Create Customer',
        confirmText: 'Create'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.notificationService.success("Customer was created.");
      }
    });
  }

  protected readonly environment = environment;
}
