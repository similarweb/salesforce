({
  onButtonClick: function (component, event, helper) {
    component.set("v.localIsDisabled", true);
    helper.validateSubscription(component, event, helper);
    // helper.showModalPopupLoading(component,'Loading...',true);
    // var action = component.get('c.finalizeQuote');
    // action.setParams({"quoteId" : component.get('v.recordId')});
    // action.setCallback(this, function(response) {
    //     var state = response.getState();
    //     if(state === "SUCCESS") {
    //         var submitMode = component.get('v.submitMode');
    //         if (submitMode == 'Submit manually') {
    //             helper.sendQuotaToZuora(component);
    //         } else if(submitMode == 'Redirect to Zuora submit page') {
    //             helper.redirectToZuoraSubmitPage(component);
    //         }
    //     } else {
    //         helper.showModalPopup(component,'Error','Fatal error');
    //     }
    // });
    // $A.enqueueAction(action);
  },
  handleConfirmSubmitEvent: function (component, event, helper) {
    let message = event.getParam("message");
    if (message == "fireSubmit") {
      helper.quoteSubmittingProcess(component, event, helper);
    }
  }
});
