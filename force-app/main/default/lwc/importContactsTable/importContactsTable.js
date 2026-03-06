import { LightningElement, track, api } from "lwc";
import getPicklistsValues from "@salesforce/apex/ImportContactsTableController.getPicklistsValues";
import getContactFieldsCharLimits from "@salesforce/apex/ImportContactsTableController.getContactFieldsCharLimits";
import checkIfSandbox from "@salesforce/apex/ImportContactsTableController.checkIfSandbox";

export default class ImportContactsTable extends LightningElement {
  error;
  @track picklistOptions = [];
  charLimits = [];
  @api currentPageItems = [];
  isSandbox;
  loaded = false;
  isApexCodeCompleted = false;

  get _picklistOptions() {
    return JSON.parse(JSON.stringify(this.picklistOptions));
  }

  set _picklistOptions(newValue) {
    this.picklistOptions = newValue;
  }

  get _charLimits() {
    return JSON.parse(JSON.stringify(this.charLimits));
  }

  set _charLimits(newValue) {
    this.charLimits = newValue;
  }

  connectedCallback() {
    console.log("check currentPageItems", this.currentPageItems);
    getPicklistsValues()
      .then((result) => {
        console.log("getPicklistsValues ", result);
        this.picklistOptions = result.content;
        console.log(
          "ImportContactsTable -> connectedCallback -> picklistOptions",
          this._picklistOptions
        );
        this.error = undefined;
        this.isApexCodeCompleted = true;
      })
      .catch((error) => {
        this.error = error;
      });

    getContactFieldsCharLimits()
      .then((result) => {
        console.log("getContactFieldsCharLimits ", result);
        this.charLimits = result.content;
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
      });

    checkIfSandbox()
      .then((result) => {
        console.log("checkIfSandbox ", result);
        this.isSandbox = result.content;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  stopTimerLoad() {
    const rowsLoadedEvent = new CustomEvent("rowsloaded");
    this.dispatchEvent(rowsLoadedEvent);
  }

  startTimerLoad() {
    const rowsLoadingEvent = new CustomEvent("rowsloading");
    this.dispatchEvent(rowsLoadingEvent);
  }

  renderedCallback() {
    let testDiv = this.template.querySelector(".table_header");
    if (!!testDiv) {
      if (this.isSandbox) {
        testDiv.style.top = "135px";
      } else {
        testDiv.style.top = "100px";
      }
    }
    if (this.loaded) {
      console.log("Hello");
    }
    console.log("Component is rendered");
  }

  @api
  refreshRows(newTableItems, pageNumber) {
    let resourceRowList = this.template.querySelectorAll(
      "c-import-contacts-table-row"
    );
    Array.prototype.forEach.call(resourceRowList, (item, index) => {
      item.handleUpdate(newTableItems[index], pageNumber);
    });
  }

  @api
  refreshSpecialRow(fieldset, pageNumber) {
    let target = this.template.querySelector(`[data-id="${fieldset.draftId}"]`);
    if (target !== null) {
      target.handleUpdate(fieldset, pageNumber);
    }
  }

  saveDraftOnRefresh(event) {
    let eventObj = JSON.parse(JSON.stringify(event.detail));
    const saveDraftOnRefreshEvent = new CustomEvent("savedraftonrefresh", {
      detail: {
        pageNumber: eventObj.pageNumber,
        fields: eventObj.fields,
        draftId: eventObj.draftId,
        index: eventObj.index
      }
    });
    this.dispatchEvent(saveDraftOnRefreshEvent);
  }

  saveDraft(event) {
    let eventObj = JSON.parse(JSON.stringify(event.detail));
    const saveDraftEvent = new CustomEvent("savedraft", {
      detail: {
        fields: eventObj.fields,
        draftId: eventObj.draftId,
        index: eventObj.index
      }
    });
    this.dispatchEvent(saveDraftEvent);
  }

  deleteRowHandler(event) {
    let eventObj = JSON.parse(JSON.stringify(event.detail));
    const deleteSpecRowEvent = new CustomEvent("deletespecrow", {
      detail: {
        fields: eventObj.fields,
        draftId: eventObj.draftId,
        index: eventObj.index
      }
    });
    this.dispatchEvent(deleteSpecRowEvent);
  }
}
