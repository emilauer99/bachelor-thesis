import {Inject, Injectable, signal} from '@angular/core';
import {HttpClient, HttpHeaders} from '@angular/common/http';
import {environment} from '../../environments/environment';
import {finalize, Observable, tap} from 'rxjs';
import {CustomerModel} from '../models/customer.model';
import {IProjectDataProvider, PROJECT_DATA} from './providers/projects.provider';

@Injectable({
  providedIn: 'root'
})
export class CustomerService {
  customers = signal<CustomerModel[]|undefined>(undefined)
  loading = signal<boolean>(false)

  constructor(private http: HttpClient,
              @Inject(PROJECT_DATA) public projectService: IProjectDataProvider) { }

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

  create(data: any, headers?: HttpHeaders): Observable<CustomerModel> {
    return this.http
      .post<CustomerModel>(environment.apiUrl + '/customers', data, {headers: headers})
      .pipe(
        tap({
          next: (customer) => {
            if(!this.customers())
              return
            this.customers.update((currentCustomers) => {
              return [...currentCustomers!, customer]
            })
          },
        }),
      );
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
            this.projectService.projects.update((currentProjects) => {
              return currentProjects?.filter(p => p.customer.id != id)
            })
          },
        }),
      );
  }
}
