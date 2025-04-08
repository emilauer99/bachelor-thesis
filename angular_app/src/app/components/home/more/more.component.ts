import { Component } from '@angular/core';
import {MatDivider, MatList, MatListItem} from '@angular/material/list';
import {Router, RouterLink} from '@angular/router';
import {NgStyle} from '@angular/common';
import {MatIcon} from '@angular/material/icon';
import {MatLine} from '@angular/material/core';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {AuthService} from '../../../services/auth.service';
import {MatSnackBar} from '@angular/material/snack-bar';
import {finalize} from 'rxjs';

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
    NgStyle
  ],
  templateUrl: './more.component.html',
  standalone: true,
  styleUrl: './more.component.sass'
})
export class MoreComponent {
  isLoggingOut = false;

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

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
