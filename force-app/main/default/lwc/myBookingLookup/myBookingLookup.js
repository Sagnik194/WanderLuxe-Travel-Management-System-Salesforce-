import { LightningElement, track } from 'lwc';
import getMyBooking from '@salesforce/apex/MyTravelerController.getMyBooking';

export default class MyBookingLookup extends LightningElement {
    @track passportNumber = '';
    @track booking = null;
    @track errorMessage = '';

    handleInputChange(event) {
        this.passportNumber = event.target.value;
        this.errorMessage = '';
    }

    handleLookup() {
        if (!this.passportNumber) {
            this.errorMessage = 'Please enter a passport number.';
            return;
        }

        getMyBooking({ passportNumber: this.passportNumber })
            .then(result => {
                this.booking = result;
                this.errorMessage = '';
            })
            .catch(error => {
                this.booking = null;
                this.errorMessage = error.body ? error.body.message : 'Unknown error occurred';
            });
    }
}