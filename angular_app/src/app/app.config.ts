import {ApplicationConfig, importProvidersFrom, provideZoneChangeDetection} from '@angular/core';
import { provideRouter } from '@angular/router';

import { routes } from './app.routes';
import {HTTP_INTERCEPTORS, provideHttpClient, withInterceptorsFromDi} from '@angular/common/http';
import {AuthInterceptorService} from './services/auth-interceptor.service';
import {provideNativeDateAdapter} from '@angular/material/core';
import {DatePipe} from '@angular/common';
import {PROJECT_DATA} from './services/providers/projects.provider';
import {environment} from '../environments/environment';
import {ProjectMockService} from './services/mock/project-mock.service';
import {ProjectService} from './services/project.service';
import {CUSTOMER_DATA} from './services/providers/customers.provider';
import {CustomerMockService} from './services/mock/customer-mock.service';
import {CustomerService} from './services/customer.service';
import {AUTH_DATA} from './services/providers/auth.provider';
import {AuthMockService} from './services/mock/auth-mock.service';
import {AuthService} from './services/auth.service';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(
      withInterceptorsFromDi()
    ),
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptorService,
      multi: true
    },
    provideNativeDateAdapter(),
    DatePipe,
    {
      provide: PROJECT_DATA,
      useClass: environment.mockData
        ? ProjectMockService
        : ProjectService
    },
    {
      provide: CUSTOMER_DATA,
      useClass: environment.mockData
        ? CustomerMockService
        : CustomerService
    },
    {
      provide: AUTH_DATA,
      useClass: environment.mockData
        ? AuthMockService
        : AuthService
    }
  ]
};
