import {Component, Inject} from '@angular/core';
import {MatDivider, MatListItem, MatNavList} from '@angular/material/list';
import {Router} from '@angular/router';
import {MatIcon} from '@angular/material/icon';
import {MatLine} from '@angular/material/core';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {finalize} from 'rxjs';
import {AUTH_DATA, IAuthDataProvider} from '../../../services/providers/auth.provider';

@Component({
  selector: 'app-more',
  imports: [
    MatListItem,
    MatIcon,
    MatLine,
    MatDivider,
    MatProgressSpinner,
    MatLine,
    MatNavList
  ],
  templateUrl: './more.component.html',
  standalone: true,
  styleUrl: './more.component.sass'
})
export class MoreComponent {
  isLoggingOut = false;

  constructor(
    @Inject(AUTH_DATA) public authService: IAuthDataProvider,
    public router: Router
  ) {}

  onCustomers() {
    this.router.navigate(['/customers']);
  }

  onSettings() {
    this.router.navigate(['/settings']);
  }

  logout(): void {
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
