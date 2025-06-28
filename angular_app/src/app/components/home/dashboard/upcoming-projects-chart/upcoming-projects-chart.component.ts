import { Component, computed, input } from '@angular/core';
import { ChartOptions } from 'chart.js';
import 'chart.js/auto';
import { ProjectModel } from '../../../../models/project.model';
import { BaseChartDirective } from 'ng2-charts';

@Component({
  selector: 'app-upcoming-projects-chart',
  standalone: true,
  imports: [BaseChartDirective],
  template: `
    @if(chartData().labels.length) {
      <div>
        <canvas baseChart
                [data]="chartData()"
                [options]="lineChartOptions"
                [type]="lineChartType">
        </canvas>
      </div>
    } @else {
      <p>No projects found</p>
    }
  `
})
export class UpcomingProjectsChartComponent {
  projects = input<ProjectModel[] | undefined>();

  chartData = computed(() => {
    const projects = this.projects();
    if (!projects || projects.length === 0) {
      return { labels: [], datasets: [] };
    }

    const now = new Date();
    const startMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);
    const months: string[] = [];
    const counts: number[] = [];

    for (let i = 0; i < 12; i++) {
      const date = new Date(startMonth.getFullYear(), startMonth.getMonth() + i, 1);
      const label = date.toLocaleString('default', { month: 'short', year: 'numeric' });
      months.push(label);
      counts.push(0);
    }

    projects.forEach(project => {
      const startDate = new Date(project.startDate);
      const endDate = new Date(project.endDate);
      for (let i = 0; i < 12; i++) {
        const monthDate = new Date(startMonth.getFullYear(), startMonth.getMonth() + i, 1);
        const endOfMonth = new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 0);
        if (startDate <= endOfMonth && endDate >= monthDate) {
          counts[i]++;
        }
      }
    });

    return {
      labels: months,
      datasets: [{
        data: counts,
        label: 'Projects per Month',
        fill: false,
        borderColor: '#3f51b5',
        tension: 0.4,
      }]
    };
  });

  public lineChartOptions: ChartOptions<'line'> = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: {
        ticks: { autoSkip: false }
      },
      y: { beginAtZero: true }
    }
  };
  public lineChartType: 'line' = 'line';
}
