({
  onButtonClick: function (component, event, helper) {
    if (component.get("v.paymentLink")) {
      helper.showPaymentLink(component);
    } else if (component.get("v.renewalLink")) {
      helper.showRenewalLink(component, event);
      helper.createSendEmailButton(component);
      helper.createAddRecipientButton(component);
      // helper.createCopyToClipboardButton(component);
      helper.generateTimestamp(component);
    }
  },

  copyToClipboard: function (component, event, helper) {
    var modalWindowData = component.get("v.modalWindowData");

    var parser = new DOMParser();
    var htmlDoc = parser.parseFromString(modalWindowData.message, "text/html");
    var arr = htmlDoc.getElementsByTagName("a");
    if (arr && arr.length > 0) {
      var link = arr[0].href;
      helper.copyTextHelper(component, event, link);
    }
  },

  clickSendEmail: function (component, event, helper) {
    helper.clickSendEmail(component, helper);
  },

  clickAddRecipient: function (component, event, helper) {
    helper.clickAddRecipient(component, helper);
  },

  handleSendEmail: function (component, event, helper) {
    helper.handleSendEmail(component, event, helper);
  },

  handleAddRecipient: function (component, event, helper) {
    helper.handleAddRecipient(component, event, helper);
  },

  handleRemoveRecipient: function (component, event, helper) {
    helper.handleRemoveRecipient(component, event, helper);
  }
});
