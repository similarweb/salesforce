import { LightningElement, track } from "lwc";
import getDraftRecords from "@salesforce/apex/ImportContactsTableController.getDraftRecords";
import importContacts from "@salesforce/apex/ImportContactsTableController.importContacts";
import deleteDrafts from "@salesforce/apex/ImportContactsTableController.deleteDrafts";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
const ERROR_TITLE = "Error";
const ERROR_MESSAGE = "Something wrong!";
const ERROR_VARIANT = "error";
const SUCCESS_TITLE = "Success";
const SUCCESS_MESSAGE =
  "Contact import has been started! Please, expect email once it is done.";
const SUCCESS_VARIANT = "success";
const SUCCESS_DELETE_MESSAGE = "Drafts are successfully deleted!";
const WARNING_VARIANT = "warning";
const WARNING_MESSAGE =
  "Contact import has been started but it looks like something wrong with some of contacts! Please check it!";
const WARNING_TITLE = "Warning";
const BASE_VARIANT = "base";
const BASE_MESSAGE =
  "Contact import has been started! Please, expect email once it is done.";
const BASE_TITLE = "Process started";

export default class ImportContactsTableWrapper extends LightningElement {
  tableItems = [];
  @track pages = [];
  @track numberOfPages = [{ label: "-- none --", value: "" }];
  @track value;
  @track currentPageItems = [];
  @track isLoaded = false;

  get _currentPageItems() {
    return JSON.parse(JSON.stringify(this.currentPageItems));
  }

  set _currentPageItems(newValue) {
    this.currentPageItems = newValue;
  }

  showModal = false;
  disabledImportButton = false;
  currentPageNumber = 0;
  error;
  number;
  isRefreshDraftsFromCSV = false;
  isLoadedImport = true;
  seconds = 0;
  intervalId;

