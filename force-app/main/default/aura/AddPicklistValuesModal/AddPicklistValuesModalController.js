({
  onSaveClick: function (component, event, helper) {
    component.set("v.isLoading", true);
    var fullNameListRaw = component.get("v.valuesListRaw");
    if (fullNameListRaw) {
      var action = component.get("c.addBaseProductPicklistValues");
      action.setParams({
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
              "Base product values successfully saved!"
            );
            $A.get("e.force:refreshView").fire();
          } else {
            helper.showToast("error", "Error!", responseObj.message);
          }
        }
      });
      $A.enqueueAction(action);
    } else {
      helper.showToast("error", "Error!", "Input is empty");
    }
  },

  onCancelClick: function (component, event, helper) {
    component.set("v.isShown", false);
  }
});
