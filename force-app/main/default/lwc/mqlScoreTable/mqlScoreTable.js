import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import getMQLScoreInfo from "@salesforce/apex/MqlScoreCtrl.getMQLScoreTableInfoFromApex";

// Fields for Lead and Contact objects
const leadFields = [
  "Lead.BI_Data__r.Intent_Log_Ins__c",
  "Lead.BI_Data__r.intent_num_of_pro_actions__c",
  "Lead.BI_Data__r.Intent_Pricing_Visits_Dates__c",
  "Lead.BI_Data__r.Mrkt_Pro_Hook_Clicked__c",
  "Lead.BI_Data__r.Mrkt_Pro_Hook_Clicked_Dates__c",
  "Lead.BI_Data__r.intent_num_of_handraises__c",
  "Lead.BI_Data__r.Mrkt_Premium_Features_Dates__c",
  "Lead.BI_Data__r.intent_num_of_minisites_visits__c",
  "Lead.BI_Data__r.intent_num_of_dashboards__c",
  "Lead.BI_Data__r.intent_num_of_png_downloads__c",
  "Lead.BI_Data__r.intent_num_of_pdf_downloads__c",
  "Lead.BI_Data__r.intent_num_of_invite_users__c",
  "Lead.BI_Data__r.Mrkt_Last_3_Compare_Websites__c",
  "Lead.BI_Data__r.Mrkt_Last_3_Keyword_List__c",
  "Lead.BI_Data__r.Intent_Trial_Section_and_Sub__c",
  "Lead.BI_Data__r.Intent_Minisite_Section_Visits__c",
  "Lead.Contact_Us_Help_Timestamp__c",
  "Lead.BI_Data__r.Intent_Num_of_Keyword_Lists__c",
  "Lead.BI_Data__r.intent_num_of_package_page_visits__c",
  "Lead.BI_Data__r.Mrkt_Industries_Searched__c"
];

const contactFields = [
  "Contact.BI_Data__r.Intent_Log_Ins__c",
  "Contact.BI_Data__r.intent_num_of_pro_actions__c",
  "Contact.BI_Data__r.Intent_Pricing_Visits_Dates__c",
  "Contact.BI_Data__r.Mrkt_Pro_Hook_Clicked__c",
  "Contact.BI_Data__r.Mrkt_Pro_Hook_Clicked_Dates__c",
  "Contact.BI_Data__r.intent_num_of_handraises__c",
  "Contact.BI_Data__r.Mrkt_Premium_Features_Dates__c",
  "Contact.BI_Data__r.intent_num_of_minisites_visits__c",
  "Contact.BI_Data__r.intent_num_of_dashboards__c",
  "Contact.BI_Data__r.intent_num_of_png_downloads__c",
  "Contact.BI_Data__r.intent_num_of_pdf_downloads__c",
  "Contact.BI_Data__r.intent_num_of_invite_users__c",
  "Contact.BI_Data__r.Mrkt_Last_3_Compare_Websites__c",
  "Contact.BI_Data__r.Mrkt_Last_3_Keyword_List__c",
  "Contact.BI_Data__r.Intent_Trial_Section_and_Sub__c",
  "Contact.BI_Data__r.Intent_Minisite_Section_Visits__c",
  "Contact.Contact_Us_Help_Timestamp__c",
  "Contact.BI_Data__r.Intent_Num_of_Keyword_Lists__c",
  "Contact.BI_Data__r.intent_num_of_package_page_visits__c",
  "Contact.BI_Data__r.Mrkt_Industries_Searched__c"
];

export default class AccordionTableComponent extends LightningElement {
  @api recordId;
  @track biData = {};
  @track openSections = {}; // Track open sections by field name

