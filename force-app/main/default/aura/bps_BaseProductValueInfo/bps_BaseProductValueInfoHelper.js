({
  obtainWordPicklistValuesForBaseProduct: function (component, event) {
    var baseValueFullName;
    if (event.getParam("fullName")) {
      baseValueFullName = event.getParam("fullName");
      component.set("v.baseProductFullName", event.getParam("fullName"));
      component.set("v.baseProductLabel", event.getParam("label"));
    } else {
      baseValueFullName = component.get("v.baseProductFullName");
    }
    component.set("v.isLoading", true);
    var worldListInfoCmp = component.find("worldListInfo");
    if (worldListInfoCmp) {
      worldListInfoCmp.clearFullName();
    }
    var action = component.get(
      "c.retreiveWorldListPicklistValuesForDependentValue"
    );
    action.setParams({
      controllingFieldValue: baseValueFullName
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          var responseContent = responseObj.content;
          responseContent.sort(function (a, b) {
            if (a.label > b.label) {
              return 1;
            }
            if (b.label > a.label) {
              return -1;
            }
            return 0;
          });
          component.set("v.worldListPicklistValues", responseContent);
        } else {
          component.set("v.worldListPicklistValues", []);
        }
      }
    });
    $A.enqueueAction(action);
  },

  obtainDefaultAddonsForBaseProduct: function (component) {
    component.set("v.isLoading", true);
    var baseValueFullName = component.get("v.baseProductFullName");
    var action = component.get("c.retrieveDefaultAddonsForBaseProduct");
    action.setParams({
      controllingName: baseValueFullName
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          var responseContent = responseObj.content;
          component.set("v.defaultAddonsValues", responseContent);
        }
      }
    });
    $A.enqueueAction(action);
  },

  obtainBaseProductsRestrictOptions: function (component) {
    component.set("v.isLoading", true);
    var action = component.get("c.retrieveBaseProductsRestrictOptions");
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          var responseContent = responseObj.content;
          component.set("v.myPicklistValues", responseContent);
        }
      }
    });
    $A.enqueueAction(action);
  },

  obtainDynamicAddonsForBaseProduct: function (component) {
    component.set("v.isLoading", true);
    var baseValueFullName = component.get("v.baseProductFullName");
    var action = component.get("c.retrieveDynamicAddonsForBaseProduct");
    action.setParams({
      controllingName: baseValueFullName
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          var responseContent = responseObj.content;
          responseContent.sort();
          component.set("v.dynamicAddonsValues", responseContent);
        }
      }
    });
    $A.enqueueAction(action);
  },

  obtainNumOfUsers: function (component) {
    component.set("v.isLoading", true);
    var baseValueFullName = component.get("v.baseProductFullName");
    var action = component.get("c.retrieveDefaultNumberOfUsersForBaseProduct");
    action.setParams({
      controllingName: baseValueFullName
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          var responseContent = responseObj.content;
          component.set("v.numberOfUsers", responseContent);
        }
      }
    });
    $A.enqueueAction(action);
  },

  deleteBaseProductValue: function (component, helper) {
    var fullNameToDelete = component.get("v.baseProductFullName");
    component.set("v.isLoading", true);
    var action = component.get("c.deleteBaseProductPicklistValues");
    action.setParams({
      fullNameToDelete: fullNameToDelete
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
            "\ " + fullNameToDelete + "' succesfully deleted!"
          );
          $A.get("e.force:refreshView").fire();
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      }
    });
    $A.enqueueAction(action);
  },

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
  }
});
