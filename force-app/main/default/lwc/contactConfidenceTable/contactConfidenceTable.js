/**
 * Created by Alon.Shalev on 10/16/2023.
 */

import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { getFieldValue } from "lightning/uiRecordApi";

// Define the fields you need to pull in
const FIELDS = [
  "Contact.Name",
  "Contact.Account.SW_Industry_Confidence__c",
  "Contact.Account.Company_Size_Confidence__c",
  "Contact.Account.Website_Domain_Confidence__c",
  "Contact.Account.Country_Confidence__c",
  "Contact.Account.Parent_Company_HQ_Confidence__c",
  "Contact.Account.Average_Confidence_Score__c",
  "Contact.Account.Enrichment_Source__c",
  "Contact.Account.sw_connector_Website_Category__c",
  "Contact.Account.SW_Industry__c",
  "Contact.Account.Polygraph_Company_Employees_Estimated__c",
  "Contact.Account.sw_connector_Number_of_Employees__c",
  "Contact.Account.Employees_Min__c",
  "Contact.Account.Employees_Max__c",
  "Contact.Account.Website_Clearbit__c",
  "Contact.Account.sw_connector__swId__r.Name",
  "Contact.Account.Website",
  "Contact.Account.Polygraph_Company_Country_Name__c",
  "Contact.Account.sw_connector_Top_Traffic_Country__c",
  "Contact.Account.BillingCountry",
  "Contact.Account.sw_connector_Headquarters_Location__c",
  "Contact.Account.Parent_Company_HQ_Country__c"
];

export default class AccountConfidenceTable extends LightningElement {
  @api recordId;

  contactName;
  isCountryTooltipVisible = false;
  confidenceScore; // Define logic for mapping to one of 5 values
  swIndustryValue; // Placeholder; will be populated by data from the relevant field
  Company_size; // Placeholder; will be populated by data from the relevant field
  Website_Domain; // Placeholder; will be populated by data from the relevant field
  CountryValue; // Placeholder; will be populated by data from the relevant field
  Parent_company_HQ; // Placeholder; will be populated by data from the relevant field
  swConnectorWebsiteCategory;
  swIndustry;
  polygraphCountry;
  polygraphCompanyEmployeesEstimated;
  swConnectorNumberOfEmployees;
  employeesMin;
  employeesMax;
  websiteClearbit;
  swConnectorSwIdName;
  websiteValue;
  swTrafficCountry;
  polygraphCompanyCountryName;
  swConnectorTopTrafficCountry;
  billingCountryValue;
  swConnectorHeadquartersLocation;
  parentCompanyHQCountry;
  @track showDisclaimer = false;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  handleAccount({ error, data }) {
    if (data) {
      console.log(JSON.stringify(data));
      this.contactName = data.fields.Name.value;
      this.swIndustryValue = this.mapToConfidence(
        getFieldValue(data, "Contact.Account.SW_Industry_Confidence__c")
      );
      this.Company_size = this.mapToConfidence(
        getFieldValue(data, "Contact.Account.Company_Size_Confidence__c")
      );
      this.Website_Domain = this.mapToConfidence(
        getFieldValue(data, "Contact.Account.Website_Domain_Confidence__c")
      );
      this.CountryValue = this.mapToConfidence(
        getFieldValue(data, "Contact.Account.Country_Confidence__c")
      );
      this.Parent_company_HQ = this.mapToConfidence(
        getFieldValue(data, "Contact.Account.Parent_Company_HQ_Confidence__c")
      );
      // For tooltip hover fields
      this.swConnectorWebsiteCategory = getFieldValue(
        data,
        "Contact.Account.sw_connector_Website_Category__c"
      );
      this.swIndustry = getFieldValue(data, "Contact.Account.SW_Industry__c");
      this.polygraphCompanyEmployeesEstimated = getFieldValue(
        data,
        "Contact.Account.Polygraph_Company_Employees_Estimated__c"
      );
      this.polygraphCountry = getFieldValue(
        data,
        "Contact.Account.Polygraph_Company_Country_Name__c"
      );
      this.swConnectorNumberOfEmployees = getFieldValue(
        data,
        "Contact.Account.sw_connector_Number_of_Employees__c"
      );
      this.employeesMin = getFieldValue(
        data,
        "Contact.Account.Employees_Min__c"
      );
      this.employeesMax = getFieldValue(
        data,
        "Contact.Account.Employees_Max__c"
      );
      this.websiteClearbit = getFieldValue(
        data,
        "Contact.Account.Website_Clearbit__c"
      );
      this.swConnectorSwIdName = getFieldValue(
        data,
        "Contact.Account.sw_connector__swId__r.Name"
      );
      this.websiteValue = getFieldValue(data, "Contact.Account.Website");
      this.swTrafficCountry = getFieldValue(
        data,
        "Contact.Account.sw_connector_Top_Traffic_Country__c"
      );
      console.log("swTrafficCountry value: ", this.swTrafficCountry);
      this.polygraphCompanyCountryName = getFieldValue(
        data,
        "Contact.Account.Polygraph_Company_Country_Name__c"
      );
      this.swConnectorTopTrafficCountry = getFieldValue(
        data,
        "Contact.Account.sw_connector_Top_Traffic_Country__c"
      );
      this.billingCountryValue = getFieldValue(
        data,
        "Contact.Account.BillingCountry"
      );
      this.swConnectorHeadquartersLocation = getFieldValue(
        data,
        "Contact.Account.sw_connector_Headquarters_Location__c"
      );
      this.parentCompanyHQCountry = getFieldValue(
        data,
        "Contact.Account.Parent_Company_HQ_Country__c"
      );
      // Map the confidence score to one of 5 values based on your criteria here
      this.confidenceScore = this.mapToConfidence(
        getFieldValue(data, "Contact.Account.Average_Confidence_Score__c")
      );
      // if (data.fields.Enrichment_Source__c.value && data.fields.Enrichment_Source__c.value.includes('Enrichment Team')) {
      //     this.showDisclaimer = true;
      // } else {
      //     this.showDisclaimer = false;
      // }
    } else if (error) {
      console.error("Error fetching account data", error);
    }
  }

