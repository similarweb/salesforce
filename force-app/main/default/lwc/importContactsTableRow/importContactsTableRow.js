import { api, track, LightningElement } from "lwc";
import saveDraft from "@salesforce/apex/ImportContactsTableController.saveDraft";
import deleteDraft from "@salesforce/apex/ImportContactsTableController.deleteOneDraft";

const requiredFieldNames = [
  "AccountId",
  "Email",
  "FirstName",
  "LastName",
  "Title",
  "Department",
  "OriginalLeadSource",
  "Country"
];
const notRequiredFieldNames = [
  "Phone",
  "Mobile",
  "otherPhone",
  "linkedInProfile",
  "ContactId",
  "State",
  "City"
];
const countryWithRequiredStates = new Set(["United States", "Canada"]);

export default class ImportContactsTableRow extends LightningElement {
  @api tableItem;
  @api countryOptions;
  @api picklistOptions;
  picklistOptionsN;
  @api charLimits;
  @api index;
  @api currentPageItemsLength;
  fields;
  stateOptions;

  @track validMessages = {
    AccountId: {
      name: "Account Id",
      message: ""
    },
    Email: {
      name: "Email",
      message: ""
    },
    FirstName: {
      name: "First Name",
      message: ""
    },
    LastName: {
      name: "Last Name",
      message: ""
    },
    Title: {
      name: "Title",
      message: ""
    },
    Department: {
      name: "Department",
      message: ""
    },
    OriginalLeadSource: {
      name: "Original Lead Source",
      message: ""
    },
    Phone: {
      name: "Phone",
      message: ""
    },
    Mobile: {
      name: "Mobile",
      message: ""
    },
    Country: {
      name: "Country",
      message: ""
    },
    State: {
      name: "State",
      message: ""
    },
    City: {
      name: "City",
      message: ""
    },
    otherPhone: {
      name: "Other Phone",
      message: ""
    },
    linkedInProfile: {
      name: "LinkedIn Profile",
      message: ""
    },
    ContactId: {
      name: "Contact Id",
      message: "Add contact ID to update an existing contact"
    },
    UploadStatus: {
      name: "Upload Status",
      message: ""
    }
  };

  handleValid() {
    if (
      this.fields.AccountId != "" &&
      this.fields.Email != "" &&
      this.fields.FirstName != "" &&
      this.fields.LastName != "" &&
      this.fields.Title != "" &&
      this.fields.Department != "" &&
      this.fields.OriginalLeadSource != "" &&
      this.fields.Country != ""
    ) {
      let valid = true;
      for (const [key, value] of Object.entries(this.fields)) {
        if (key != "UploadStatus" && key != "draftId" && key != "isValid") {
          if (!this.validField(key, value)) {
            this.fields.UploadStatus = "Some of fields are invalid";
            console.log("this is not valid man- " + key + "- " + value);
            valid = false;
          } else {
            console.log("this is  valid man- " + key + "- " + value);
          }
        }
      }
      return valid;
    } else {
      for (const [key, value] of Object.entries(this.fields)) {
        if (key != "UploadStatus" && key != "draftId" && key != "isValid") {
          if (requiredFieldNames.find((elem) => elem == key) != undefined) {
            if (value == "") {
              if (
                key == "Department" ||
                key == "OriginalLeadSource" ||
                key == "Country"
              ) {
                this.template
                  .querySelector(`.picklist${key}`)
                  .classList.add("is_not_valid");
                this.validMessages[key].message =
                  `${this.validMessages[key].name} is empty`;
                this.fields.UploadStatus = "Some of fields are invalid";
              } else {
                this.template
                  .querySelector(`input[name=${key}]`)
                  .classList.add("is_not_valid");
                this.validMessages[key].message =
                  `${this.validMessages[key].name} is empty`;
                this.fields.UploadStatus = "Some of fields are invalid";
              }
            } else {
              if (!this.validField(key, value)) {
                this.fields.UploadStatus = "Some of fields are invalid";
              }
            }
          }
          if (notRequiredFieldNames.find((elem) => elem == key) != undefined) {
            this.validField(key, value);
          }
        }
      }
      return false;
    }
  }

