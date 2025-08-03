import {Component, Inject} from '@angular/core';
import {MatDivider, MatList, MatListItem, MatNavList} from '@angular/material/list';
import {Router, RouterLink} from '@angular/router';
import {NgStyle} from '@angular/common';
import {MatIcon} from '@angular/material/icon';
import {MatLine} from '@angular/material/core';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {AuthService} from '../../../services/auth.service';
import {MatSnackBar} from '@angular/material/snack-bar';
import {finalize} from 'rxjs';
import {CUSTOMER_DATA, ICustomerDataProvider} from '../../../services/providers/customers.provider';
import {AUTH_DATA, IAuthDataProvider} from '../../../services/providers/auth.provider';

@Component({
  selector: 'app-more',
  imports: [
    MatList,
    MatListItem,
    RouterLink,
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
