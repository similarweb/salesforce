import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { FlowNavigationNextEvent } from "lightning/flowSupport";

import getData from "@salesforce/apex/ProductTrackingController.getData";
import saveData from "@salesforce/apex/ProductTrackingController.saveData";

export default class ProductTracking extends LightningElement {
  upsellSubTypeOptions = [
    {
      label: "Upsell (New Paying Account)",
      value: "Upsell (New Paying Account)"
    },
    { label: "Upsell (Existing Account)", value: "Upsell (Existing Account)" }
  ];
  allSubTypeOptions = [];
  allPurchaseMotionOptions = [];

  @api recordId;
  // @api recordId = '006Pw00000IgPkPIAV';
  @api availableActions;

  @track allSolutions = [];
  @track solutions = [];
  @track type;
  @track subType;
  @track isAccActive;
  @track acquiredCompany;

  @track subTypeOptions = [];
  @track purchaseMotionOptions = [];
  @track showSubType = false;
  @track subTypeDisabled = false;

  @track load = false;
  @track checkSubTypeAvailability = false;
  @track hasAtLeast1SelectedProduct = false;

  connectedCallback() {
    getData({ recordId: this.recordId })
      .then((data) => {
        this.allSolutions = data.solutions;
        this.type = data.type;
        this.subType = data.subType;
        this.isAccActive = data.isAccActive;
        this.acquiredCompany = data.acquiredCompany;
        this.allSubTypeOptions = data.subTypeOptions;
        this.allPurchaseMotionOptions = data.purchaseMotionOptions;

        this.subTypeDisabled = this.subType != undefined;
        this.checkSubTypeAvailability =
          this.type !== "New Sale" &&
          this.type !== "Renewal" &&
          this.type !== "Upsell";

        if (this.type === "New Sale" || this.type === "Renewal") {
          this.subType = this.type;
        } else if (this.type === "Upsell") {
          this.subType = this.subType
            ? this.subType
            : this.isAccActive
              ? "Upsell (Existing Account)"
              : "Upsell (New Paying Account)";
          this.subTypeOptions = this.upsellSubTypeOptions;
          this.showSubType = true;
        } else {
          this.subTypeOptions = this.allSubTypeOptions;
          this.showSubType = true;
        }

        if (this.acquiredCompany) {
          this.subType = this.subType ? this.subType : "New Sale";
          this.showSubType = false;
        }

        this.solutions = this.filterSolutions();

        if (this.checkSubTypeAvailability === true) {
          this.subTypeDisabled = this.updateSubTypeAvailability();
          if (this.subTypeDisabled === true && !this.subType) {
            this.subType = data.defaultSubType;
            this.solutions = this.filterSolutions();
          }
        }
      })
      .catch((error) => {
        if (error.body) {
          this.showError(error.body.message + " " + error.body.stackTrace);
        } else {
          this.showError(error);
        }
      })
      .finally(() => {
        this.load = true;
      });
  }

