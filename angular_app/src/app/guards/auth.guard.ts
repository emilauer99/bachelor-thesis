import {CanActivateFn, Router} from '@angular/router';
import {inject} from '@angular/core';
import {AuthService} from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  let authService = inject(AuthService)
  let router = inject(Router)

  if (authService.user()?.token) {
    console.log(authService.user())
    router.navigate(['/home']);
    return false;
  } else {
    return true;
  }
};
