import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getHierarchyData from "@salesforce/apex/AccountHierarchyDataCtrl.getHierarchyData";

const FIELDS = [
  "Account.Parent_Company_Domain__c",
  "Account.Website_Domain__c"
];

export default class HierarchyData extends LightningElement {
  @api recordId; // This will be automatically populated with the current record ID
  parentCompanyDomain;
  websiteDomain;
  @track gridColumns = [
    { type: "text", fieldName: "Name", label: "Account Name" },
    { type: "text", fieldName: "Status__c", label: "Account STATUS" },
    { type: "text", fieldName: "BillingCountry", label: "Country" },
    {
      type: "text",
      fieldName: "Number_of_Open_Opps__c",
      label: "Number Of Open opps"
    },
    { type: "text", fieldName: "Website", label: "Website" },
    { type: "Date", fieldName: "LastActivityDate", label: "LastActivityDate" },
    { type: "text", fieldName: "OwnerName", label: "owner name" },
    { type: "text", fieldName: "Base_Product__c", label: "Base Product" }
  ];
  @track gridData = [];
  @track data = {};
  @track expandedRows = [];

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredAccount({ error, data }) {
    if (data) {
      this.parentCompanyDomain = getFieldValue(
        data,
        "Account.Parent_Company_Domain__c"
      );
      this.websiteDomain = getFieldValue(data, "Account.Website_Domain__c");
      this.fetchHierarchyData();
    } else if (error) {
      console.error("Error fetching account data:", error);
    }
  }

  fetchHierarchyData() {
    if (this.parentCompanyDomain || this.websiteDomain) {
      getHierarchyData({
        parentCompanyDomain: this.parentCompanyDomain,
        websiteDomain: this.websiteDomain,
        accountId: this.recordId
      })
        .then((result) => {
          this.data = result;
          this.gridData = this.transformData([result.gridDataFromApex]);
          console.log("this grid data = " + JSON.stringify(this.gridData));
          this.setExpandedRows();
          console.log(JSON.stringify(this.expandedRows));
          console.log(
            "Transformed Data:",
            JSON.stringify(this.gridData, null, 2)
          );
        })
        .catch((error) => {
          console.error("Error fetching hierarchy data:", error);
        });
    }
  }

  transformData(data) {
    const transformNode = (node) => {
      const transformedNode = {
        Id: node.Id,
        Name: node.Name,
        Status__c: node.Status__c,
        BillingCountry: node.BillingCountry,
        Number_of_Open_Opps__c: node.Number_of_Open_Opps__c,
        Website: node.Website,
        LastActivityDate: node.LastActivityDate,
        OwnerName: node.OwnerName,
        Base_Product__c: node.Base_Product__c,
        isExposed: node.isExposed
      };

      if (node._children && node._children.length > 0) {
        transformedNode._children = node._children.map(transformNode);
      }

      return transformedNode;
    };

    return data.map(transformNode);
  }
  setExpandedRows() {
    this.expandedRows = this.gridData
      .filter((element) => element.isExposed)
      .map((element) => element.Id);
  }
}
