import { LightningElement, api, track, wire } from "lwc";
import getChatGPTResponse from "@salesforce/apex/ChatGPTController.getChatGPTResponse";
import { getRecord } from "lightning/uiRecordApi";

export default class ChatGPTBrief extends LightningElement {
  @api recordId;
  @track accountBrief;
  @track isLoading = false;

  get fields() {
    // Let's say '00Q' is the prefix for Lead and '001' is the prefix for Account.
    // Adjust as per your org's prefixes.
    if (this.recordId.startsWith("00Q"))
      return ["Lead.ChatGPT_Summary__c", "Lead.Website"];
    if (this.recordId.startsWith("001"))
      return ["Account.ChatGPT_Summary__c", "Account.Website"];
    return [];
  }

  @wire(getRecord, { recordId: "$recordId", fields: "$fields" })
  wiredRecord({ error, data }) {
    if (data) {
      this.accountBrief = data.fields
        ? data.fields.ChatGPT_Summary__c
          ? data.fields.ChatGPT_Summary__c.value
          : null
        : null;
    } else if (error) {
      console.error("Error retrieving record:", error);
    }
  }

  getAccountBrief() {
    this.isLoading = true;
    getChatGPTResponse({ recordId: this.recordId })
      .then((result) => {
        this.accountBrief = result;
        this.isLoading = false;
      })
      .catch((error) => {
        console.error("Error retrieving ChatGPT response:", error);
        this.isLoading = false;
      });
  }
}
