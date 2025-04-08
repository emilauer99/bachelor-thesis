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
  protected readonly isMobile = signal(true);

  private readonly _mobileQuery: MediaQueryList;
  private readonly _mobileQueryListener: () => void;

  isLoggingOut: boolean = false

  constructor(private authService: AuthService,
              private router: Router) {
    const media = inject(MediaMatcher);

    this._mobileQuery = media.matchMedia('(max-width: 600px)');
    this.isMobile.set(this._mobileQuery.matches);
    this._mobileQueryListener = () => this.isMobile.set(this._mobileQuery.matches);
    this._mobileQuery.addEventListener('change', this._mobileQueryListener);
  }

  ngOnDestroy(): void {
    this._mobileQuery.removeEventListener('change', this._mobileQueryListener);
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
