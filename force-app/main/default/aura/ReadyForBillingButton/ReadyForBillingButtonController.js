({
  onButtonClick: function (component, event, helper) {
    helper.validateSubscription(component, event, helper);
    //helper.readyForBilling(component, helper);
  },
  handleConfirmSubmitEvent: function (component, event, helper) {
    let message = event.getParam("message");
    if (message == "fireRFB") {
      helper.readyForBilling(component, helper);
    }
  }
});