  handleChange(event) {}

  renderedCallback() {
    let inputs = this.template.querySelector(".slds-input");
    if (!!inputs) {
      if (this.fields.draftId != "") {
        this.handleValid();
      }
    }
    console.log(
      "Component is rendered ",
      this.index,
      ": ",
      JSON.parse(JSON.stringify(this.fields))
    );
  }

  @api
  handleUpdate(fieldSet, pageNumber) {
    if (fieldSet != undefined) {
      if (
        JSON.parse(JSON.stringify(fieldSet)) !=
          JSON.parse(JSON.stringify(this.fields)) &&
        JSON.parse(JSON.stringify(fieldSet)).UploadStatus ==
          JSON.parse(JSON.stringify(this.fields)).UploadStatus &&
        JSON.parse(JSON.stringify(fieldSet)).draftId != ""
      ) {
        this.fields = JSON.parse(JSON.stringify(fieldSet));
        this.fields.isValid = this.handleValid();
        const saveDraftOnRefreshEvent = new CustomEvent("savedraftonrefresh", {
          detail: {
            pageNumber: pageNumber,
            fields: this.fields,
            draftId: this.fields.draftId,
            index: this.index - 1
          }
        });
        this.dispatchEvent(saveDraftOnRefreshEvent);
      } else {
        this.fields = JSON.parse(JSON.stringify(fieldSet));
      }
    }
  }