  renderedCallback() {
    const styleElement = this.template.querySelector(".style-injector");
    // Ensure the active sections are set after rendering is complete
    const accordion = this.template.querySelector("lightning-accordion");
    if (accordion && Object.keys(this.openSections).length > 0) {
      accordion.activeSectionName = Object.values(this.openSections);
    }
    if (styleElement) {
      const style = document.createElement("style");
      style.innerText = `
            /* Customize accordion label font size */
            .slds-accordion__summary-content {
                font-size: 12px; /* Change this to the desired size */
            }

           
            .slds-is-open>.slds-accordion__content{
                font-size: 14px;
            }
        `;

      styleElement.appendChild(style);
    }
  }

  connectedCallback() {
    this.determineObjectType();
    this.getInfoFromApex();
  }
  getInfoFromApex() {
    getMQLScoreInfo({ recordId: this.recordId, sObjectType: this.sobjectType })
      .then((result) => {
        if (result.isSuccess && result.isSuccess == true) {
          this.biData.totalLogins = result.biData.Intent_Log_Ins__c; // data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;
          this.biData.totalActions = result.biData.intent_num_of_pro_actions__c; // data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;
          this.biData.miniSitesVisits =
            result.biData.intent_num_of_minisites_visits__c; // data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;
          this.biData.invitedUsers =
            result.biData.intent_num_of_invite_users__c; // data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;
          this.biData.Intent_Num_of_Keyword_Lists =
            result.biData.Intent_Num_of_Keyword_Lists__c; // data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;
          this.biData.intent_num_of_package_page_visits =
            result.biData.intent_num_of_package_page_visits__c; // data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;
          this.biData.pdfPngDownloads =
            (result.biData.intent_num_of_pdf_downloads__c || 0) +
            (result.biData.intent_num_of_png_downloads__c || 0); // data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;

          this.biData.dashboardsCreated =
            result.biData.intent_num_of_dashboards__c; //    data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value;
          this.biData.SI_Saved_Searches =
            result.biData.Intent_Num_of_SI_Saved_Searches__c; //    data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value;
          this.biData.SI_Sales_Signals =
            result.biData.Intent_Num_of_SI_Sales_Signal__c; //    data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value;
          this.biData.SI_Company_Signals =
            result.biData.Intent_Num_of_SI_Company_Overview_Signal__c; //    data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value;
          this.biData.SI_Advanced_Searches =
            result.biData.Intent_Num_of_SI_Advanced_Searches__c; //    data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value;

          // Process each field to get all values
          this.processField(
            "pricingPageVisit",
            result.biData.Intent_Pricing_Visits_Dates__c
          );
          this.processCombinedField(
            "hooks",
            result.biData.Mrkt_Pro_Hook_Clicked__c,
            result.biData.Mrkt_Pro_Hook_Clicked_Dates__c
          );
          this.processCampaignMembers(
            "campaignMembers",
            result.campaignMembers
          );

          this.processField(
            "handraises",
            result.biData.Contact_Us_Help_Timestamp__c
          );
          this.processField(
            "premiumCenterVisits",
            result.biData.Mrkt_Premium_Features_Dates__c
          );
          // this.processField('miniSitesVisits', data.fields.BI_Data__r.value.fields.intent_num_of_minisites_visits__c.value);
          // this.processField('dashboardsCreated', data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value);
          this.processField(
            "pngDownloads",
            result.biData.intent_num_of_png_downloads__c
          );
          // this.processField('pdfDownloads', data.fields.BI_Data__r.value.fields.intent_num_of_pdf_downloads__c.value);
          // this.processField('invitedUsers', data.fields.BI_Data__r.value.fields.intent_num_of_invite_users__c.value);
          this.processField(
            "latestDomainsComparisons",
            result.biData.Mrkt_Last_3_Compare_Websites__c,
            this.splitValuesSpecialCase
          );
          this.processField(
            "latestKeywords",
            result.biData.Mrkt_Last_3_Keyword_List__c
          );
          this.processField(
            "topTrialSections",
            result.biData.Intent_Trial_Section_and_Sub__c
          );
          this.processField(
            "latestMiniSitesVisited",
            result.biData.Intent_Minisite_Section_Visits__c
          );
          this.processField(
            "Industries",
            result.biData.Mrkt_Industries_Searched__c
          );
        } else {
          this.error = result.exception;
        }
      })
      .catch((error) => {
        console.error("Error fetching MQL Info:", error);
        this.error = error;
      });
  }

