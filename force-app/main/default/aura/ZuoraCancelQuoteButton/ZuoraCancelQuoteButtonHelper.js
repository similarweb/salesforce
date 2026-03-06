({
  cancellQuoteAction: function (component, helper) {
    helper.showModalPopupLoading(component, "Loading...", true);
    var action = component.get("c.cancelQuote");
    action.setParams({ quoteId: component.get("v.recordId") });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          helper.showModalPopupLoading(component, "Loading...", false);
          helper.showModalPopup(
            component,
            "Success!",
            "Quote has been cancelled"
          );
          setTimeout(() => {
            window.location.reload(false);
          }, 2000);
        } else {
          helper.showModalPopup(component, "Error", responseObj.message);
          $A.get("e.force:closeQuickAction").fire();
        }
      } else {
        helper.showModalPopup(component, "Error", "Fatal error");
        $A.get("e.force:closeQuickAction").fire();
      }
    });
    $A.enqueueAction(action);
  }
});
