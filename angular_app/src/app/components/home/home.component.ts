import {Component, inject, signal} from '@angular/core';
import {MatSidenavContainer, MatSidenavModule} from '@angular/material/sidenav';
import {Router, RouterLink, RouterLinkActive, RouterOutlet} from '@angular/router';
import {MatToolbar} from '@angular/material/toolbar';
import {MatIcon} from '@angular/material/icon';
import {MatIconButton} from '@angular/material/button';
import {MediaMatcher} from '@angular/cdk/layout';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {finalize} from 'rxjs';
import {AuthService} from '../../services/auth.service';
import {MobileService} from '../../services/mobile.service';

@Component({
  selector: 'app-home',
  imports: [
    MatSidenavContainer,
    RouterLink,
    MatSidenavModule,
    MatToolbar,
    MatIcon,
    RouterOutlet,
    RouterLinkActive,
    MatProgressSpinner,
  ],
  templateUrl: './home.component.html',
  standalone: true,
  styleUrl: './home.component.sass'
})
export class HomeComponent {
  isLoggingOut: boolean = false

  constructor(private authService: AuthService,
              public mobileService: MobileService,
              private router: Router) {
  }

  logout() {
    this.isLoggingOut = true;
    this.authService.logout()
      .pipe(finalize(() => this.isLoggingOut = false)
      ).subscribe({
      next: () => {
        this.router.navigate(['/login']);
      },
      error: (error) => {

      }
    });
  }
}
