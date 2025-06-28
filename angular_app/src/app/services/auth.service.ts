import {effect, Injectable, signal, WritableSignal} from '@angular/core';
import {UserModel} from '../models/user.model';
import {HttpClient} from '@angular/common/http';
import {environment} from '../../environments/environment';
import {Observable, tap} from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  user: WritableSignal<UserModel | null>

  constructor(private http: HttpClient) {
    this.user = signal(JSON.parse(localStorage.getItem('user') ?? 'null'))

    effect(() => {
      if (this.user()) {
        localStorage.setItem('user', JSON.stringify(this.user()!))
      } else
        localStorage.removeItem('user')
    });
  }

  public login(email: string, password: string) {
    return this.http.post<{token: string}>(environment.apiUrl + '/login', {
      email,
      password
    })
      .pipe(
        tap((response: any) => {
          this.user.set(response);
        })
      );
  }

  public logout(): Observable<any> {
    return this.http.post<any>(environment.apiUrl + '/logout', {})
      .pipe(
        tap(() => {
          this.user.set(null)
        })
      )
  }
}
