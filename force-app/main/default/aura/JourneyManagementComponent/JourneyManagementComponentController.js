({
  doInit: function (component, event, helper) {
    component.set("v.columns", [
      {
        label: "Order",
        fieldName: "Step_Order__c",
        type: "number",
        sortable: true
      },
      { label: "Step", fieldName: "Step_Name__c", type: "text" },
      {
        label: "Status",
        fieldName: "Active__c",
        type: "boolean",
        editable: "true"
      },
      {
        label: "Step SLA (minutes)",
        fieldName: "Step_SLA__c",
        type: "text",
        editable: "true"
      }
    ]);
    var action = component.get("c.obtainJorneySettingList");
    component.set("v.loaded", !component.get("v.loaded"));
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        component.set("v.journeyList", responseJson);
        component.set("v.journeyName", responseJson[0]);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  journeyNameChange: function (component, event, helper) {
    var journeyName = component.get("v.journeyName");
    helper.obtainJourneyPathSettings(component, journeyName);
  },
  updateColumnSorting: function (component, event, helper) {
    var fieldName = event.getParam("fieldName");
    var sortDirection = event.getParam("sortDirection");
    helper.sortData(component, fieldName, sortDirection);
  },
  handleSaveClick: function (component, event, helper) {
    var settings = event.getParam("draftValues");
    var action = component.get("c.updateJourneyPathSettings");
    var journeyName = component.get("v.journeyName");
    action.setParams({
      journeySettings: settings
    });
    component.set("v.loaded", !component.get("v.loaded"));
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        component.find("datatable").set("v.draftValues", null);
        helper.obtainJourneyPathSettings(component, journeyName);
        var journeyPathSettingEvent = $A.get("e.c:JourneyPathSettingEvent");
        journeyPathSettingEvent.fire();
        alert("Success");
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  }
});
