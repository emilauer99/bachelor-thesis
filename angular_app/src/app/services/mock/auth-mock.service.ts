import {effect, Injectable, signal, WritableSignal} from '@angular/core';
import {Observable, of, throwError, delay, tap} from 'rxjs';
import mockUsers from '../../mocks/users.json';
import {UserModel} from '../../models/user.model';

@Injectable({
  providedIn: 'root'
})
export class AuthMockService {
  user: WritableSignal<UserModel | null>;

  constructor() {
    this.user = signal(JSON.parse(localStorage.getItem('user') ?? 'null'));

    effect(() => {
      if (this.user()) {
        localStorage.setItem('user', JSON.stringify(this.user()!));
      } else {
        localStorage.removeItem('user');
      }
    });
  }

  public login(email: string, password: string): Observable<UserModel> {
    const users: UserModel[] = mockUsers as any;
    const found = users.find(u => u.email === email && u.password === password);
    if (!found) {
      return throwError(() => new Error('Invalid credentials (mock)'));
    }

    const user: UserModel = {
      id: found.id,
      email: found.email,
      role: found.role,
      token: found.token
    }

    this.user.set(user)
    return of(user)
  }

  public logout(): Observable<any> {
    this.user.set(null)
    return of(null)
  }
}
