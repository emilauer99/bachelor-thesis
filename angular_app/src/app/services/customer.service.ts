import {Injectable, signal} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {environment} from '../../environments/environment';
import {finalize, Observable, tap} from 'rxjs';
import {CustomerModel} from '../models/customer.model';

@Injectable({
  providedIn: 'root'
})
export class CustomerService {
  customers = signal<CustomerModel[]|undefined>(undefined)
  loading = signal<boolean>(false)

  constructor(private http: HttpClient) { }

  getAll(): void {
    this.loading.set(true)
    this.http.get<CustomerModel[]>(environment.apiUrl + '/customers')
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (customers) => {
          this.customers.set(customers)
        }
      })
  }

  delete(id: number): Observable<any> {
    return this.http
      .delete<any>(environment.apiUrl + `/customers/${id}`)
      .pipe(
        tap({
          next: () => {
            this.customers.update((currentCustomers) => {
              return currentCustomers?.filter(c => c.id != id)
            })
          },
        }),
      );
  }
}
