import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import csvImport from "@salesforce/apex/ImportContactsTableController.csvImport";

export default class UploadCSVFile extends LightningElement {
  @api showModal;
  @api isDisabled = false;
  @track data;
  @track showLoadingSpinner = false;

  MAX_FILE_SIZE = 2000000; //Max file size 2.0 MB
  filesUploaded = [];
  filename;

  importcsv(event) {
    if (event.target.files.length > 0) {
      this.filesUploaded = event.target.files;
      this.filename = event.target.files[0].name;
      console.log(this.filename);
      if (this.filesUploaded.size > this.MAX_FILE_SIZE) {
        this.filename = "File Size is to long to process";
      }
      this.isDisabled = false;
    }
  }

  readFiles() {
    if (this.template.querySelector("lightning-input").files != null) {
      this.isDisabled = true;
      const rowsLoadingEvent = new CustomEvent("rowsloading");
      this.dispatchEvent(rowsLoadingEvent);
      this.onCloseButtonClick();
      [...this.template.querySelector("lightning-input").files].forEach(
        async (file) => {
          try {
            const result = await this.load(file);
            console.log("result ", result);
            console.log("file ", file);
            csvImport({ jsonCsv: result })
              .then((result) => {
                console.log("csvImport ", result);
                if (!!result.content && result.content.length > 0) {
                  const importDraftsEvent = new CustomEvent("importdrafts", {
                    detail: {
                      drafts: result.content,
                      message: result.message
                    }
                  });
                  this.dispatchEvent(importDraftsEvent);
                }
              })
              .catch((error) => {
                console.log("csvImport error ", error);
                this.error = error;
              });
            // Process the CSV here
            this.showLoadingSpinner = false;
            console.log(result);
            this.data = JSON.parse(this.csvJSON(result));
            // console.log('data..'+JSON.parse(this.data));
          } catch (e) {
            // handle file load exception
            console.log("exception....");
          }
        }
      );
    } else {
      const event = new ShowToastEvent({
        title: "Error",
        message: "You have to upload a file!",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(event);
    }
  }

  async load(file) {
    return new Promise((resolve, reject) => {
      this.showLoadingSpinner = true;
      const reader = new FileReader();
      // Read file into memory as UTF-8
      //reader.readAsText(file);
      reader.onload = function () {
        resolve(reader.result);
      };
      reader.onerror = function () {
        reject(reader.error);
      };
      reader.readAsText(file);
    });
  }

  //process CSV input to JSON

  csvJSON(csv) {
    var lines = csv.split(/\r\n|\n/);

    var result = [];

    var headers = lines[0].split(",");
    console.log("headers.." + JSON.stringify(headers));
    for (var i = 1; i < lines.length - 1; i++) {
      var obj = {};
      var currentline = lines[i].split(",");

      for (var j = 0; j < headers.length; j++) {
        obj[headers[j]] = currentline[j];
      }

      result.push(obj);
    }
    console.log("result.." + JSON.stringify(result));
    //return result; //JavaScript object
    return JSON.stringify(result); //JSON
  }

  onCloseButtonClick() {
    this.showModal = false;
    const closeEvent = new CustomEvent("close", {
      detail: {
        showModal: false
      }
    });
    this.dispatchEvent(closeEvent);
  }
}
