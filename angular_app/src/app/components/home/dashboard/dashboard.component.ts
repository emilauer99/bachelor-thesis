import { Component } from '@angular/core';
import {MatSidenavContainer, MatSidenavModule} from '@angular/material/sidenav';
import {RouterLink, RouterOutlet} from '@angular/router';
import {MatToolbar} from '@angular/material/toolbar';
import {MatIcon} from '@angular/material/icon';
import {MatIconButton} from '@angular/material/button';

@Component({
  selector: 'app-dashboard',
  imports: [
  ],
  templateUrl: './dashboard.component.html',
  standalone: true,
  styleUrl: './dashboard.component.sass'
})
export class DashboardComponent {

  logout() {
    // Logout-Logik hier implementieren
    console.log('Logging out…');
  }
}