  determineObjectType() {
    const prefix = this.recordId.substr(0, 3);
    this.sobjectType = prefix === "00Q" ? "Lead" : "Contact";
  }

  // Wire the getRecord method to fetch data from Lead or Contact, including the parent BI_Data__c fields
  // @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
  // wiredRecord({ error, data }) {
  //     if (data) {
  //         if (data.fields.BI_Data__r?.value) {
  //             this.biData.totalLogins = data.fields.BI_Data__r.value.fields.Intent_Log_Ins__c.value;
  //             this.biData.totalActions = data.fields.BI_Data__r.value.fields.intent_num_of_pro_actions__c.value;
  //             this.biData.miniSitesVisits = data.fields.BI_Data__r.value.fields.intent_num_of_minisites_visits__c.value;
  //             this.biData.invitedUsers = data.fields.BI_Data__r.value.fields.intent_num_of_invite_users__c.value;
  //             this.biData.Intent_Num_of_Keyword_Lists = data.fields.BI_Data__r.value.fields.Intent_Num_of_Keyword_Lists__c.value;
  //             this.biData.intent_num_of_package_page_visits = data.fields.BI_Data__r.value.fields.intent_num_of_package_page_visits__c.value;
  //             this.biData.pdfPngDownloads =
  //                 (data.fields.BI_Data__r.value.fields.intent_num_of_pdf_downloads__c?.value ?? 0) +
  //                 (data.fields.BI_Data__r.value.fields.intent_num_of_png_downloads__c?.value ?? 0);
  //             this.biData.dashboardsCreated = data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value;
  //
  //             // Process each field to get all values
  //             this.processField('pricingPageVisit', data.fields.BI_Data__r.value.fields.Intent_Pricing_Visits_Dates__c.value);
  //             this.processCombinedField('hooks',
  //                 data.fields.BI_Data__r.value.fields.Mrkt_Pro_Hook_Clicked__c.value,
  //                 data.fields.BI_Data__r.value.fields.Mrkt_Pro_Hook_Clicked_Dates__c.value);
  //             this.processField('handraises', data.fields.Contact_Us_Help_Timestamp__c.value);
  //             this.processField('premiumCenterVisits', data.fields.BI_Data__r.value.fields.Mrkt_Premium_Features_Dates__c.value);
  //             // this.processField('miniSitesVisits', data.fields.BI_Data__r.value.fields.intent_num_of_minisites_visits__c.value);
  //             // this.processField('dashboardsCreated', data.fields.BI_Data__r.value.fields.intent_num_of_dashboards__c.value);
  //             this.processField('pngDownloads', data.fields.BI_Data__r.value.fields.intent_num_of_png_downloads__c.value);
  //             // this.processField('pdfDownloads', data.fields.BI_Data__r.value.fields.intent_num_of_pdf_downloads__c.value);
  //             // this.processField('invitedUsers', data.fields.BI_Data__r.value.fields.intent_num_of_invite_users__c.value);
  //             this.processField('latestDomainsComparisons', data.fields.BI_Data__r.value.fields.Mrkt_Last_3_Compare_Websites__c.value, this.splitValuesSpecialCase);
  //             this.processField('latestKeywords', data.fields.BI_Data__r.value.fields.Mrkt_Last_3_Keyword_List__c.value);
  //             this.processField('topTrialSections', data.fields.BI_Data__r.value.fields.Intent_Trial_Section_and_Sub__c.value);
  //             this.processField('latestMiniSitesVisited', data.fields.BI_Data__r.value.fields.Intent_Minisite_Section_Visits__c.value);
  //             this.processField('Industries', data.fields.BI_Data__r.value.fields.Mrkt_Industries_Searched__c.value);
  //         }
  //
  //     } else if (error) {
  //         console.error('Error fetching BI_Data__c fields: ', error);
  //     }
  // }

