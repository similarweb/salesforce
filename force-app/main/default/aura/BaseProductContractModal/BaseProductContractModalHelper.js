({
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

  removeRecord: function (component, rowName, helper) {
    var action = component.get("c.deleteBaseProductContractValues");
    action.setParams({
      value: rowName
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          helper.deleteWordListPicklistValue(component, helper, rowName);
        } else {
          component.set("v.isLoading", false);
          helper.showToast("error", "Error!", responseObj.message);
        }
      } else {
        component.set("v.isLoading", false);
      }
    });
    $A.enqueueAction(action);
  },

  addWordListPicklistValue: function (component, helper, fullNameListRaw) {
    var controllingFieldValue = component.get("v.controllingFieldValue");
    var action = component.get("c.addWorldListPicklistValue");
    action.setParams({
      controllingFieldValue: controllingFieldValue,
      fullNameListRaw: fullNameListRaw
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          helper.showToast(
            "success",
            "Success!",
            "Word picklist values successfully assigned to '" +
              controllingFieldValue +
              "' base product!"
          );
          $A.get("e.force:refreshView").fire();
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      }
    });
    $A.enqueueAction(action);
  },

  deleteWordListPicklistValue: function (component, helper, rowName) {
    var action = component.get("c.deleteWorldListPicklistValue");
    action.setParams({
      fullNameToDelete: rowName
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          helper.showToast(
            "success",
            "Success!",
            "'" + rowName + "' succesfully deleted!"
          );
          $A.get("e.force:refreshView").fire();
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      }
    });
    $A.enqueueAction(action);
  },

  editWordListPicklistValue: function (component, helper, newLabel, fullName) {
    var action = component.get("c.editBaseProductPicklistValues");
    action.setParams({
      label: newLabel,
      fullName: fullName
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          helper.showToast(
            "success",
            "Success!",
            "Label is changed to '" + newLabel + "' succesfully!"
          );
          $A.get("e.force:refreshView").fire();
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      }
    });
    $A.enqueueAction(action);
  }
});
