import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";

export default class CustomFlowButton extends LightningElement {
  @api recordId;
  @api buttonLabel = "Click here to update the Bill\\\Sold to contact details";
  @api flowName = "Update_bill_sold_to_screen_flow";
  isModalOpen = false;

  get flowVariables() {
    return [
      {
        name: "recordId",
        type: "String",
        value: this.recordId
      }
    ];
  }

  openModal() {
    this.isModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
  }
  handleFlowStatusChange(event) {
    const status = event.detail.status;
    if (status === "FINISHED" || status === "FINISHED_SCREEN") {
      this.closeModal();
    }
  }
}
