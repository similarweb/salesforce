/**
 * Created by Alon.Shalev on 7/3/2023.
 */

import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class GaugeLWC extends LightningElement {
    @api recordId;  // Assuming this component is placed on Lead's record page.
    @track leadIntentScore;
    circleStyle;
    get fields() {
        // Let's say '00Q' is the prefix for Lead and '001' is the prefix for Account.
        // Adjust as per your org's prefixes.
        if(this.recordId.startsWith('00Q')) return ['Lead.Intent_Score__c'];
        if(this.recordId.startsWith('003')) return ['Contact.Intent_Score__c'];
        return [];
    }
    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    lead({error, data}) {
        if(data) {
            if(data.fields && data.fields.Intent_Score__c) {
                this.leadIntentScore = data.fields.Intent_Score__c.value;
                const radius = 15.9155; // Defined in SVG path
                const circumference = 2 * Math.PI * radius;
                const strokeVal = circumference * (1 - (this.leadIntentScore / 10));
                this.circleStyle = `stroke-dasharray: ${circumference}; stroke-dashoffset: ${strokeVal};`;
            } else {
                // Handle the situation when the intent_score__c field is not available
                console.warn('The Intent_Score__c field is not available');
            }
        }else if(error) {
            console.error('Error in retrieving Lead data', error);
        }
    }
}