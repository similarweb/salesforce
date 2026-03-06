/**
 * Created by Alon.Shalev on 1/7/2025.
 */

import { LightningElement, wire,api } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class RefreshRecordUponEventCmp extends LightningElement {
    channelName = '/event/Refresh_Record_Page__e'; // Update with your Platform Event API Name
    subscription = {};
    @api recordId

    connectedCallback() {
        // Subscribe to the Platform Event channel
        this.subscribeToEvent();

        // Handle errors
        onError((error) => {
            console.error('Error received from platform event: ', error);
        });
    }

    disconnectedCallback() {
        // Unsubscribe when component is destroyed
        this.unsubscribeFromEvent();
    }

    subscribeToEvent() {
        const messageCallback = (response) => {
            console.log('Platform Event received: ', response);
            const eventRecordId = response.data.payload.Record_ID__c;
            if (eventRecordId === this.recordId) {
                console.log('Record ID matches. Refreshing the page.');
                this.refreshPage();
            } else {
                console.log('Record ID does not match. No action taken.');
            }
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            this.subscription = response;
            console.log('Subscribed to: ', response.channel);
        });
    }

    unsubscribeFromEvent() {
        unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed from: ', response);
        });
    }

    refreshPage() {
        // Refresh the current page
        window.location.reload();
    }
}