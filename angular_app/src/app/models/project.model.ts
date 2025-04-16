import {EProjectState} from '../enums/e-project-state';
import {CustomerModel} from './customer.model';

export interface ProjectModel {
  id?: number
  name: string
  description?: string
  state: EProjectState
  isPublic: boolean
  startDate: string
  endDate: string
  budget?: number
  estimatedHours?: number
  customer: CustomerModel
  customerId?: number
  index: number
}

export interface ProjectStateList {
  state: EProjectState
  projects: ProjectModel[]
}
