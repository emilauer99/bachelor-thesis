import { Component } from '@angular/core';
import {RouterOutlet} from '@angular/router';

@Component({
  selector: 'app-home',
  imports: [
    RouterOutlet
  ],
  templateUrl: './home.component.html',
  standalone: true,
  styleUrl: './home.component.sass'
})
export class HomeComponent {

}
