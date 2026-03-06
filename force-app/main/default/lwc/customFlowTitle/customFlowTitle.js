import { LightningElement, api } from 'lwc';

export default class CustomFlowTitle extends LightningElement {
    @api title;
    @api helpText;
    @api isWarning = false;
    @api hideTitle = false;
    
    get helpBoxClass() {
        return this.isWarning === true ? 'help-box warning' : 'help-box';
    }
    
    get showTitle() {
        return !this.hideTitle;
    }
}