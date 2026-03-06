({
  doInit: function (cmp, event, helper) {
    var action = cmp.get("c.getOpportunityDetails");
    action.setParams({ oppId: cmp.get("v.recordId") });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        debugger;
        var resp = response.getReturnValue();
        if (resp.success) {
          var opp = resp.content["opportunity"];
          //opp.Section_in_PRO_w_accuracy_issues__c= '';
          opp.Missing_Data_or_Feature__c = "";
          opp.CSA_Satisfaction_Score__c = "";
          cmp.set("v.isShowCSA", resp.content["oppRequests"]);
          var accIssues = cmp.get(
            "v.fieldDetails.Opportunity.Section_in_PRO_w_accuracy_issues__c"
          );
          accIssues.push({
            value: "Desktop visits & engagement",
            label: "Desktop visits & engagement"
          });
          accIssues.push({
            value: "Desktop traffic channels",
            label: "Desktop traffic channels"
          });
          accIssues.push({
            value: "Mobile web visits & engagement",
            label: "Mobile web visits & engagement"
          });
          accIssues.push({
            value: "Mobile web traffic channels",
            label: "Mobile web traffic channels"
          });
          accIssues.push({
            value: "Android app metrics",
            label: "Android app metrics"
          });
          accIssues.push({
            value: "iOS app metrics",
            label: "iOS app metrics"
          });
          accIssues.push({
            value: "Search keywords",
            label: "Search keywords"
          });
          accIssues.push({ value: "Referral", label: "Referral" });
          accIssues.push({ value: "Display ad", label: "Display ad" });
          accIssues.push({ value: "Social", label: "Social" });
          accIssues.push({
            value: "DI and conversion",
            label: "DI and conversion"
          });
          accIssues.push({ value: "Other", label: "Other" });
          cmp.set(
            "v.fieldDetails.Opportunity.Section_in_PRO_w_accuracy_issues__c",
            accIssues
          );
          cmp.set("v.opportunity", opp);

          if (
            opp.Competitor_Product__c &&
            opp.Competitor_Product__c.split(";").indexOf("Other") != -1
          )
            cmp.set("v.showOtherCompetitorProduct", true);

          var relevantReasons = [];

          var allReasons = cmp.get(
            "v.fieldDetails.Opportunity.Closed_Lost_Reason__c"
          );
          for (var i = 0; i < allReasons.length; i++) {
            if (allReasons[i].oppTypes.indexOf(opp.Type) != -1) {
              relevantReasons.push(allReasons[i]);
            }
          }
          cmp.set(
            "v.fieldDetails.Opportunity.Closed_Lost_Reason__c",
            relevantReasons
          );
          var solutionFit = resp.content["solutionFit"]
            ? resp.content["solutionFit"]
            : [];
          if (opp.Use_Cases__c) {
            solutionFit.push(...opp.Use_Cases__c.split(";"));
          }
          cmp.set("v.selectedSolutionFit", solutionFit);
          if (
            opp.IsClosed ||
            (opp.Type != "Renewal" &&
              opp.Type != "New Sale" &&
              opp.Type != "Upsell")
          ) {
            cmp.set("v.canBeShown", false);
          }
          if (opp.Type == "Renewal" && opp.Original_Renewal_Date__c) {
            cmp.set(
              "v.formattedRenewalDate",
              helper.formatDate(opp.Original_Renewal_Date__c)
            );
          }
          if (opp.Closed_Lost_Reason__c)
            helper.setCheckedReasons(cmp, opp.Closed_Lost_Reason__c);
          if (opp.Competitor_Product__c)
            helper.setCheckedCompetitorProds(cmp, opp.Competitor_Product__c);
          helper.setDefault(cmp, opp);
        }
      } else {
      }
    });
    helper.initiateFields(cmp, action);
    //$A.enqueueAction(action);
  },

  handleClosedLostChange: function (cmp, event, helper) {
    var selectedClosedReasons = cmp.get("v.selectedClosedReasons");
    /*var newVal = event.target.value;
        var checked = event.target.checked;
        if (checked) {
            if (selectedClosedReasons && selectedClosedReasons.length == 2) {
                helper.showToast('warning', undefined, 'Maximum 2 reasons are allowed');
            }else {
                selectedClosedReasons.push(newVal);
                cmp.set('v.selectedClosedReasons', selectedClosedReasons);
            }
        } else {
            if (selectedClosedReasons.indexOf(newVal) != -1) {
                selectedClosedReasons.slice(selectedClosedReasons.indexOf(newVal), 1);
            }
        }*/
    var isChecked = event.getSource().get("v.value");
    var newVal = event.getSource().get("v.text");
    if (
      !isChecked &&
      newVal &&
      selectedClosedReasons &&
      selectedClosedReasons.indexOf(newVal) != -1
    ) {
      selectedClosedReasons.splice(selectedClosedReasons.indexOf(newVal), 1);
      cmp.set("v.selectedClosedReasons", selectedClosedReasons);
    } else {
      if (selectedClosedReasons && selectedClosedReasons.length == 2) {
        event.getSource().set("v.value", false);
        helper.showToast(
          cmp.get("v.isLEX"),
          "warning",
          undefined,
          "You have selected more than two closed lost reasons. Please select up to two reasons and try again"
        );
      } else {
        selectedClosedReasons.push(newVal);
        cmp.set("v.selectedClosedReasons", selectedClosedReasons);
      }
    }
    helper.cleanClosedReasons(cmp);
  },

  reasonIsChecked: function (cmp, event, helpert) {
    var selected = cmp.get("v.opportunity.Closed_Lost_Reasons__c");
  },

  submit: function (cmp, event, helper) {
    debugger;
    cmp.set("v.isProcessing", true);

    if (cmp.get("v.newCyclePrice"))
      cmp.set("v.opportunity.Cycle_Price__c", cmp.get("v.newCyclePrice"));

    if (cmp.get("v.newCycle"))
      cmp.set("v.opportunity.Cycle__c", cmp.get("v.newCycle"));

    var closedLostReasons = cmp.get("v.selectedClosedReasons").join(";");
    var solutionFit = cmp.get("v.selectedSolutionFit")
      ? cmp.get("v.selectedSolutionFit").join(";")
      : "";
    var competitorProducts = cmp.get("v.selectedCopetitorProducts");
    var competitorProduct = "";
    for (var i = 0; i < competitorProducts.length; i++) {
      competitorProduct += competitorProducts[i].value + ";";
    }

    var opport = cmp.get("v.opportunity");
    //opport.Closed_Lost_Reasons__c = closedLostReasons;
    opport.Closed_Lost_Reason__c = closedLostReasons;
    opport.Use_Cases__c = solutionFit;
    opport.Competitor_Product__c = competitorProduct;

    delete opport["Account"];
    delete opport["Contact"];

    if (competitorProduct.indexOf("Other") == -1) {
      opport.Other_Competitors__c = "";
    }

    var action = cmp.get("c.submitOpportunity");
    action.setParams({ jsonOpp: JSON.stringify(opport) });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resp = response.getReturnValue();
        if (resp.success) {
          helper.showToast(
            cmp.get("v.isLEX"),
            "success",
            undefined,
            "Opportunity closed successfully"
          );
          /*if (cmp.get('v.isLEX')){
                                var eUrl= $A.get("e.force:navigateToURL");
                                eUrl.setParams({
                                  "url": '/' + cmp.get('v.recordId')
                                });
                                eUrl.fire();
                        } else {*/
          window.location = "/" + cmp.get("v.recordId");
          //}
        } else {
          helper.showToast(
            cmp.get("v.isLEX"),
            "error",
            undefined,
            "Error happened : " + resp.message
          );
        }
        cmp.set("v.isProcessing", false);
      } else {
        cmp.set("v.isProcessing", false);
      }
    });

    $A.enqueueAction(action);
  },

  closeSubmitModal: function (cmp, event, helper) {
    cmp.set("v.showConfirmationModal", false);
  },

  openSubmitModal: function (cmp, event, helper) {
    debugger;
    var isValid = helper.validateOpp(cmp);

    if (isValid) {
      cmp.set("v.showConfirmationModal", true);
    } else {
      cmp.set("v.isProcessing", false);
    }
  },

  cancelFlow: function (cmp, event, helper) {
    var isLEX = cmp.get("v.isLEX");

    if (isLEX) {
      /*var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId":  cmp.get('v.recordId')
            });
            navEvt.fire();*/
      window.location =
        "/lightning/r/Opportunity/" + cmp.get("v.recordId") + "/view";
    } else {
      window.location = "/" + cmp.get("v.recordId");
    }
  },

  showCancelationModal: function (cmp, event, helper) {
    cmp.set("v.showCancelationModel", true);
  },

  noCancelation: function (cmp, event, helper) {
    cmp.set("v.showCancelationModel", false);
  },

  hideSpinner: function (cmp) {
    cmp.set("v.Spinner", false);
  },

  showSpinner: function (cmp) {
    cmp.set("v.Spinner", true);
  },

  selectCompetitorProduct: function (cmp, event) {
    var selectedCopetitorProducts = [];
    var value = event.target.value;
    if (
      cmp.get("v.selectedCopetitorProducts") &&
      cmp.get("v.selectedCopetitorProducts").length == 3
    ) {
      event.target.selected = false;
      alert(
        "You have selected more than three competitor products. Please select up to three products and try again."
      );
      return;
    }
    var selectElem = cmp.find("compet-product").getElement();
    var options = selectElem.options;
    for (var i = 0; i < options.length; i++) {
      if (options[i].selected) {
        selectedCopetitorProducts.push(options[i].value);
      }
    }
    cmp.set("v.selectedCopetitorProducts", selectedCopetitorProducts);
  },

  setSelectedCompetitorProd: function (cmp, event) {
    var val = event.target.id;
    cmp.set("v.selectedCompProduct", val);
  },

  addCompetitorProduct: function (cmp, event) {
    var updatedAll = [];
    var selectedVal = cmp.get("v.selectedCompProduct");
    if (!selectedVal) return;
    var selectedObj = {};
    var allValues = cmp.get("v.fieldDetails.Opportunity.Competitor_Product__c");
    var selectedList = cmp.get("v.selectedCopetitorProducts");
    if (selectedList && selectedList.length == 3) {
      alert(
        "You have selected more than three competitor products. Please select up to three products and try again."
      );
      return;
    }
    if (selectedVal == "Other") {
      cmp.set("v.showOtherCompetitorProduct", true);
    }
    for (var i = 0; i < allValues.length; i++) {
      if (allValues[i].value != selectedVal) updatedAll.push(allValues[i]);
      else selectedObj = allValues[i];
    }
    cmp.set("v.fieldDetails.Opportunity.Competitor_Product__c", updatedAll);

    var updatedSelected = [];
    selectedList.push(selectedObj);
    cmp.set("v.selectedCopetitorProducts", selectedList);
    cmp.set("v.selectedCompProduct", "");
  },

  delCompetitorProduct: function (cmp, event) {
    var selectedObj = {};
    var selectedVal = cmp.get("v.selectedCompProduct");
    if (!selectedVal) return;
    var allSelected = cmp.get("v.selectedCopetitorProducts");
    var updatedSelected = [];
    for (var i = 0; i < allSelected.length; i++) {
      if (allSelected[i].value != selectedVal)
        updatedSelected.push(allSelected[i]);
      else selectedObj = allSelected[i];
    }
    if (selectedVal == "Other") {
      cmp.set("v.showOtherCompetitorProduct", false);
    }
    cmp.set("v.selectedCopetitorProducts", updatedSelected);

    var allValues = cmp.get("v.fieldDetails.Opportunity.Competitor_Product__c");
    allValues.push(selectedObj);
    allValues.sort(function (a, b) {
      return a.label == b.label ? 0 : a.label < b.label ? -1 : 1;
    });
    cmp.set("v.fieldDetails.Opportunity.Competitor_Product__c", allValues);
    cmp.set("v.selectedCompProduct", "");
  }
});
