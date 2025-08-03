import {Component, Inject} from '@angular/core';
import {FormBuilder, FormGroup, ReactiveFormsModule, Validators} from '@angular/forms';
import {AuthService} from '../../services/auth.service';
import {Router} from '@angular/router';
import {MatError, MatFormField, MatInput, MatLabel, MatPrefix} from '@angular/material/input';
import {MatButton} from '@angular/material/button';
import {MatProgressSpinner} from '@angular/material/progress-spinner';
import {MatIcon} from '@angular/material/icon';
import {MatCard, MatCardContent, MatCardHeader, MatCardModule} from '@angular/material/card';
import {CustomNotificationService} from '../../services/custom-notification.service';
import {finalize} from 'rxjs';
import {AUTH_DATA, IAuthDataProvider} from '../../services/providers/auth.provider';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatFormField,
    MatLabel,
    MatButton,
    MatProgressSpinner,
    MatIcon,
    MatInput,
    MatError,
    MatCard,
    MatCardHeader,
    MatCardContent,
    MatCardModule,
    MatPrefix
  ],
  styleUrl: './login.component.sass'
})
export class LoginComponent {
  loginForm: FormGroup;
  loading = false;
  hidePassword = true;

  constructor(
    private formBuilder: FormBuilder,
    @Inject(AUTH_DATA) public authService: IAuthDataProvider,
    private router: Router,
    private customNotificationService: CustomNotificationService
  ) {
    this.loginForm = this.formBuilder.group({
      email: [null, [Validators.required, Validators.email]],
      password: [null, Validators.required]
    });
  }

  onSubmit() {
    this.loginForm.markAllAsTouched()
    if (this.loginForm.invalid)
      return

    this.loading = true;
    const { email, password } = this.loginForm.value;

    this.authService.login(email, password)
      .pipe(
        finalize(() => this.loading = false)
      )
      .subscribe({
      next: (user) => {
        console.log('lol')
        this.router.navigate(['/dashboard'], { state: { freshLogin: true } });
      },
      error: (error) => {
        let errorMessage = 'An unknown error occurred';

        if (error.status === 401) {
          errorMessage = 'Credentials incorrect';
        } else if (error.error?.message) {
          errorMessage = error.error.message;
        }
        this.customNotificationService.error(errorMessage)
      }
    });
  }
}
