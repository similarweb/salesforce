import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import getMQLInfo from "@salesforce/apex/CountDownClockCtrl.getMQLInfoFromApex";
import {
  subscribe,
  unsubscribe,
  onError,
  setDebugFlag
} from "lightning/empApi";

const leadFields = [
  "Lead.SLA_Start_Timestamp__c",
  "Lead.mql_status__c",
  "Lead.BI_Data__r.Intent_Score__c",
  "Lead.SW_Fit_Score__c",
  "Lead.API_last_60_days__c"
];

const contactFields = [
  "Contact.mql_status__c",
  "Contact.SLA_Start_Timestamp__c",
  "Contact.BI_Data__r.Intent_Score__c",
  "Contact.SW_Fit_Score__c",
  "Contact.API_last_60_days__c"
];

export default class CountdownClock extends LightningElement {
  @api recordId;
  @track timeRemaining = "00:00:00"; // Initialize time remaining
  @track showMessage = false;
  @track error = null;
  @track hours = "00";
  @track minutes = "00";
  @track seconds = "00";
  countdownTimer;
  subscription = null;
  channelName = "/event/MirStatusChangeEvent__e";

  connectedCallback() {
    this.setEmpApiDebugFlag();
    this.determineObjectType();
    this.subscribeToPlatformEvent();
    this.getInfoFromApex();
  }

  disconnectedCallback() {
    if (this.subscription) {
      unsubscribe(this.subscription, (response) => {
        console.log("Unsubscribed from event:", response);
      }).catch((error) => {
        console.error("Error while unsubscribing:", error);
      });
    }

    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }

    console.log("Component destroyed, subscription and timer cleared.");
  }

  setEmpApiDebugFlag() {
    setDebugFlag(true);
  }

  subscribeToPlatformEvent() {
    subscribe(this.channelName, -1, (message) => {
      console.log("Received MirStatusChangeEvent:", message);
      this.handlePlatformEvent(message);
    })
      .then((response) => {
        this.subscription = response;
        console.log("Successfully subscribed to event:", response);
      })
      .catch((error) => {
        console.error("Subscription failed:", error);
      });

    onError((error) => {
      console.error("Streaming API error:", error);
    });
  }

  handlePlatformEvent(message) {
    const recordId = message.data.payload.Record_Id__c;

    if (recordId === this.recordId) {
      console.log(`MIR_Status__c changed for RecordId: ${this.recordId}`);
      this.stopCountdown();
      this.showMessage = true;
      this.message = "alon stopped it";
    }
  }

  determineObjectType() {
    const prefix = this.recordId.substring(0, 3);
    this.sobjectType = prefix === "00Q" ? "Lead" : "Contact";
    this.fields = prefix === "00Q" ? leadFields : contactFields;
  }

  getInfoFromApex() {
    getMQLInfo({ objectType: this.sobjectType, recordId: this.recordId })
      .then((result) => {
        console.log("MQL Info:", result);
        const startTime = new Date(result.SobjectInfo.SLA_Start_Timestamp__c);
        const additionalTime = result.mqlMap[result.SobjectInfo.mql_status__c];

        if (additionalTime) {
          const endTime = new Date(
            startTime.getTime() + additionalTime * 60 * 60 * 1000
          );
          this.startCountdown(endTime);
        }
      })
      .catch((error) => {
        console.error("Error fetching MQL Info:", error);
        this.error = error;
      });
  }

  startCountdown(endTime) {
    this.countdownTimer = setInterval(() => {
      const now = new Date().getTime();
      const timeDifference = endTime - now;

      if (timeDifference <= 0) {
        this.stopCountdown();
        console.log("Countdown finished.");
        return;
      }

      this.timeRemaining = this.formatTimeRemaining(timeDifference);
    }, 1000);
  }

  stopCountdown() {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  }

  formatTimeRemaining(timeDifference) {
    const days = Math.floor(timeDifference / (1000 * 60 * 60 * 24));
    const hours = Math.floor(
      (timeDifference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
    );
    const minutes = Math.floor(
      (timeDifference % (1000 * 60 * 60)) / (1000 * 60)
    );
    const seconds = Math.floor((timeDifference % (1000 * 60)) / 1000);

    this.hours = String(hours).padStart(2, "0");
    this.minutes = String(minutes).padStart(2, "0");
    this.seconds = String(seconds).padStart(2, "0");

    return days > 0
      ? `${days}d ${this.hours}:${this.minutes}:${this.seconds}`
      : `${this.hours}:${this.minutes}:${this.seconds}`;
  }

  get hoursClass() {
    return this.isComplete ? "time-box no-animation" : "time-box hours";
  }

  get minutesClass() {
    return this.isComplete ? "time-box no-animation" : "time-box minutes";
  }

  get secondsClass() {
    return this.isComplete ? "time-box no-animation" : "time-box seconds";
  }
}
