export enum EProjectState {
  PLANNED = "planned",
  IN_PROGRESS = "inProgress",
  FINISHED = "finished",
}

export function getStateColor(state: EProjectState): string {
  switch (state) {
    case EProjectState.PLANNED:
      return '#2196F3';
    case EProjectState.IN_PROGRESS:
      return '#FF9800';
    case EProjectState.FINISHED:
      return '#4CAF50';
    default:
      return '#000';
  }
}

export function getStateLabel(state: EProjectState): string {
  switch (state) {
    case EProjectState.PLANNED: return 'Planned';
    case EProjectState.IN_PROGRESS: return 'In Progress';
    case EProjectState.FINISHED: return 'Finished';
  }
}
