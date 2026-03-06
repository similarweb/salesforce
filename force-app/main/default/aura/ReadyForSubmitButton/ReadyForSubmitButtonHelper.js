({
  readyForSubmit: function (component, helper) {
    this.showModalPopupLoading(component, "Loading...", true);
    var action = component.get("c.readyFoSubmitQuote");
    action.setParams({
      quoteId: component.get("v.recordId"),
      emailCofirmationValidation: component.get("v.emailCofirmationValidation")
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
  }
});
