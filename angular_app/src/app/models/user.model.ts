import {EUserRole} from '../enums/e-user-role';

export interface UserModel {
  id: number
  email: string
  token?: string
  role: EUserRole
}
