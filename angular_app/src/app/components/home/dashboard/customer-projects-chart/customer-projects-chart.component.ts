import {Component, computed, input} from '@angular/core';
import {ChartData, ChartOptions} from 'chart.js';
import 'chart.js/auto';
import {ProjectModel} from '../../../../models/project.model';
import {BaseChartDirective} from 'ng2-charts';

@Component({
  selector: 'app-customer-projects-chart',
  standalone: true,
  imports: [
    BaseChartDirective
  ],
  template: `
    @if(projects() && projects()!.length) {
      <canvas baseChart
              [data]="chartData()"
              [options]="barChartOptions"
              [type]="barChartType">
      </canvas>
    } @else {
      <p>No projects found</p>
    }
  `
})
export class CustomerProjectsChartComponent {
  projects = input<ProjectModel[] | undefined>();
  chartData = computed(() => {
    const projects = this.projects();
    if (!projects || projects.length === 0) {
      return { labels: [], datasets: [] };
    }

    const counts: { [customerName: string]: number } = {};
    this.projects()!.forEach(project => {
      const name = project.customer.name;
      counts[name] = (counts[name] || 0) + 1;
    })

    return {
      labels: Object.keys(counts),
      datasets: [{
        data: Object.values(counts),
        label: 'Projects',
        backgroundColor: 'rgba(63,81,181,0.7)'
      }]
    };
  });

  public barChartOptions: ChartOptions<'bar'> = {
    responsive: true,
    scales: {
      x: {},
      y: { beginAtZero: true }
    },
  };
  public barChartType: 'bar' = 'bar';
  public barChartData: ChartData<'bar'> = {
    labels: [],
    datasets: []
  };
}
