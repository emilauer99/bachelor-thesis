import {CanActivateFn, Router} from '@angular/router';
import {inject} from '@angular/core';
import {AUTH_DATA, IAuthDataProvider} from '../services/providers/auth.provider';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AUTH_DATA) as IAuthDataProvider;
  let router = inject(Router)

  if (authService.user()?.token) {
    console.log(authService.user())
    router.navigate(['/home']);
    return false;
  } else {
    return true;
  }
};
