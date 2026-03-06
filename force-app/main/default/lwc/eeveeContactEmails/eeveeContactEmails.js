import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getContactEmailsData from '@salesforce/apex/EeveeController.getContactEmailsData';

export default class EeveeContactEmails extends LightningElement {
    @api recordId;

    @track iframeUrl;

    connectedCallback() {
        getContactEmailsData({recordId: this.recordId})
            .then((data) => {
                if (data) {
                    this.iframeUrl = data;
                }
            })
            .catch((error) => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body?.message || error.message || 'Unknown error'
                }));
            })
    }
}