import {Component, computed, Inject, signal, ViewChild} from '@angular/core';
import {ProjectService} from '../../../services/project.service';
import {ProjectFiltersComponent} from '../../utils/project-filters/project-filters.component';
import {UpcomingProjectsChartComponent} from './upcoming-projects-chart/upcoming-projects-chart.component';
import {StatusProjectsChartComponent} from './status-projects-chart/status-projects-chart.component';
import {CustomerProjectsChartComponent} from './customer-projects-chart/customer-projects-chart.component';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {SpinnerComponent} from '../../utils/spinner/spinner.component';
import {EProjectState} from '../../../enums/e-project-state';
import {IProjectDataProvider, PROJECT_DATA} from '../../../services/providers/projects.provider';

@Component({
  selector: 'app-dashboard',
  imports: [
    MatProgressSpinner,
    ProjectFiltersComponent,
    UpcomingProjectsChartComponent,
    StatusProjectsChartComponent,
    CustomerProjectsChartComponent,
    SpinnerComponent
  ],
  templateUrl: './dashboard.component.html',
  standalone: true,
  styleUrl: './dashboard.component.sass'
})
export class DashboardComponent {
  customerFilterId = signal<number|undefined|null>(undefined)
  stateFilter = signal<EProjectState|undefined|null>(undefined)
  projects = computed(() => {
    return  this.projectService.projects()?.filter(project => {
      let customerOk = true
      if(this.customerFilterId())
        customerOk = project.customer.id == this.customerFilterId()
      let stateOk = true
      if(this.stateFilter())
        stateOk = project.state == this.stateFilter()

      return customerOk && stateOk
    })
  })

  constructor(@Inject(PROJECT_DATA) public projectService: IProjectDataProvider) {
    if(!this.projectService.projects())
      this.projectService.getAll()
  }
}