  connectedCallback() {
    getDraftRecords()
      .then((result) => {
        console.log("getDraftRecords ", result);
        this.tableItems = JSON.parse(JSON.stringify(result.content));
        this.pages = this.handlePageSort(this.tableItems);
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  startTimerLoad() {
    this.isLoaded = false;
    console.log(
      "ImportContactsTableWrapper -> startTimerLoad -> this.isLoaded",
      this.isLoaded
    );
  }

  stopTimerLoad() {
    this.isLoaded = true;
    console.log(
      "ImportContactsTableWrapper -> stopTimerLoad -> this.isLoaded",
      this.isLoaded
    );
  }

  renderedCallback() {
    console.log(
      "Render check",
      this._currentPageItems,
      " Pages ",
      JSON.parse(JSON.stringify(this.pages))
    );
  }

  onAddRowClick() {
    this.tableItems.push({
      AccountId: "",
      Email: "",
      FirstName: "",
      LastName: "",
      Title: "",
      Department: "",
      OriginalLeadSource: "",
      Phone: "",
      Mobile: "",
      Country: "",
      ContactId: "",
      linkedInProfile: "",
      otherPhone: "",
      isValid: "",
      UploadStatus: "",
      draftId: ""
    });
    this.pages = this.handlePageSort(this.tableItems);
  }

  handlePageSort(items) {
    let start;
    let end;
    let pages = [];
    let pagesOptions = [];
    for (let i = 0; i < Math.ceil(items.length / 250); i++) {
      i == 0 ? (start = 0) : (start = end);
      end = items.length < (i + 1) * 250 ? items.length : (i + 1) * 250;
      console.log("start ", start, ", end ", end);
      pages.push({
        pageNumber: i,
        items: [...this.tableItems.slice(start, end)]
      });
      pagesOptions.push({
        label: `${i + 1} page`,
        value: i
      });
    }
    this.numberOfPages = [...pagesOptions];
    this.currentPageItems = JSON.parse(
      JSON.stringify(
        pages.find((elem) => elem.pageNumber == this.currentPageNumber).items
      )
    );
    console.log("Pages ", JSON.parse(JSON.stringify(pages)));
    console.log(
      "Number of pages ",
      JSON.parse(JSON.stringify(this.numberOfPages))
    );
    return pages;
  }

  handlePageChange(event) {
    this.value = event.target.value;
    this.currentPageItems = this.pages.find(
      (elem) => elem.pageNumber == this.value
    ).items;
    this.currentPageNumber = this.value;
    console.log(
      "Current page ",
      this.currentPageNumber,
      "Current page items ",
      JSON.parse(JSON.stringify(this.currentPageItems))
    );
  }

  refreshAllRows() {
    for (let j = 0; j < this.pages.length; j++) {
      this.refreshRows(this.pages[j].items, j);
    }
  }

  refreshSpecialRows(items) {
    if (items.length > 0) {
      for (let i = 0; i < items.length; i++) {
        let resourceRowList = this.template.querySelectorAll(
          "c-import-contacts-table"
        );
        resourceRowList[0].refreshSpecialRow(items[i], this.currentPageNumber);
      }
    }
  }

  onImportContactsClick() {
    let err = false;
    let validTableItems = [];
    let invalidTableItems = [];
    this.isLoaded = false;
    this.refreshAllRows();
    for (let j = 0; j < this.pages.length; j++) {
      for (let i = 0; i < this.pages[j].items.length; i++) {
        if (this.pages[j].items[i].draftId == "") {
          console.log("This item is empty");
        } else if (!this.pages[j].items[i].isValid) {
          console.log("This item is invalid", j, " page");
          if (this.pages[j].items[i].UploadStatus == "") {
            this.pages[j].items[i].UploadStatus = "Some of fields are invalid!";
          }
          invalidTableItems.push(this.pages[j].items[i]);
          err = true;
        } else {
          console.log("This item is okay");
          this.pages[j].items[i].UploadStatus = "";
          validTableItems.push(this.pages[j].items[i]);
        }
        console.log(JSON.parse(JSON.stringify(this.pages[j].items[i])));
      }
    }

    if (
      this.pages[this.currentPageNumber].pageNumber == this.currentPageNumber &&
      err
    ) {
      this.isLoaded = false;
      this.refreshSpecialRows(invalidTableItems);
      // this.refreshAllRows();
    }

    if (err && validTableItems.length == 0) {
      const event = new ShowToastEvent({
        title: ERROR_TITLE,
        message: ERROR_MESSAGE,
        variant: ERROR_VARIANT,
        mode: "dismissable"
      });
      this.dispatchEvent(event);
      this.isLoaded = true;
    } else {
      console.log(
        "validTableItems ",
        JSON.parse(JSON.stringify(validTableItems))
      );
      console.log(
        "JSON ",
        JSON.stringify(validTableItems),
        "JSON Length",
        JSON.stringify(validTableItems).length
      );
      if (validTableItems.length == 0 && invalidTableItems.length == 0) {
        const event = new ShowToastEvent({
          title: ERROR_TITLE,
          message: "All rows are empty! Please, fill at least one row!",
          variant: ERROR_VARIANT,
          mode: "dismissable"
        });
        this.dispatchEvent(event);
        this.isLoaded = true;
      } else {
        importContacts({
          contactsToImportJSON: JSON.stringify(validTableItems)
        })
          .then((result) => {
            console.log("importContacts ", result);
            if (result.content && result.message == "") {
              let itemsFromApex = [];
              let newItemsToSort = JSON.parse(JSON.stringify(result.content));

              for (let i = 0; i < newItemsToSort.length; i++) {
                if (newItemsToSort[i].draftId != "") {
                  itemsFromApex.push(newItemsToSort[i]);
                }
              }

              if (itemsFromApex.length > 0) {
                const event = new ShowToastEvent({
                  title: WARNING_TITLE,
                  message: WARNING_MESSAGE,
                  variant: WARNING_VARIANT,
                  mode: "dismissable"
                });
                this.dispatchEvent(event);
              } else {
                const event = new ShowToastEvent({
                  title: BASE_TITLE,
                  message: BASE_MESSAGE,
                  variant: BASE_VARIANT,
                  mode: "dismissable"
                });
                this.dispatchEvent(event);
              }

              if (invalidTableItems.length > 0) {
                for (let i = 0; i < invalidTableItems.length; i++) {
                  for (let j = 0; j < newItemsToSort.length; j++) {
                    if (newItemsToSort[j].draftId == "") {
                      newItemsToSort.splice(j, 1, invalidTableItems[i]);
                      break;
                    }
                  }
                }
              }

              this.tableItems = JSON.parse(JSON.stringify(newItemsToSort));
              this.pages = [...this.handlePageSort(this.tableItems)];

              this.refreshSpecialRows(newItemsToSort);
              this.isLoaded = true;
            } else {
              const event = new ShowToastEvent({
                title: "Error",
                message: result.message,
                variant: ERROR_VARIANT,
                mode: "dismissable"
              });
              this.dispatchEvent(event);
              if (result.content) {
                let newItemsToSort = JSON.parse(JSON.stringify(result.content));
                this.tableItems = JSON.parse(JSON.stringify(newItemsToSort));
                this.pages = [...this.handlePageSort(this.tableItems)];
                this.refreshSpecialRows(newItemsToSort);
                // this.refreshAllRows();
              }

              this.isLoaded = true;
            }
            this.error = undefined;
          })
          .catch((error) => {
            console.log("importContacts error ", error);
            this.error = error;
            this.isLoaded = true;
          });
      }
    }
  }

  refreshRows(newTableItems, pageNumber) {
    let resourceRowList = this.template.querySelectorAll(
      "c-import-contacts-table"
    );
    resourceRowList[0].refreshRows(newTableItems, pageNumber);
  }

  refreshSpecialRow(newTableItem, pageNumber, index) {
    let resourceRowList = this.template.querySelectorAll(
      "c-import-contacts-table"
    );
    resourceRowList[0].refreshSpecialRow(newTableItem, pageNumber, index);
  }

  saveDraftOnRefresh(event) {
    console.log("saveDraftOnRefresh on import table wrapper");
    let eventObj = JSON.parse(JSON.stringify(event.detail));
    let index = this.pages[eventObj.pageNumber].items
      .map(function (e) {
        return e.draftId;
      })
      .indexOf(eventObj.draftId);
    if (index != -1) {
      this.pages[eventObj.pageNumber].items.splice(index, 1, eventObj.fields);
      this.tableItems.splice(index, 1, eventObj.fields);
      console.log(
        "pages after refresh",
        JSON.parse(JSON.stringify(this.pages))
      );
    } else {
      this.pages[eventObj.pageNumber].items.splice(
        eventObj.index,
        1,
        eventObj.fields
      );
      this.tableItems.splice(eventObj.index, 1, eventObj.fields);
      this.currentPageItems.splice(eventObj.index, 1, eventObj.fields);
      console.log(
        "pages after refresh",
        JSON.parse(JSON.stringify(this.pages))
      );
    }
  }

  saveDraft(event) {
    let eventObj = JSON.parse(JSON.stringify(event.detail));
    let index = this.pages[this.currentPageNumber].items
      .map(function (e) {
        return e.draftId;
      })
      .indexOf(eventObj.draftId);
    if (index != -1) {
      this.pages[this.currentPageNumber].items.splice(
        index,
        1,
        eventObj.fields
      );
      this.tableItems.splice(index, 1, eventObj.fields);
      this.pages = [...JSON.parse(JSON.stringify(this.pages))];
      console.log("pages ", JSON.parse(JSON.stringify(this.pages)));
    } else {
      this.pages[this.currentPageNumber].items[eventObj.index] = JSON.parse(
        JSON.stringify(eventObj.fields)
      );
      this.tableItems.splice(eventObj.index, 1, eventObj.fields);

      this.currentPageItems.splice(eventObj.index, 1, eventObj.fields);
      this.pages = [...JSON.parse(JSON.stringify(this.pages))];
      console.log("pages ", JSON.parse(JSON.stringify(this.pages)));
    }
  }

  deleteSpecificRow(event) {
    let eventObj = JSON.parse(JSON.stringify(event.detail));
    let index = eventObj.index - 1;
    console.log("deleteSpecificRow index ", index);
    console.log("passed index ", eventObj.index);
    if (index != -1) {
      this.pages[this.currentPageNumber].items.splice(
        index,
        1,
        eventObj.fields
      );
      this.pages = [...JSON.parse(JSON.stringify(this.pages))];
    }
  }

  closeModal(event) {
    let eventObj = JSON.parse(JSON.stringify(event.detail));
    this.showModal = eventObj.showModal;
  }

  openModal() {
    this.showModal = true;
    this.disabledImportButton = false;
  }

  importDraftsFromCSV(event) {
    this.isLoaded = false;
    let eventObj = JSON.parse(JSON.stringify(event.detail.drafts));
    let evntIndex = 0;
    for (let i = 0; i < this.tableItems.length; i++) {
      if (this.tableItems[i].draftId == "") {
        if (evntIndex <= eventObj.length - 1) {
          this.tableItems.splice(i, 1, eventObj[evntIndex]);
          evntIndex++;
        } else {
          break;
        }
      }
    }
    for (let i = 0; i < eventObj.length; i++) {
      if (evntIndex <= eventObj.length - 1) {
        this.tableItems.push(JSON.parse(JSON.stringify(eventObj[evntIndex])));
        evntIndex++;
      } else {
        break;
      }
    }
    this.pages = [...this.handlePageSort(this.tableItems)];
    // this.refreshSpecialRows(JSON.parse(JSON.stringify(this.tableItems)));
    const event1 = new ShowToastEvent({
      title: "Success",
      message: event.detail.message
        ? event.detail.message
        : "Contacts are successfully imported from CSV",
      variant: "success",
      mode: "dismissable"
    });
    this.dispatchEvent(event1);
  }

  deleteAllDrafts() {
    this.isLoaded = false;
    let draftsToDelete = [];
    for (let j = 0; j < this.pages.length; j++) {
      for (let i = 0; i < this.pages[j].items.length; i++) {
        console.log(
          "pages items[i] ",
          JSON.parse(JSON.stringify(this.pages[j].items[i]))
        );
        if (this.pages[j].items[i].draftId == "") {
          console.log("This item is empty");
        } else {
          draftsToDelete.push(this.pages[j].items[i]);
        }
      }
    }
    if (draftsToDelete.length > 0) {
      deleteDrafts({ contactsToImportJSON: JSON.stringify(draftsToDelete) })
        .then((result) => {
          console.log("deleteDrafts ", result);
          if (result.content.length > 0) {
            const event = new ShowToastEvent({
              title: SUCCESS_TITLE,
              message: SUCCESS_DELETE_MESSAGE,
              variant: SUCCESS_VARIANT,
              mode: "dismissable"
            });
            this.dispatchEvent(event);
            this.tableItems = JSON.parse(JSON.stringify(result.content));
            this.pages = this.handlePageSort(
              JSON.parse(JSON.stringify(this.tableItems))
            );
          }
        })
        .catch((error) => {
          console.log("deleteDrafts error ", error);
          this.error = error;
          this.isLoaded = true;
        });
    } else {
      const event = new ShowToastEvent({
        title: ERROR_TITLE,
        message: "All rows are already empty!",
        variant: ERROR_VARIANT,
        mode: "dismissable"
      });
      this.dispatchEvent(event);
      this.isLoaded = true;
    }
  }
}
