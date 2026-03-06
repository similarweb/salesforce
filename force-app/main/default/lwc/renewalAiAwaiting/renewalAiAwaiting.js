import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import checkFieldsPopulated from '@salesforce/apex/RenewalAiAwaitingController.checkFieldsPopulated';

export default class RenewalAiAwaiting extends LightningElement {
    @api recordId;
    @api fieldsToCheck;
    @api pollIntervalSeconds = 5;
    @api maxWaitTimeSeconds = 30;
    @api loadingMessage = 'Processing your request...';
    @api successMessage = 'Data received successfully!';
    
    @api availableActions = [];
    
    isLoading = true;
    displayMessage = '';
    pollCount = 0;
    maxPollCount = 0;
    pollIntervalId = null;
    fieldApiNames = [];
    
    connectedCallback() {
        this.displayMessage = this.loadingMessage;
        this.maxPollCount = Math.floor(this.maxWaitTimeSeconds / this.pollIntervalSeconds);
        
        if (this.fieldsToCheck) {
            this.fieldApiNames = this.fieldsToCheck.split(',').map(field => field.trim());
            this.startPolling();
        } else {
            this.handleSuccess();
        }
    }
    
    disconnectedCallback() {
        this.stopPolling();
    }
    
    startPolling() {
        this.checkFields();
        
        this.pollIntervalId = setInterval(() => {
            this.pollCount++;
            
            if (this.pollCount >= this.maxPollCount) {
                this.stopPolling();
                this.handleTimeout();
            } else {
                this.checkFields();
            }
        }, this.pollIntervalSeconds * 1000);
    }
    
    stopPolling() {
        if (this.pollIntervalId) {
            clearInterval(this.pollIntervalId);
            this.pollIntervalId = null;
        }
    }
    
    checkFields() {
        if (!this.recordId) {
            console.error('No recordId provided');
            return;
        }
        
        checkFieldsPopulated({ 
            recordId: this.recordId, 
            fieldNames: this.fieldApiNames
        })
            .then(result => {
                if (result) {
                    this.stopPolling();
                    this.handleSuccess();
                }
            })
            .catch(error => {
                console.error('Error fetching record:', error);
            });
    }
    
    handleSuccess() {
        this.isLoading = false;
        this.displayMessage = this.successMessage;
        
        setTimeout(() => {
            this.navigateNext();
        }, 1000);
    }
    
    handleTimeout() {
        this.isLoading = false;
        this.displayMessage = 'Processing is taking longer than expected. Continuing...';
        
        setTimeout(() => {
            this.navigateNext();
        }, 2000);
    }
    
    navigateNext() {
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}