  mapToConfidence(rawValue) {
    let score;
    if (rawValue === null) {
      return "Missing Data"; // Or whatever message or value you want for null cases
    }
    let intValue = Math.floor(rawValue); // Convert to the nearest lower integer

    switch (intValue) {
      case 0:
        score = "Missing Data"; // This will handle values from 0 (inclusive) to 1 (exclusive)
        break;
      case 1:
        score = "Basic"; // This will handle values from 1 (inclusive) to 2 (exclusive)
        break;
      case 2:
        score = "Good"; // and so on...
        break;
      case 3:
        score = "High"; // This will handle values from 3 (inclusive) to 4 (exclusive)
        break;
      case 4:
        score = "Very High"; // This will handle exactly the value 4
        break;
      default:
        score = "Unknown"; // Just in case any unexpected values come through
        break;
    }

    return score;
  }

  get swIndustryValueClass() {
    return this.getScoreClass(this.swIndustryValue);
  }

  get CompanySizeClass() {
    return this.getScoreClass(this.Company_size);
  }

  get WebsiteDomainClass() {
    return this.getScoreClass(this.Website_Domain);
  }

  get CountryValueClass() {
    return this.getScoreClass(this.CountryValue);
  }

  get ParentCompanyHQClass() {
    return this.getScoreClass(this.Parent_company_HQ);
  }

  get totalConfidenceScoreClass() {
    return this.getScoreClass(this.confidenceScore);
  }

  getScoreClass(score) {
    if (score == "Missing Data") {
      return "slds-truncate score-missingData";
    } else if (score == "Basic") {
      return "slds-truncate score-Basic";
    } else if (score == "Good") {
      return "slds-truncate score-Good";
    } else if (score == "High") {
      return "slds-truncate score-High";
    } else if (score == "Very High") {
      return "slds-truncate score-Very-High";
    }
  }
}
