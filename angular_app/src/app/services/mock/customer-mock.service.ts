import {Injectable, signal} from '@angular/core';
import {HttpHeaders} from '@angular/common/http';
import {Observable, of} from 'rxjs';
import rawCustomersData from '../../mocks/customers.json';
import {CustomerModel} from '../../models/customer.model';
import {ICustomerDataProvider} from '../providers/customers.provider';

export const customersData: CustomerModel[] = (rawCustomersData as any[]).map((c, i) => ({
  id:             c.id,
  name:           c.name,
  imagePath:      c.imagePath,
}))

@Injectable({ providedIn: 'root' })
export class CustomerMockService implements ICustomerDataProvider {
  customers = signal<CustomerModel[]>([...customersData])
  loading = signal<boolean>(false)

  getAll(): void {
    this.loading.set(true)
    // setTimeout(() => {
      this.customers.set([...customersData])
      this.loading.set(false)
    // }, 300);
  }

  create(data: any, headers?: HttpHeaders): Observable<CustomerModel> {
    const newCustomer: CustomerModel = {
      id: this.generateId(),
      ...data,
    };
    this.customers.update(current => [...current, newCustomer]);
    return of(newCustomer);
  }

  update(
    id: number,
    data: any,
    preventListUpdate: boolean = false
  ): Observable<CustomerModel> {
    const updated: CustomerModel = { id, ...data };
    if (!preventListUpdate) {
      this.customers.update(current =>
        current.map(c => (c.id === id ? updated : c))
      );
    }
    return of(updated);
  }

  delete(id: number): Observable<any> {
    this.customers.update(current => current.filter(c => c.id !== id));
    return of(null);
  }

  private generateId(): number {
    const current = this.customers();
    return current.length
      ? Math.max(...current.map(c => c.id!)) + 1
      : 1;
  }
}

