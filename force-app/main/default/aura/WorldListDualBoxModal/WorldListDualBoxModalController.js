({
  doInit: function (component, event, helper) {
    component.set("v.isLoading", true);

    var selectedWorldListPicklistValues = component.get(
      "v.selectedWorldListPicklistValues"
    );
    var selectedWorldListPicklistValueFullNames = [];

    selectedWorldListPicklistValues.forEach((selectedWorldListPicklistValue) =>
      selectedWorldListPicklistValueFullNames.push(
        selectedWorldListPicklistValue.value
      )
    );
    component.set(
      "v.selectedWorldListPicklistValueFullNames",
      selectedWorldListPicklistValueFullNames
    );

    var action = component.get("c.retreiveBaseProductContractValues");
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          var responseContent = responseObj.content;
          component.set("v.options", responseContent);
        }
      }
    });
    $A.enqueueAction(action);
  },

  onCancelClick: function (component, event, helper) {
    component.set("v.isShown", false);
  },

  onSaveClick: function (component, event, helper) {
    helper.saveWordPicklistValues(component, event, helper);
  }
});
