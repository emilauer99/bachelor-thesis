import {InjectionToken, WritableSignal} from '@angular/core';
import {Observable} from 'rxjs';
import {UserModel} from '../../models/user.model';

export const AUTH_DATA = new InjectionToken<IAuthDataProvider>(
  'AUTH_DATA'
);

export interface IAuthDataProvider {
  user: WritableSignal<UserModel | null>;

  login(email: string, password: string): Observable<UserModel>
  logout(): Observable<any>
}
