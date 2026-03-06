/**
 * Created by Alon.Shalev on 8/7/2024.
 */
import { LightningElement, api } from "lwc";
import getRecordData from "@salesforce/apex/MqlScoreCtrl.getRecordData";

export default class MqlScoreLwc extends LightningElement {
  @api recordId; // Record ID passed to the component

  score;
  lastModify;
  sObjectType;

  connectedCallback() {
    this.sObjectType = this.determineObjectType(); // Initialize it correctly
    this.loadRecordData(); // Load record data when component initializes
  }

  determineObjectType() {
    const prefix = this.recordId.substr(0, 3);
    return prefix === "00Q" ? "Lead" : "Contact";
  }

  // Fetch record data from the Apex controller
  async loadRecordData() {
    try {
      const data = await getRecordData({
        recordId: this.recordId,
        sObjectType: this.sObjectType
      });

      // Extract values from the response
      this.score = data.mql_status;
      const lastModifyDate = data.firstMQLDate || data.firstOwnerTimestamp;
      this.lastModify = this.convertToNicerVersion(lastModifyDate);
    } catch (error) {
      console.error("Error loading record data:", error);
    }
  }

  // Dynamically calculate indicator style based on score value
  get indicatorStyle() {
    let left = "0%"; // Default value for the indicator
    let activeSectionClass = "";

    if (this.score) {
      const sections = this.template.querySelectorAll(".gauge-section");
      sections.forEach((section) => section.classList.add("grayed-out"));

      switch (this.score) {
        case "Unverified MQL":
          activeSectionClass = "UNVERIFIED";
          break;
        case "Reserve":
          activeSectionClass = "RESERVE";
          break;
        case "Soft MQL":
          activeSectionClass = "SOFT";
          break;
        case "Hard MQL":
          activeSectionClass = "HARD";
          break;
        default:
          activeSectionClass = "NURTURE";
      }

      const activeSection = this.template.querySelector(
        `.${activeSectionClass}`
      );
      if (activeSection) activeSection.classList.remove("grayed-out");
    }

    console.log("Computed indicator style:", `left: ${left};`);
    return `left: ${left};`;
  }

  // Helper function to format Salesforce datetime values
  convertToNicerVersion(sfdcDatetime) {
    let formattedDate = "";
    if (sfdcDatetime) {
      const date = new Date(sfdcDatetime);
      const now = new Date();
      const options = { hour: "numeric", minute: "numeric", hour12: false };

      if (date.toDateString() === now.toDateString()) {
        formattedDate = `Today at ${date.toLocaleTimeString("en-US", options)}`;
      } else if (
        date.toDateString() ===
        new Date(now.setDate(now.getDate() - 1)).toDateString()
      ) {
        formattedDate = `Yesterday at ${date.toLocaleTimeString("en-US", options)}`;
      } else {
        const fullDateOptions = {
          year: "numeric",
          month: "long",
          day: "numeric",
          ...options
        };
        formattedDate = date.toLocaleString("en-US", fullDateOptions);
      }
    }
    return formattedDate;
  }
}
