({
  onButtonClick: function (component, event, helper) {
    component.set("v.approvalRequestComment", "");
    helper.checkQuoteForASRequests(component, event, helper);
  },

  onSaveClick: function (component, event, helper) {
    component.set("v.isModalOpen", false);
    var approvalRequestComment = component.get("v.approvalRequestComment");
    if (!approvalRequestComment) {
      approvalRequestComment = "***";
    }
    helper.triggerSubmitForApproval(component, helper, approvalRequestComment);
  },

  onCancelClick: function (component, event, helper) {
    component.set("v.approvalRequestComment", "");
    component.set("v.isModalOpen", false);
  },

  handleASProductEvent: function (component, event, helper) {
    let message = event.getParam("message");
    if (message == "approved") {
      helper.triggerSubmitForApproval(component, helper);
    }
  }
});
