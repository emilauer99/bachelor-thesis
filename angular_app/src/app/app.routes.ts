import { Routes } from '@angular/router';
import {LoginComponent} from './components/login/login.component';
import {HomeComponent} from './components/home/home.component';
import {DashboardComponent} from './components/home/dashboard/dashboard.component';
import {ProjectsComponent} from './components/home/projects/projects.component';
import {CustomersComponent} from './components/home/customers/customers.component';
import {BoardComponent} from './components/home/board/board.component';
import {homeGuard} from './guards/home.guard';
import {authGuard} from './guards/auth.guard';
import {MoreComponent} from './components/home/more/more.component';
import {ProjectComponent} from './components/home/projects/project/project.component';

export const routes: Routes = [
  {
    path: 'login',
    // canActivate: [authGuard],
    component: LoginComponent
  },
  {
    path: '',
    // canActivate: [homeGuard],
    component: HomeComponent,
    children: [
      {
        path: "dashboard",
        component: DashboardComponent
      },
      {
        path: "projects",
        component: ProjectsComponent,
      },
      {
        path: "projects/:id",
        component: ProjectComponent
      },
      {
        path: "customers",
        component: CustomersComponent
      },
      {
        path: "board",
        component: BoardComponent
      },
      {
        path: "more",
        component: MoreComponent
      },
      {
        path: "**",
        redirectTo: "dashboard"
      }
    ]
  },
  {
    path: "**",
    redirectTo: "login",
  }
];