  handleSave() {
    if (this.validateBody() !== "Success") {
      return;
    }
    this.load = false;

    let jsonInput = JSON.stringify({
      oppId: this.recordId,
      subType: this.subType,
      solutions: JSON.stringify(this.solutions)
    });

    saveData({ jsonInput: jsonInput })
      .then((data) => {
        if (data !== "Success") {
          this.showError(data);
        }
      })
      .catch((error) => {
        if (error.body) {
          this.showError(error.body.message + " " + error.body.stackTrace);
        } else {
          this.showError(error);
        }
      })
      .finally(() => {
        this.load = true;
        if (this.availableActions.find((action) => action === "NEXT")) {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent);
        }
      });
  }

  handleSubTypeChange(event) {
    this.subType = event.target.value;
    this.solutions = this.filterSolutions();
  }

  handlePurchaseMotionChange(event) {
    const solutionIndex = event.target.dataset.id,
      skuIndex = event.target.dataset.index,
      value = event.target.value;

    this.solutions[solutionIndex].products[this.subType][
      skuIndex
    ].purchaseMotion = value;
    this.solutions[solutionIndex].skus[skuIndex].purchaseMotion = value;
  }

  handleProductSelect(event) {
    const solutionIndex = event.target.dataset.id,
      skuIndex = event.target.dataset.index,
      checked = event.target.checked;

    this.solutions[solutionIndex].products[this.subType][skuIndex].selected =
      checked;
    this.solutions[solutionIndex].skus[skuIndex].selected = checked;

    if (
      ((checked === true && this.hasAtLeast1SelectedProduct === false) ||
        (checked === false && this.hasAtLeast1SelectedProduct === true)) &&
      this.checkSubTypeAvailability === true
    ) {
      this.subTypeDisabled = this.updateSubTypeAvailability();
    }
  }

  handleToggle(event) {
    const index = event.currentTarget.dataset.index,
      checked = event.currentTarget.checked;

    this.solutions[index].open = checked;
    if (checked === false) {
      this.deselectSKUs(index);
    }

    if (
      ((checked === true && this.hasAtLeast1SelectedProduct === false) ||
        (checked === false && this.hasAtLeast1SelectedProduct === true)) &&
      this.checkSubTypeAvailability === true
    ) {
      this.subTypeDisabled = this.updateSubTypeAvailability();
    }
  }

  updateSubTypeAvailability() {
    let hasAtLeast1SelectedProduct = false;

    this.solutions.forEach((s) => {
      if (s.open === true) {
        s.skus.forEach((sku) => {
          if (sku.selected === true) {
            hasAtLeast1SelectedProduct = true;
          }
        });
      }
    });

    this.hasAtLeast1SelectedProduct = hasAtLeast1SelectedProduct;
    return hasAtLeast1SelectedProduct;
  }

  validateBody() {
    if (!this.subType) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          variant: "warning",
          message: "Please select a Sub Type"
        })
      );
      return "Failure";
    }

    let emptySolutions = [],
      skusWithoutPurchaseMotion = [],
      noPriceProducts = [];
    this.solutions.forEach((s) => {
      if (s.open === true) {
        let hasAtLeast1SelectedProduct = false;
        s.skus.forEach((sku) => {
          if (sku.selected === true) {
            hasAtLeast1SelectedProduct = true;

            if (!sku.purchaseMotion) {
              skusWithoutPurchaseMotion.push(sku);
            }
            if (!(sku.unitPrice >= 0)) {
              noPriceProducts.push(sku.name);
            }
          }
        });
        if (hasAtLeast1SelectedProduct === false) {
          emptySolutions.push(s.name);
        }
        if (!(s.unitPrice >= 0)) {
          noPriceProducts.push(s.name);
        }
      }
    });

    if (emptySolutions.length > 0) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          variant: "warning",
          message:
            "Select at least one add-on / package for solutions: " +
            emptySolutions.join(", ")
        })
      );
      return "Failure";
    }

    if (skusWithoutPurchaseMotion.length > 0) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          variant: "warning",
          message: "Please choose the Purchase Motion for each selected add-on"
        })
      );
      return "Failure";
    }

    if (noPriceProducts.length > 0) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          variant: "warning",
          message:
            "Following selected products don't have a pricebook entry: " +
            noPriceProducts.join(", ") +
            ". Please deselect them or add to the pricebook"
        })
      );
      return "Failure";
    }

    return "Success";
  }

  deselectSKUs(index) {
    if (this.subType) {
      this.solutions[index].products[this.subType].forEach((p) => {
        p.selected = false;
      });
      this.solutions[index].skus.forEach((p) => {
        p.selected = false;
      });
    }
  }

  filterSolutions() {
    let solutions = this.subType
      ? this.allSolutions.filter((s) =>
          s.availableSubTypes.includes(this.subType)
        )
      : [];

    solutions.forEach((s) => {
      s.skus = this.subType ? s.products[this.subType] : [];

      s.skus.forEach((sku) => {
        if (
          this.acquiredCompany ||
          this.subType === "New Sale" ||
          this.subType === "Upsell (New Paying Account)"
        ) {
          sku.purchaseMotion = "New Product";
          sku.purchaseMotionDisabled = true;
          sku.purchaseMotionOptions = this.allPurchaseMotionOptions;
        }

        if (this.subType === "Renewal" && !this.acquiredCompany) {
          sku.purchaseMotion = "Renewal";
          sku.purchaseMotionDisabled = true;
          sku.purchaseMotionOptions = this.allPurchaseMotionOptions;
        }

        if (
          this.subType === "Upsell (Existing Account)" &&
          !this.acquiredCompany
        ) {
          sku.purchaseMotionDisabled = sku.purchaseMotion != undefined;
          sku.purchaseMotionOptions =
            sku.purchaseMotionOptions.length > 0
              ? sku.purchaseMotionOptions
              : this.allPurchaseMotionOptions;
        }
      });
    });

    return solutions;
  }

  showError(error) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error",
        variant: "error",
        message: error
      })
    );
  }
}
