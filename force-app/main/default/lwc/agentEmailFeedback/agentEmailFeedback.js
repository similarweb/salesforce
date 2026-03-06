import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {FlowNavigationFinishEvent} from 'lightning/flowSupport';

import getData from '@salesforce/apex/AgentEmailFeedbackController.getData';
import saveData from '@salesforce/apex/AgentEmailFeedbackController.saveData';


export default class AgentEmailFeedback extends LightningElement {
    // @api recordId = '00TPw00000BMNinMAH';
    @api recordId;
    @api availableActions;

    @track htmlTemplate;
    @track approvalStatus;
    @track reviewerNotes;
    @track isApproved;

    @track load = false;

    connectedCallback() {
        getData({recordId: this.recordId})
            .then((data) => {
                if (data) {
                    this.htmlTemplate = this.normalizeEmailText(data.htmlTemplate);
                    this.approvalStatus = data.approvalStatus;
                    this.reviewerNotes = data.reviewerNotes;
                    this.isApproved = this.approvalStatus === 'Approve';
                }
            })
            .catch((error) => {
                this.showError(error);
            })
            .finally(() => {
                this.load = true;
            })
    }

    handleReviewerNotesInput(event) {
        this.reviewerNotes = event.target.value;
    }

    handleApprove() {
        this.submitFeedback('Approve');
    }

    handleDecline() {
        this.submitFeedback('Decline');
    }

    updateFeedback() {
        this.submitFeedback(this.approvalStatus);
    }

    submitFeedback(status) {
        if (!this.reviewerNotes) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                variant: 'warning',
                message: 'Please enter the feedback'
            }));
            return;
        }

        let jsonInput = JSON.stringify({
            taskId: this.recordId,
            approvalStatus: status,
            reviewerNotes: this.reviewerNotes,
        });
        this.load = false;

        saveData({jsonInput: jsonInput})
            .then((result) => {
                if (result !== 'Success') {
                    this.showError(result);
                }
            })
            .catch((error) => {
                this.showError(error);
            })
            .finally(() => {
                this.load = true;
                if (this.availableActions.find((action) => action === 'FINISH')) {
                    const navigateNextEvent = new FlowNavigationFinishEvent();
                    this.dispatchEvent(navigateNextEvent);
                }
            })
    }

    normalizeEmailText(s) {
        if (!s) return '';

        let out = s.replace(/\r\n/g, '\n').replace(/\r/g, '\n');

        out = out.replace(/\\+r?\\+n/g, '\n');
        out = out.replace(/\\n/g, '\n').replace(/\\r\\n/g, '\n');

        return out;
    }

    showError(error) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message: error
        }));
    }
}