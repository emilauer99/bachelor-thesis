import {InjectionToken, WritableSignal} from '@angular/core';
import {HttpHeaders} from '@angular/common/http';
import {Observable} from 'rxjs';
import {CustomerModel} from '../../models/customer.model';

export const CUSTOMER_DATA = new InjectionToken<ICustomerDataProvider>(
  'CUSTOMER_DATA'
);

export interface ICustomerDataProvider {
  customers: WritableSignal<CustomerModel[] | undefined>;
  loading:  WritableSignal<boolean>;

  getAll(): void;
  create(data: any, headers?: HttpHeaders): Observable<CustomerModel>;
  delete(id: number): Observable<any>;
}
