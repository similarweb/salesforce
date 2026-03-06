import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getData from '@salesforce/apex/RecordIFrameController.getData';

export default class RecordIframe extends LightningElement {
    @api recordId;

    @track iframeUrl;

    connectedCallback() {
        getData({recordId: this.recordId})
            .then((data) => {
                if (data) {
                    this.iframeUrl = data;
                }
            })
            .catch((error) => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error
                }));
            })
    }
}