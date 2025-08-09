import {InjectionToken, Signal, WritableSignal} from '@angular/core';
import {HttpHeaders} from '@angular/common/http';
import {Observable} from 'rxjs';
import {ProjectModel} from '../../models/project.model';
import {EProjectState} from '../../enums/e-project-state';

export const PROJECT_DATA = new InjectionToken<IProjectDataProvider>(
  'PROJECT_DATA'
);

export interface IProjectDataProvider {
  projects: WritableSignal<ProjectModel[] | undefined>;
  loading:  WritableSignal<boolean>;

  getAll(): void;
  create(data: any, headers?: HttpHeaders): Observable<ProjectModel>;
  update(id: number, data: any, preventListUpdate?: boolean): Observable<ProjectModel>;
  setStateOfAll(state: EProjectState): Observable<any>;
  delete(id: number): Observable<any>;
}
