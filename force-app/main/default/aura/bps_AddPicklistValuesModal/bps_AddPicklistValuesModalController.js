({
  doInit: function (component) {
    let allRestrictedOptionsMap = component.get("v.myPicklistValues");
    if (allRestrictedOptionsMap) {
      let defaultPicklistValues = allRestrictedOptionsMap["Default"];
      let leadEnrichmentPicklistValues =
        allRestrictedOptionsMap["Lead Enrichment"];
      component.set("v.defaultPicklistValues", defaultPicklistValues);
      component.set(
        "v.leadEnrichmentPicklistValues",
        leadEnrichmentPicklistValues
      );
    }
  },
  onSaveClick: function (component, event, helper) {
    component.set("v.isLoading", true);
    var fullNameListRaw = component.get("v.valuesListRaw");
    var mode = component.get("v.mode");
    if (fullNameListRaw || mode != "Base product") {
      var action;
      var params = {
        fullNameListRaw: fullNameListRaw
      };
      if (mode == "Base product") {
        action = component.get("c.addBaseProductPicklistValues");
      } else if (mode == "Default addon") {
        action = component.get("c.setDefaultAddonsForBaseProduct");
        params.controllingName = component.get("v.controllingFieldValue");
      } else if (mode == "Dynamic addon") {
        action = component.get("c.setDynamicAddonsForBaseProduct");
        params.controllingName = component.get("v.controllingFieldValue");
      }
      if (action) {
        action.setParams(params);
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
              if (mode == "Base product") {
                $A.get("e.force:refreshView").fire();
              } else {
                var baseProductValueSelectedEvent = $A.get(
                  "e.c:bps_BaseProductValueSelected"
                );
                baseProductValueSelectedEvent.fire();
                component.set("v.isShown", false);
              }
            } else {
              helper.showToast("error", "Error!", responseObj.message);
            }
          }
        });
        $A.enqueueAction(action);
      }
    } else {
      helper.showToast("error", "Error!", "Input is empty");
    }
  },

  onCancelClick: function (component, event, helper) {
    component.set("v.isShown", false);
  }
});
