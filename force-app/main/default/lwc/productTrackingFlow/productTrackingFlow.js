import {LightningElement, api} from 'lwc';

export default class ProductTrackingFlow extends LightningElement {
    @api recordId = '';
    @api availableActions = [];

    @api successResult = false;

    get inputVariables() {
        return [
            {
                name: "recordId",
                type: "String",
                value: this.recordId,
            },
            {
                name: "IsSubFlow",
                type: "Boolean",
                value: true,
            }
        ];
    }

    handleStatusChange(event) {
        if (event.detail.status === "FINISHED") {
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                console.log('outputVar: ' + JSON.stringify(outputVar));
                if (outputVar.name == "SuccessResult") {
                    this.successResult = outputVar.value;
                    console.log(this.successResult);
                }
            }
        }
    }
}