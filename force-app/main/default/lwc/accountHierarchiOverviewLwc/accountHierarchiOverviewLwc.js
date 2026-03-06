import { LightningElement, api, wire,track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getHierarchyData from '@salesforce/apex/AccountHierarchyDataCtrl.getHierarchyData';

const FIELDS = ['Account.Parent_Company_Domain__c'];

export default class HierarchyData extends LightningElement {
    @api recordId; // This will be automatically populated with the current record ID
    parentCompanyDomain;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this.parentCompanyDomain = getFieldValue(data, 'Account.Parent_Company_Domain__c');
            this.fetchHierarchyData();
        } else if (error) {
            console.error(error);
        }
    }

    @track data = {};

    fetchHierarchyData() {
        if (this.parentCompanyDomain) {
            getHierarchyData({ parentCompanyDomain: this.parentCompanyDomain })
                .then(result => {
                    this.data = result;
                    console.log('i am here')
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }
}