  validField(fieldName, fieldValue) {
    if (fieldName != "State" && fieldValue == "") {
      return true;
    }
    let regex;
    let valid;
    if (fieldName == "Email") {
      regex =
        /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    }
    // else if (fieldName == 'Phone' || fieldName == 'Mobile' || fieldName == 'otherPhone') { MIS-1304
    //     regex = /^[0-9$ )(\-+]+$/;
    // }
    else if (fieldName == "linkedInProfile") {
      regex =
        /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/;
    } else if (
      fieldName == "Title" ||
      fieldName == "FirstName" ||
      fieldName == "LastName"
    ) {
      regex = /^[a-zA-ZÀ-ú\-0-9$@$!%*?&#^-_.,/"'-/<>{}\[\]\=:;~` +]+$/;
    } else {
      regex = /^[a-zA-Z\-0-9$@$!%*?&#^-_. +]+$/;
    }
    if (
      fieldName == "Department" ||
      fieldName == "OriginalLeadSource" ||
      fieldName == "Country"
    ) {
      if (
        (fieldName == "Department" &&
          this.picklistOptions.DepartmentOptions.find(
            (elem) => elem.value == fieldValue
          ) != undefined) ||
        (fieldName == "OriginalLeadSource" &&
          this.picklistOptions.LeadSourceOptions.find(
            (elem) => elem.value == fieldValue
          ) != undefined) ||
        (fieldName == "Country" &&
          this.picklistOptions.CountryPicklistOptions.find(
            (elem) => elem.value == fieldValue
          ) != undefined)
      ) {
        this.template
          .querySelector(`.picklist${fieldName}`)
          .classList.remove("is_not_valid");
        this.validMessages[fieldName].message = ``;
        return true;
      } else {
        this.template
          .querySelector(`.picklist${fieldName}`)
          .classList.add("is_not_valid");
        this.validMessages[fieldName].message =
          `${this.validMessages[fieldName].name} is invalid`;
        return false;
      }
    }
    if (fieldName == "State") {
      this.template
        .querySelector(`.picklist${fieldName}`)
        .classList.remove("is_not_valid");
      this.validMessages[fieldName].message = ``;
      return true;
    }
    if (fieldName == "Phone") {
      let exactError = "#ERROR!";
      let containError = "e+";
      if (
        fieldValue != exactError &&
        !fieldValue.toLowerCase().includes(containError)
      ) {
        this.template
          .querySelector(`input[name=${fieldName}]`)
          .classList.remove("is_not_valid");
        this.validMessages[fieldName].message = ``;
        return true;
      } else {
        this.template
          .querySelector(`input[name=${fieldName}]`)
          .classList.add("is_not_valid");
        this.validMessages[fieldName].message =
          `${this.validMessages[fieldName].name} is invalid`;
        return false;
      }
    }
    valid = regex.test(String(fieldValue).toLowerCase());

    if (!valid) {
      this.template
        .querySelector(`input[name=${fieldName}]`)
        .classList.add("is_not_valid");
      this.validMessages[fieldName].message =
        `${this.validMessages[fieldName].name} is invalid`;
    } else {
      this.template
        .querySelector(`input[name=${fieldName}]`)
        .classList.remove("is_not_valid");
      this.validMessages[fieldName].message = ``;
    }

    return valid;
  }

  handleUpsert(event) {
    if (this.fields[event.target.name] != event.target.value) {
      if (event.target.name == "Country") {
        if (
          this.picklistOptionsN.CountryToStatePicklistMap.hasOwnProperty(
            event.target.value
          )
        ) {
          this.stateOptions =
            this.picklistOptionsN.CountryToStatePicklistMap[
              event.target.value
            ].stateList;
          this.fields.State = "";
          this.fields["Country"] = event.target.value;
        }
      } else {
        this.fields[event.target.name] = event.target.value;
      }

      this.fields.isValid = this.handleValid();
      saveDraft({ draftObjectJSON: JSON.stringify(this.fields) })
        .then((result) => {
          if (result.content != undefined) {
            this.fields = result.content;
            const saveDraftEvent = new CustomEvent("savedraft", {
              detail: {
                fields: result.content,
                draftId: this.fields.draftId,
                index: this.index - 1
              }
            });
            this.dispatchEvent(saveDraftEvent);
          }
          this.error = undefined;
        })
        .catch((error) => {
          console.log("savedraft error ", error);
          this.error = error;
        });
      console.log("Handle upsert fields ", this.fields);
    }
  }

  connectedCallback() {
    this.fields = JSON.parse(JSON.stringify(this.tableItem));
    this.index++;
    console.log(
      "Tab Item ",
      this.index - 1,
      ": ",
      JSON.parse(JSON.stringify(this.fields))
    );
    this.picklistOptionsN = JSON.parse(JSON.stringify(this.picklistOptions));
    this.stateOptions =
      this.picklistOptionsN.CountryToStatePicklistMap.hasOwnProperty(
        this.fields.Country
      )
        ? this.picklistOptionsN.CountryToStatePicklistMap[this.fields.Country]
            .stateList
        : {};

    if (this.index == 1) {
      const rowsLoadingEvent = new CustomEvent("rowsloading");
      this.dispatchEvent(rowsLoadingEvent);
    }
    const rowsLoadedEvent = new CustomEvent("rowsloaded");
    this.dispatchEvent(rowsLoadedEvent);
  }

  clearRow() {
    deleteDraft({ draftObjectJSON: JSON.stringify(this.fields) })
      .then((result) => {
        if (result.content != undefined) {
          console.log(
            "deleteDraft ",
            JSON.parse(JSON.stringify(result.content))
          );
          this.fields = result.content;
          const clearRowEvent = new CustomEvent("deleterow", {
            detail: {
              fields: result.content,
              draftId: this.fields.draftId,
              index: this.index
            }
          });
          this.dispatchEvent(clearRowEvent);
          this.removeRedBorder();
        }
        this.error = undefined;
      })
      .catch((error) => {
        console.log("deleteDraft error ", error);
        this.error = error;
      });
  }

  removeRedBorder() {
    let inputs = this.template.querySelectorAll(".is_not_valid");
    Array.prototype.forEach.call(inputs, function (item) {
      item.classList.remove("is_not_valid");
    });
  }
}