  processCampaignMembers(fieldName, campaignMembers) {
    // Limit processing to 3 campaign members
    const limitedMembers = campaignMembers.slice(0, 3);
    let valueExist = limitedMembers.length > 0;
    this.openSections[fieldName] = valueExist ? fieldName : ""; // Only open sections with values

    // Process each campaign member to combine its fields
    const valuesArray = limitedMembers.map((member) => {
      const value1 = member.Campaign_Name__c || ""; // Get field1 value or default to empty string
      const value2 = this.formatDate(member.CreatedDate || ""); // Get field2 value or default to empty string
      const value3 = member.Status || ""; // Get field3 value or default to empty string

      // Combine the values into the desired format
      return `${value1} - ${value2} - ${value3}`;
    });
    this.biData[fieldName] = valueExist ? valuesArray : [];
    this.openSections[fieldName] = valueExist ? fieldName : "";
  }

  // Helper method to process a field and store all values in biData, handle 'NA' for empty fields
  processField(fieldName, fieldValue, splitFunction = this.splitValues) {
    const valuesArray = splitFunction.call(this, String(fieldValue || ""));
    let valueExist = valuesArray.length > 0 && valuesArray[0] !== "NA";
    this.biData[fieldName] = valueExist ? valuesArray : [];
    this.openSections[fieldName] = valueExist ? fieldName : ""; // Only open sections with values
  }

  // Helper method to process combined fields (e.g., hooks)
  processCombinedField(fieldName, fieldValue1, fieldValue2) {
    const combinedValues = this.combineFields(fieldValue1, fieldValue2);
    let valueExist = combinedValues.length > 0 && combinedValues[0] !== "NA";

    this.biData[fieldName] = valueExist ? combinedValues : [];
    this.openSections[fieldName] = valueExist ? fieldName : ""; // Only open sections with values
  }

  // Special case: Split with different delimiter logic (as needed)
  splitValuesSpecialCase(value) {
    if (!value) {
      return [];
    }
    const valuesArray = value.split(",");
    return valuesArray.map((val) => this.formatDate(val.trim()));
  }

  // Split a string using | as the delimiter
  splitValues(value) {
    if (!value) {
      return [];
    }
    const valuesArray = value.split("|");
    return valuesArray.map((val) => this.formatDate(val.trim()));
  }

  // Combine fields for the Hooks section
  combineFields(field1, field2) {
    const field1Values = this.splitValues(field1);
    const field2Values = this.splitValues(field2);
    return field1Values.map((value, index) => {
      const secondValue = field2Values[index] || "";
      return `${value} at ${secondValue}`;
    });
  }

  formatDate(value) {
    // Use a regex to match the first 10 characters of the date (YYYY-MM-DD)
    const dateMatch = value.match(/^\d{4}-\d{2}-\d{2}/);

    // If no valid date is found, return the value as is
    if (!dateMatch) {
      return value;
    }

    // Extract the matched date string (YYYY-MM-DD)
    const dateString = dateMatch[0];

    // Get today's date in the same format (YYYY-MM-DD)
    const today = new Date();
    const todayString = today.toISOString().slice(0, 10); // Get the first 10 chars of today's date

    // Get yesterday's date in the same format (YYYY-MM-DD)
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);
    const yesterdayString = yesterday.toISOString().slice(0, 10);

    // Compare the dateString with today's and yesterday's date strings
    if (dateString === todayString) {
      return "Today";
    } else if (dateString === yesterdayString) {
      return "Yesterday";
    }

    // If it's neither today nor yesterday, return the date in DD-MM-YYYY format
    const [year, month, day] = dateString.split("-");
    return `${day}-${month}-${year}`;
  }
}
