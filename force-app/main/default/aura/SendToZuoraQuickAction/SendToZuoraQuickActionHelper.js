({
  sendQuoteToZuoraAction: function (component, helper) {
    component.set("v.isLoading", true);
    var action = component.get("c.sendQuoteToZuora");
    var params = {};
    params.quoteId = component.get("v.recordId");
    action.setParams(params);
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          helper.showToast("success", "Success!", responseObj.message);
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      } else {
        helper.showToast("error", "Error!", "Fatal error!");
      }
    });
    $A.enqueueAction(action);
  },
  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    var params = {
      title: title,
      type: type,
      duration: 10000
    };
    if (message) {
      params.message = message;
    }
    toastEvent.setParams(params);
    toastEvent.fire();
  }
});
