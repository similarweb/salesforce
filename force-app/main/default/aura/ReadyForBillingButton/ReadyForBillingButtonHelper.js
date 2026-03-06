({
  readyForBilling: function (component, helper) {
    this.showModalPopupLoading(component, "Loading...", true);
    var action = component.get("c.readyForBillingQuote");
    action.setParams({
      quoteId: component.get("v.recordId"),
      autoFinalizeQuote: component.get("v.autoFinalizeQuote")
    });
    action.setCallback(this, function (response) {
      this.showModalPopupLoading(component, "Loading...", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          this.showModalPopup(component, "Success!", responseObj.message);
          var refreshEvent = $A.get("e.c:ApplicationRefresgEvent");
          refreshEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          this.showModalPopup(component, "Error", responseObj.message);
        }
      } else {
      }
    });
    $A.enqueueAction(action);
  },
  validateSubscription: function (component, event, helper) {
    let action = component.get("c.validateSubscription");
    action.setParams({
      quoteId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      let state = response.getState();
      let responseData = response.getReturnValue();
      if (state === "SUCCESS" && responseData.success !== "false") {
        if (responseData.content) {
          component.set("v.isOpenModal", true);
        } else {
          helper.readyForBilling(component, helper);
        }
      } else if (responseData != undefined) {
        this.showModalPopup(component, "Error", responseData.message);
      } else {
        this.showModalPopup(component, "Error", "Unexpected error");
      }
    });
    $A.enqueueAction(action);
  }
});
