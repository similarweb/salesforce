({
  voidQuote: function (component, event, helper) {
    let action = component.get("c.voidQuotes");
    action.setParams({
      quoteId: component.get("v.recordId"),
      subscriptionName: component.get("v.subscriptionName")
    });
    action.setCallback(this, function (response) {
      let state = response.getState();
      let responseData = response.getReturnValue();
      if (state === "SUCCESS" && responseData.success !== "false") {
        component.set("v.isOpenModal", false);
        helper.fireConfirmEvent(component, event);
      } else if (responseData != undefined) {
        helper.showToast("error", "Error!", responseData.message);
      } else {
        helper.showToast("error", "Error!", "Unexpected error");
      }
    });
    $A.enqueueAction(action);
  },
  getQuoteList: function (component, event, helper) {
    let action = component.get("c.obtainQuoteList");
    action.setParams({
      quoteId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      let state = response.getState();
      let responseData = response.getReturnValue();
      if (state === "SUCCESS" && responseData.success !== "false") {
        let quoteList = responseData.content.quoteList;
        let subscriptionName = responseData.content.subscriptionName;
        component.set("v.quoteList", quoteList);
        component.set("v.subscriptionName", subscriptionName);
      } else if (responseData != undefined) {
        helper.showToast("error", "Error!", responseData.message);
      } else {
        helper.showToast("error", "Error!", "Unexpected error");
      }
    });
    $A.enqueueAction(action);
  },
  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    var params = {
      title: title,
      type: type
    };
    if (message) {
      params.message = message;
    }
    toastEvent.setParams(params);
    toastEvent.fire();
  },
  fireConfirmEvent: function (component, event) {
    let message;
    let actionType = component.get("v.actionType");
    if (actionType == "RFB") {
      message = "fireRFB";
    } else if (actionType == "Submit") {
      message = "fireSubmit";
    }
    let confirmEvent = component.getEvent("confirmEvent");
    confirmEvent.setParams({
      message: message
    });
    confirmEvent.fire();
  }
});
