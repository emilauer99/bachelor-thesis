import {CanActivateFn, Router} from '@angular/router';
import {inject} from '@angular/core';
import {AUTH_DATA, IAuthDataProvider} from '../services/providers/auth.provider';

export const homeGuard: CanActivateFn = (route, state) => {
  const authService = inject(AUTH_DATA) as IAuthDataProvider;
  let router = inject(Router)

  if (authService.user()?.token) {
    return true;
  } else {
    // Redirect to the login page if no token exists
    router.navigate(['/login']);
    return false;
  }
};
