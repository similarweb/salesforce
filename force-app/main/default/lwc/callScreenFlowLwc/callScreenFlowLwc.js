import { LightningElement, api, track } from 'lwc';

export default class CallScreenFlowLwc extends LightningElement {
    @api recordId;
    @api flowApiName;

    @api label = 'Start Flow';
    @api launchMode = 'inline'; // 'inline' or 'modal'
    @api nameInput;
    @api Input_Bool_Var;
    @api Input_Text_Var;
    @api autoLaunch = false; // 👈 new: auto-start or wait for click
    @api buttonStyle = 'default-flow-button'; // ✅ CSS class support
    @api buttonClass = 'default-flow-button'; // ✅ CSS class support
    @api buttonSize = 'medium';
    @api variant = 'brand';         // Valid variant: 'brand', 'neutral', etc.
    @api iconName;                  // e.g. 'utility:forward'
    @api iconPosition = 'left';     // 'left' or 'right'
    @api modalName = '';     // 'left' or 'right'
    @api alignment = 'left'; // 'left', 'center', or 'right'
    @api modalSize;

    @track isModalOpen = false;
    @track shouldRunFlow = false;
    @track flowInputVariables = [];

    @api successResult = false;
    @api newProductCreated = false;
    @api outputBool1 = false;
    @api outputBool2 = false;
    @api outputString1 = '';
    @api outputString2 = '';

    @api
    get flowFinished() {
        return this._flowFinished;
    }
    get combinedButtonClass() {
        return `${this.buttonClass} ${this.buttonSizeClass}`.trim();
    }

    get buttonSizeClass() {
        switch (this.buttonSize?.toLowerCase()) {
            case 'big':
                return 'button-big';
            case 'small':
                return 'button-small';
            case 'medium':
            default:
                return 'button-medium';
        }
    }

    get buttonClass() {
        switch (this.buttonStyle?.toLowerCase()) {
            case 'action':
                return 'custom-action-button';
            case 'subtle':
                return 'custom-subtle-button';
            case 'brand':
            default:
                return 'custom-brand-button';
        }
    }

    get alignmentClass() {
        switch (this.alignment) {
            case 'center': return 'slds-text-align_center slds-m-top_small';
            case 'right': return 'slds-text-align_right slds-m-top_small';
            case 'left': return 'slds-text-align_left slds-m-top_small';
            default: return 'slds-text-align_left';
        }
    }
    get computedModalClass() {
        const sizeClassMap = {
            small: 'slds-modal_small',
            medium: 'slds-modal_medium',
            large: 'slds-modal_large'
        };

        const resolvedSize = sizeClassMap[this.modalSize?.toLowerCase()] || 'slds-modal_medium';
        return `slds-modal slds-fade-in-open ${resolvedSize}`;
    }


    connectedCallback() {
        if (this.autoLaunch === true || this.autoLaunch === 'true') {
            this.startFlow();
        }
    }

    handleClick() {
        debugger;
        this.startFlow();
    }

    startFlow() {
        const inputs = {};
        if (this.recordId) inputs.recordId = this.recordId;
        if (this.nameInput) inputs.nameInput = this.nameInput;
        if (this.Input_Text_Var) inputs.Input_Text_Var = this.Input_Text_Var;
        if (this.Input_Bool_Var !== undefined) inputs.Input_Bool_Var = this.Input_Bool_Var;

        this.flowInputVariables = Object.entries(inputs).map(([key, value]) => ({
            name: key,
            type:
                typeof value === 'boolean' ? 'Boolean' :
                    typeof value === 'number' ? 'Number' :
                        'String',
            value
        }));

        if (this.launchMode === 'modal') {
            this.isModalOpen = true;
        } else {
            this.shouldRunFlow = true;
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleFlowStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                if (outputVar.name == "outputBool1") {
                    this.outputBool1 = outputVar.value;
                }
                if (outputVar.name == "outputBool2") {
                    this.outputBool2 = outputVar.value;
                }
                if (outputVar.name == "outputString1") {
                    this.outputString1 = outputVar.value;
                }
                if (outputVar.name == "outputString2") {
                    this.outputString2 = outputVar.value;
                }
            }
            this.shouldRunFlow = false;
            this.isModalOpen = false;
            // this._status = 'FINISHED';
            // this._flowFinished = true;
            // this.dispatchEvent(new CustomEvent('flowfinished'));
        }
    }
}