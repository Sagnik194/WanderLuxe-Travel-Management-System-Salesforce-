import { LightningElement, track } from 'lwc';
import getPendingVerifications from '@salesforce/apex/TravelerConsoleController.getPendingVerifications';
import massApprove from '@salesforce/apex/TravelerConsoleController.massApprove';
import updateBookingStatus from '@salesforce/apex/TravelerConsoleController.updateBookingStatus';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Traveler', fieldName: 'Name' },
    { label: 'Passport Number', fieldName: 'Passport_Number__c' },
    { label: 'Verification Status', fieldName: 'Verification_Status__c' },
    { label: 'Booking Status', fieldName: 'Booking_Status__c' },
    { label: 'VIP Grade', fieldName: 'VIP_Grade__c' }
];

export default class TravelerConsole extends LightningElement {
    columns = COLUMNS;
    searchTerm = '';
    selectedIds = [];
    wiredResult;
    @track travelers = [];

    connectedCallback() {
        this.loadTravelers();
    }

    loadTravelers() {
        getPendingVerifications({ searchPassport: this.searchTerm || null })
            .then(result => {
                this.travelers = result;
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.loadTravelers();
    }

    handleRowSelection(event) {
        this.selectedIds = event.detail.selectedRows.map(row => row.Id);
    }

    handleMassApprove() {
        if (this.selectedIds.length === 0) {
            this.showToast('No records selected', 'Select at least one traveler to approve.', 'warning');
            return;
        }
        massApprove({ travelerIds: this.selectedIds })
            .then(() => {
                this.showToast('Success', 'Selected travelers approved.', 'success');
                this.loadTravelers();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}