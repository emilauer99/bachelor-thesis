import { Component, computed, input } from '@angular/core';
import { BaseChartDirective } from 'ng2-charts';
import { ProjectModel } from '../../../../models/project.model';
import { ChartOptions } from 'chart.js';
import 'chart.js/auto';
import { EProjectState } from '../../../../enums/e-project-state';

@Component({
  selector: 'app-status-projects-chart',
  standalone: true,
  imports: [BaseChartDirective],
  template: `
    @if(chartData().labels.length) {
      <div class="d-flex justify-content-center">
        <div style="max-height: 300px">
          <canvas baseChart
                  [data]="chartData()"
                  [options]="pieChartOptions"
                  [type]="pieChartType">
          </canvas>
        </div>
      </div>
    } @else {
      <p>No projects found</p>
    }
  `
})
export class StatusProjectsChartComponent {
  projects = input<ProjectModel[] | undefined>();

  chartData = computed(() => {
    const projects = this.projects();
    if (!projects || projects.length === 0) {
      return { labels: [], datasets: [] };
    }

    const counts: { [key in EProjectState]?: number } = {};
    projects.forEach(project => {
      counts[project.state] = (counts[project.state] || 0) + 1;
    });

    const labels = Object.keys(counts);
    const data = Object.values(counts);
    const total = data.reduce((sum, value) => sum + value, 0);

    const labelsWithPercentage = labels.map((label, index) => {
      const percentage = ((data[index] / total) * 100).toFixed(1);
      return `${label} (${percentage}%)`;
    });

    const statusColors: { [key in EProjectState]: string } = {
      [EProjectState.PLANNED]: '#2196F3',
      [EProjectState.IN_PROGRESS]: '#FF9800',
      [EProjectState.FINISHED]: '#4CAF50'
    };
    const backgroundColors = labels.map(label => statusColors[label as EProjectState] || '#CCCCCC');

    return {
      labels: labelsWithPercentage,
      datasets: [{
        data: data,
        backgroundColor: backgroundColors,
      }]
    };
  });

  public pieChartOptions: ChartOptions<'pie'> = {
    responsive: true,
    maintainAspectRatio: false
  };
  public pieChartType: 'pie' = 'pie';
}
