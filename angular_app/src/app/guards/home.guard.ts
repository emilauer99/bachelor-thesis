import {CanActivateFn, Router} from '@angular/router';
import {inject} from '@angular/core';
import {AuthService} from '../services/auth.service';

export const homeGuard: CanActivateFn = (route, state) => {
  let authService = inject(AuthService)
  let router = inject(Router)

  if (authService.user()?.token) {
    return true;
  } else {
    // Redirect to the login page if no token exists
    router.navigate(['/login']);
    return false;
  }
};
