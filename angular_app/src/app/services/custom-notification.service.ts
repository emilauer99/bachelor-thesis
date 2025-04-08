import {inject, Injectable} from '@angular/core';
import {MatSnackBar} from '@angular/material/snack-bar';

@Injectable({
  providedIn: 'root'
})
export class CustomNotificationService {
  private _snackBar = inject(MatSnackBar);

  constructor() { }

  success(message: string, panelClass?: string) {
    this._snackBar.open(message, 'Close', {panelClass: [panelClass ?? 'success'], duration: 3000});
  }

  error(message: string) {
    this._snackBar.open(message, 'Close', {panelClass: ['error'], duration: 3000});
  }
}
