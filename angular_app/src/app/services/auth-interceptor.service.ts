import {Inject, Injectable} from '@angular/core';
import {
  HttpErrorResponse,
  HttpEvent,
  HttpHandler,
  HttpHeaders,
  HttpInterceptor,
  HttpRequest
} from '@angular/common/http';
import {Router} from '@angular/router';
import {catchError, Observable, of, throwError} from 'rxjs';
import {AUTH_DATA, IAuthDataProvider} from './providers/auth.provider';

@Injectable({
  providedIn: 'root'
})
export class AuthInterceptorService implements HttpInterceptor {
  constructor(@Inject(AUTH_DATA) public authService: IAuthDataProvider,
              private router: Router) {
  }

  private handleAuthError(err: HttpErrorResponse): Observable<any> {
    if ((err.status === 401) && this.router.url !== "/login") {
      this.authService.user.set(null)
      sessionStorage.clear()
      localStorage.clear()
      window.location.href = ''
      return of(err.message)
    }
    return throwError(() => err);
  }

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    if (this.authService.user()?.token) {
      const modifiedRequest = req.clone({headers: new HttpHeaders().append("Authorization", "Bearer " + this.authService.user()?.token)});
      return next.handle(modifiedRequest).pipe(
        catchError((error: HttpErrorResponse) => {
          return this.handleAuthError(error);
        }));
    }

    return next.handle(req).pipe(
      catchError((error: HttpErrorResponse) => {
        return this.handleAuthError(error);
      }));
  }

}
