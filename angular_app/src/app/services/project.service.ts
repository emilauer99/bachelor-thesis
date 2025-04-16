import {Injectable, signal} from '@angular/core';
import {ProjectModel} from '../models/project.model';
import {HttpClient, HttpHeaders} from '@angular/common/http';
import {environment} from '../../environments/environment';
import {finalize, Observable, tap} from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ProjectService {
  projects = signal<ProjectModel[]|undefined>(undefined)
  loading = signal<boolean>(false)

  constructor(private http: HttpClient) {}

  getAll(): void {
    this.loading.set(true)
    this.http.get<ProjectModel[]>(environment.apiUrl + '/projects')
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (projects) => {
          this.projects.set(projects)
        }
      })
  }

  create(data: any, headers?: HttpHeaders): Observable<ProjectModel> {
    return this.http
      .post<ProjectModel>(environment.apiUrl + '/projects', data, {headers: headers})
      .pipe(
        tap({
          next: (project) => {
            if(!this.projects())
              return
            this.projects.update((currentProjects) => {
              return [...currentProjects!, project]
            })
          },
        }),
      );
  }

  update(id: number, data: any, preventListUpdate: boolean = false): Observable<ProjectModel> {
    return this.http
      .put<ProjectModel>(environment.apiUrl + `/projects/${id}`, data)
      .pipe(
        tap({
          next: (project: ProjectModel) => {
            if(preventListUpdate)
              return
            this.projects.update((currentProjects) => {
              return currentProjects?.map(p => p.id == id ? project : p)
            })
          },
        }),
      );
  }

  delete(id: number): Observable<any> {
    return this.http
      .delete<any>(environment.apiUrl + `/projects/${id}`)
      .pipe(
        tap({
          next: () => {
            this.projects.update((currentProjects) => {
              return currentProjects?.filter(p => p.id != id)
            })
          },
        }),
      );
  }
}
