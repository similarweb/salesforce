({
  showPaymentLink: function (component) {
    let modalLabel =
      component.get("v.label") === "Feature acceptance link"
        ? "Link"
        : "Payment link";
    let paymentLinkText = component.get("v.paymentLink");
    let paymentLink;
    if (paymentLinkText.indexOf("<a href=") == -1) {
      paymentLink =
        "<a href=" + paymentLinkText + ">" + paymentLinkText + "</a>";
    } else {
      paymentLink = paymentLinkText;
    }
    this.showModalPopup(component, modalLabel, paymentLink);
  },

  showRenewalLink: function (component, event) {
    var title = "Email Link to Customer";
    var message =
      "Please click on the button below “Add Recipients” in order to send an email to the customer with the renewal link.<br>";
    message += "<br>Please make sure to pick at least one contact.";

    if (component.get("v.additionalRecipientAddress")) {
      let emailAddressList = component.get("v.additionalRecipientAddress");
      if (emailAddressList.length > 0) {
        message +=
          "<br>Recipient(s) - " + component.get("v.additionalRecipientAddress");
      }
    }
    this.showModalPopup(component, title, message);
  },

  generateTimestamp: function (component) {
    var action = component.get("c.setRenewalLinkGeneratedTimestamp");
    action.setParams({ quoteId: component.get("v.quoteRecordId") });
    $A.enqueueAction(action);
  },

  createCopyToClipboardButton: function (cmp) {
    var copyToClipboardButton = cmp.find("copyToClipboardButton");
    if (copyToClipboardButton) {
      return;
    }
    $A.createComponent(
      "lightning:button",
      {
        "aura:id": "copyToClipboardButton",
        label: "Copy Link",
        variant: "brand",
        onclick: cmp.getReference("c.copyToClipboard"),
        class: "slds-float_left"
      },
      function (newButton, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var modalFooterButton = cmp.get("v.modalFooterButton");
          modalFooterButton.push(newButton);
          cmp.set("v.modalFooterButton", modalFooterButton);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
          // Show offline error
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
          // Show error message
        }
      }
    );
  },

  copyTextHelper: function (component, event, text) {
    // Create an hidden input
    var hiddenInput = document.createElement("input");
    // passed text into the input
    hiddenInput.setAttribute("value", text);
    // Append the hiddenInput input to the body
    document.body.appendChild(hiddenInput);
    // select the content
    hiddenInput.select();
    // Execute the copy command
    document.execCommand("copy");
    // Remove the input from the body after copy text
    document.body.removeChild(hiddenInput);
    // store target button label value
    var orignalLabel = event.getSource().get("v.label");
    // change button icon after copy text
    event.getSource().set("v.iconName", "utility:check");
    // change button label with 'copied' after copy text
    event.getSource().set("v.label", "Copied!");

    // set timeout to reset icon and label value after 700 milliseconds
    setTimeout(function () {
      event.getSource().set("v.iconName", "");
      event.getSource().set("v.label", orignalLabel);
    }, 700);
  },

  createSendEmailButton: function (cmp) {
    var sendEmailButton = cmp.find("sendEmailButton");
    if (sendEmailButton) {
      return;
    }
    $A.createComponent(
      "lightning:button",
      {
        "aura:id": "sendEmailButton",
        label: "Send Email",
        variant: "brand",
        onclick: cmp.getReference("c.clickSendEmail"),
        class: "slds-float_left"
      },
      function (newButton, status, errorMessage) {
        if (status === "SUCCESS") {
          var modalFooterButton = cmp.get("v.modalFooterButton");
          modalFooterButton.push(newButton);
          cmp.set("v.modalFooterButton", modalFooterButton);
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
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
  },

  clickSendEmail: function (component, helper) {
    let emailAddressList = component.get("v.additionalRecipientAddress");
    if (emailAddressList == undefined || emailAddressList.length < 1) {
      helper.showToast(
        "error",
        "Error!",
        $A.get("$Label.c.QuoteRenewalEmailMissingRecipientsMsg")
      );
      return;
    }
    this.setRenewalTimestamp(component);
    helper.showModalPopupComment(
      component,
      helper,
      "Additional text to be sent to the customer",
      "Send Email",
      "Comments"
    );
  },

  showModalPopupComment: function (
    component,
    helper,
    title,
    submitLabel,
    inputLabel
  ) {
    var modalWindowData = {};
    modalWindowData.title = title;
    modalWindowData.submitLabel = submitLabel;
    modalWindowData.inputLabel = inputLabel;
    if (submitLabel == "Send Email") {
      modalWindowData.isComment = true;
      modalWindowData.isContactTableCheck = false;
    } else {
      modalWindowData.isComment = false;
      modalWindowData.isContactTableCheck = true;
    }
    if (submitLabel == "Add Recipients") {
      modalWindowData.isContactTable = true;
    }
    modalWindowData.placeholder = "";
    component.set("v.modalWindowData", modalWindowData);
    component.set("v.isModalOpen", true);
  },

  createAddRecipientButton: function (component) {
    var addRecipientButton = component.find("addRecipientButton");
    if (addRecipientButton) {
      return;
    }
    $A.createComponent(
      "lightning:button",
      {
        "aura:id": "addRecipientButton",
        label: "Add Recipients",
        variant: "brand-outline",
        onclick: component.getReference("c.clickAddRecipient"),
        class: "slds-float_left"
      },
      function (newButton, status, errorMessage) {
        if (status === "SUCCESS") {
          var modalFooterButton = component.get("v.modalFooterButton");
          modalFooterButton.push(newButton);
          component.set("v.modalFooterButton", modalFooterButton);
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  },

  clickAddRecipient: function (component, helper) {
    helper.showModalPopupComment(
      component,
      helper,
      "Additional recipients",
      "Add Recipients",
      "Email"
    );
  },

  handleAddRecipient: function (component, event, helper) {
    var emailList = event.getParam("emailList");
    let additionalRecipientAddress = "";
    for (var i = 0; i < emailList.length; i++) {
      let email = emailList[i];
      if (additionalRecipientAddress.length > 0) {
        additionalRecipientAddress = additionalRecipientAddress + ", ";
      }
      additionalRecipientAddress = additionalRecipientAddress + email;
    }
    component.set("v.additionalRecipientAddress", additionalRecipientAddress);
    var action = component.get("c.onButtonClick");
    $A.enqueueAction(action);
  },

  handleRemoveRecipient: function (component, event, helper) {
    component.set("v.additionalRecipientAddress", undefined);
  },

  setRenewalTimestamp: function (component) {
    var action = component.get("c.setRenewalLinkGeneratedTimestamp");
    action.setParams({ quoteId: component.get("v.quoteRecordId") });
    action.setCallback(this, function (res) {
      var state = res.getState();
      if (state === "SUCCESS") {
        console.log("Timestamp set successfully");
      } else if (state === "ERROR") {
        var errors = res.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  handleSendEmail: function (component, event, helper) {
    var action = component.get("c.sendEmailNotification");
    action.setParams({
      quoteId: component.get("v.quoteRecordId"),
      message: event.getParam("message"),
      additionalRecipients: component.get("v.additionalRecipientAddress")
        ? component.get("v.additionalRecipientAddress").split(",")
        : undefined
    });
    action.setCallback(this, function (res) {
      component.set("v.additionalRecipientAddress", undefined);
      helper.setLoading(component, false);
      var state = res.getState();
      if (state === "SUCCESS") {
        //Temporarily disable the creation of a ticket in Zendesk
        //this.createZendeskTicket(component, event, helper);
        var successMsg = res.getReturnValue();
        console.log(successMsg);
        component.set("v.approvalRequestComment", "");
        component.set("v.isModalOpen", false);
        helper.showToast("success", "Success!", successMsg);
      } else if (state === "ERROR") {
        var errorMsg = "";
        var errors = res.getError();
        if (errors && errors[0] && errors[0].message) {
          errorMsg = errors[0].message;
        }
        console.log(errorMsg);
        helper.showToast("error", "Error!", errorMsg);
      }
    });
    helper.setLoading(component, true);
    $A.enqueueAction(action);
  },

  createZendeskTicket: function (component, event, helper) {
    var action = component.get("c.createZendeskTicket");
    action.setParams({
      quoteId: component.get("v.quoteRecordId")
    });
    action.setCallback(this, function (res) {
      var state = res.getState();
      if (state === "SUCCESS") {
        var ticketId = res.getReturnValue();
        console.log("Zendesk ticketId: " + ticketId);
        helper.showToast("success", "Success!", "Zendesk ticket created");
      } else if (state === "ERROR") {
        var errorMsg = "";
        var errors = res.getError();
        if (errors && errors[0] && errors[0].message) {
          errorMsg = errors[0].message;
        }
        console.log(errorMsg);
        helper.showToast("error", "Error!", "Zendesk ticket was not created");
      }
    });
    $A.enqueueAction(action);
  }
});
