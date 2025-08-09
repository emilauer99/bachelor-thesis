import {Injectable, signal} from '@angular/core';
import {IProjectDataProvider} from '../providers/projects.provider';
import {ProjectModel} from '../../models/project.model';
import {HttpHeaders} from '@angular/common/http';
import {Observable, of} from 'rxjs';
import rawProjectsData from '../../mocks/projects.json';
import {EProjectState} from '../../enums/e-project-state';

export const projectsData: ProjectModel[] = (rawProjectsData as any[]).map((p, i) => ({
  id: p.id,
  index: p.index ?? i,
  name: p.name,
  description: p.description,
  budget: p.budget,
  estimatedHours: p.estimatedHours,
  startDate: p.startDate,
  endDate: p.endDate,
  createdAt: p.createdAt,
  isPublic: p.isPublic,
  // cast string into enum
  state: p.state as EProjectState,
  customer: {
    id: p.customer.id,
    name: p.customer.name,
    imagePath: p.customer.imagePath
  }
}))

@Injectable({providedIn: 'root'})
export class ProjectMockService implements IProjectDataProvider {
  projects = signal<ProjectModel[]>([...projectsData])
  loading = signal<boolean>(false)

  getAll(): void {
    // this.loading.set(true)
    // this.projects.set([...projectsData])
    // this.loading.set(false)
  }

  create(data: any, headers?: HttpHeaders): Observable<ProjectModel> {
    const newProject: ProjectModel = {
      id: this.generateId(),
      ...data,
    };
    this.projects.update(current => [...current, newProject]);
    return of(newProject);
  }

  update(
    id: number,
    data: any,
    preventListUpdate: boolean = false
  ): Observable<ProjectModel> {
    const updated: ProjectModel = {id, ...data};
    if (!preventListUpdate) {
      this.projects.update(current =>
        current.map(p => (p.id === id ? updated : p))
      );
    }
    return of(updated);
  }

  setStateOfAll(state: EProjectState): Observable<any> {
    this.projects.update(current =>
      (current ?? []).map(p => ({ ...p, state }))
    );
    return of(this.projects() ?? []);
  }

  delete(id: number): Observable<any> {
    this.projects.update(current => current.filter(p => p.id !== id));
    return of(null);
  }

  private generateId(): number {
    const current = this.projects();
    return current.length
      ? Math.max(...current.map(p => p.id!)) + 1
      : 1;
  }
}

