({
  doInit: function (component, event, helper) {
    var action = component.get("c.obtainRequestRecordTypes");
    action.setParams({
      oppId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var response = JSON.parse(response.getReturnValue());
        component.set("v.picklistValues", response.rtwList);
        component.set("v.oppType", response.oppType);
      }
    });

    $A.enqueueAction(action);
  },
  selectRecordType: function (component, event, helper) {
    document.getElementsByName("options").forEach(function (option) {
      if (option.checked) {
        component.set("v.selectedRecordType", option.value);
      }
    });
  },
  createRecord: function (component, event, helper) {
    debugger;
    var recordTypeId = component.get("v.selectedRecordType");
    var oppType = component.get("v.oppType");
    console.log(oppType);
    console.log(recordTypeId);
    if (!!recordTypeId) {
      if (
        recordTypeId == "012b0000000UddJAAS" &&
        oppType != "Renewal" &&
        oppType != "Upsell" &&
        oppType != "New Sale"
      ) {
        //2021-02-11: added New Sale - Itzik Winograd
        helper.setError(
          component,
          "A Solution Consulting request may be created for New Sale, Renewal and Upsell opportunities types only"
        );
      } else if (
        recordTypeId == "0120O000000BvvsQAC" &&
        oppType != "New Sale" &&
        oppType != "Upsell"
      ) {
        helper.setError(
          component,
          "A Solution Engineering request may be created for New Sale and Upsell opportunities types only"
        );
      } else {
        helper.setError(component, "");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
          entityApiName: "Request__c",
          recordTypeId: recordTypeId,
          defaultFieldValues: {
            Opportunity__c: component.get("v.recordId")
          }
        });
        debugger;
        createRecordEvent.fire();
      }
    } else {
      helper.setError(component, "S");
    }
  },
  cancel: function (cmp, event, helper) {
    var modalCaller = cmp.get("v.modalCaller");
    if (modalCaller) {
      modalCaller.closeModal();
    } else {
      $A.get("e.force:closeQuickAction").fire();
      $A.get("e.force:refreshView").fire();
    }
  }
});
