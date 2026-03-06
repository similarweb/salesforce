({
  loadData: function (component) {
    component.set("v.valuesListRaw", "");
    component.set("v.newLabel", "");
    var columns = [
      {
        fieldName: "label",
        label: "Label",
        type: "text"
      },
      {
        fieldName: "value",
        label: "Value",
        type: "text"
      }
    ];
    var actions = [
      {
        label: "Delete record",
        iconName: "utility:delete",
        name: "removeRecord"
      },

      {
        label: "Edit records",
        iconName: "utility:edit",
        name: "editRecord"
      }
    ];
    var column = {};
    column.typeAttributes = { rowActions: actions };
    column.type = "action";
    columns.push(column);
    component.set("v.columns", columns);

    var action = component.get("c.retreiveBaseProductContractValues");
    component.set("v.isLoading", true);
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
          component.set("v.data", responseContent);
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
    //var controllingFieldValue = component.get('v.controllingFieldValue');
    var action = component.get("c.addWorldListPicklistValue");
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
            "Word picklist values successfully added!"
          );
          var baseProductValueSelectedEvent = $A.get(
            "e.c:bps_BaseProductValueSelected"
          );
          baseProductValueSelectedEvent.fire();
          helper.loadData(component);
          component.set("v.shownAddValuesModal", false);
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
          var baseProductValueSelectedEvent = $A.get(
            "e.c:bps_BaseProductValueSelected"
          );
          baseProductValueSelectedEvent.fire();
          helper.loadData(component);
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      }
    });
    $A.enqueueAction(action);
  },

  editWordListPicklistValue: function (component, helper, newLabel, fullName) {
    var action = component.get("c.editWorldListPicklistValues");
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
          var baseProductValueSelectedEvent = $A.get(
            "e.c:bps_BaseProductValueSelected"
          );
          baseProductValueSelectedEvent.fire();
          helper.loadData(component);
          component.set("v.shownEditValuesModal", false);
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      }
    });
    $A.enqueueAction(action);
  }
});
