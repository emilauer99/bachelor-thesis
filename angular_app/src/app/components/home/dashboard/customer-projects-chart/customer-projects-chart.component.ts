import {Component, computed, input, ViewChild} from '@angular/core';
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
      <div class="chart-scrollable">
        <div class="chart-inner" [style.min-width.px]="chartWidth()">
          <canvas
            #chart
            baseChart
            [data]="chartData()"
            [options]="barChartOptions"
            [type]="barChartType"
            [style.width.px]="chartWidth()"
            style="height: 300px;"
          >
          </canvas>
        </div>
      </div>

    } @else {
      <p>No projects found</p>
    }
  `,
  styles: `
    .chart-scrollable
      overflow-x: auto

    .chart-inner
      height: 100%

    canvas
      display: block
  `
})
export class CustomerProjectsChartComponent {
  projects = input<ProjectModel[] | undefined>();

  private readonly barWidth = 40;
  private readonly groupSpacing = 10;

  chartData = computed(() => {
    const projs = this.projects() || [];
    const counts: { [key: string]: number } = {};
    projs.forEach(p => counts[p.customer.name] = (counts[p.customer.name] || 0) + 1);
    const labels = Object.keys(counts);
    return {
      labels,
      datasets: [{
        data: labels.map(l => counts[l]),
        label: 'Projects',
        backgroundColor: 'rgba(63,81,181,0.7)',
        barThickness: this.barWidth
      }]
    } as ChartData<'bar'>;
  });

  chartWidth = computed(() => {
    const labels = this.chartData().labels as string[];
    return labels.length * (this.barWidth + this.groupSpacing) + 50;
  });

  public barChartOptions: ChartOptions<'bar'> = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: {
        ticks: { autoSkip: false },
      },
      y: { beginAtZero: true }
    },
  };
  public barChartType: 'bar' = 'bar';
}
