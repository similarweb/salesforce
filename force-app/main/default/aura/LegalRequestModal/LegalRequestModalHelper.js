({
  redirectToCreateRequest: function (component, event, helper) {
    component.set("v.isModalOpen", false);

    var navService = component.find("navService");
    var pageRef = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Request__c",
        actionName: "new"
      },
      state: {
        recordTypeId: component.get("v.legalRequestRecordType")
      }
    };

    var defaultFieldValues = {
      Account__c: component.get("v.accountId"),
      Opportunity__c: component.get("v.opportunityId"),
      Applicable_Quote__c: "Yes",
      Quote__c: component.get("v.recordId")
    };
    pageRef.state.defaultFieldValues = component
      .find("pageRefUtils")
      .encodeDefaultFieldValues(defaultFieldValues);
    component.set("v.pageReference", pageRef);
    var defaultUrl = "#";

    navService.generateUrl(pageRef).then(
      $A.getCallback(function (url) {
        component.set("v.url", url ? url : defaultUrl);
      }),
      $A.getCallback(function (error) {
        component.set("v.url", defaultUrl);
      })
    );

    event.preventDefault();
    navService.navigate(pageRef);
  },

  obtainLegalRequestRecordTypeId: function (component, event, helper) {
    var action = component.get("c.obtainLegalRequestPreFillingData");
    action.setParams({ quoteId: component.get("v.recordId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var rsponseData = response.getReturnValue();
      if (state === "SUCCESS" && rsponseData.success !== false) {
        console.log(response.getReturnValue());
        component.set(
          "v.legalRequestRecordType",
          rsponseData.content.recordTypeId
        );
        component.set("v.opportunityId", rsponseData.content.opportunityId);
        component.set("v.accountId", rsponseData.content.accountId);
      } else if (rsponseData != undefined) {
        helper.showToast("error", "Error!", rsponseData.message);
      } else {
        helper.showToast("error", "Error!", "Unexpected error");
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
