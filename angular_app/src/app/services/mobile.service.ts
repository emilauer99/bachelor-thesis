import {Injectable, Signal, signal} from '@angular/core';
import {MediaMatcher} from '@angular/cdk/layout';

@Injectable({
  providedIn: 'root'
})
export class MobileService {
  private readonly _mobileQuery: MediaQueryList;
  private readonly _isMobile = signal(false);

  // Expose as readonly signal
  public isMobile: Signal<boolean> = this._isMobile.asReadonly();

  constructor(private mediaMatcher: MediaMatcher) {
    this._mobileQuery = this.mediaMatcher.matchMedia('(max-width: 600px)');
    this._isMobile.set(this._mobileQuery.matches);

    this._mobileQuery.addEventListener('change', (event) => {
      this._isMobile.set(event.matches);
    });
  }
}
