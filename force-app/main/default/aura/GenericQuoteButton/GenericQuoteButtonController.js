({
  onCancelClick: function (component, event, helper) {
    component.set("v.approvalRequestComment", "");
    component.set("v.isModalOpen", false);
    component.getEvent("removeRecipientEvent").fire();
  },

  onDynamicButtonClick: function (component, event, helper) {
    var modalWindowData = component.get("v.modalWindowData");

    if (modalWindowData.buttonArray[0].action) {
      $A.enqueueAction(modalWindowData.buttonArray[0].action);
    } else if (modalWindowData.buttonArray[0].event) {
      var e = modalWindowData.buttonArray[0].event;
      $A.get(e.name).fire(e.body);
      component.set("v.isModalOpen", false);
    }
  },

  onSaveClick: function (component, event, helper) {
    const buttonLabel = event.target.innerHTML;
    var message = component.get("v.approvalRequestComment");
    var event;
    let contactTabelComponent = component.find("relatedContactTableId");
    if (buttonLabel === "Send Email") {
      event = component.getEvent("sendEmailEvent");
      event.setParam("message", message);
      event.fire();
    } else if (buttonLabel === "Add Recipients") {
      event = component.getEvent("addRecipientEvent");
      if (contactTabelComponent != undefined) {
        let contactEmailList = contactTabelComponent.get(
          "v.selectedContactList"
        );
        for (var i = 0; i < contactEmailList.length; i++) {
          message = contactEmailList[i];
          if (!helper.validateEmail(message)) {
            helper.showToast("error", "Error!", "Invalid Email Address");
            return;
          }
        }
        event.setParam("emailList", contactEmailList);
        component.set("v.contactEmailList", contactEmailList);
      }
      event.fire();
    }
    component.set("v.approvalRequestComment", "");
  }
});
