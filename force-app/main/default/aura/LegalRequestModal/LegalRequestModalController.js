({
  onInit: function (component, event, helper) {
    helper.obtainLegalRequestRecordTypeId(component, event, helper);
  },

  openModal: function (component, event, helper) {
    component.set("v.isModalOpen", true);
  },

  closeModal: function (component, event, helper) {
    component.set("v.isModalOpen", false);
  },

  closeGenerateContractDecisionModal: function (component, event, helper) {
    component.set("v.isGenerateContractDecision", false);
  },

  redirectToCreateRequest: function (component, event, helper) {
    helper.redirectToCreateRequest(component, event, helper);
  },

  openGenerateContractDecision: function (component, event, helper) {
    component.set("v.isModalOpen", false);
    component.set("v.isGenerateContractDecision", true);
  },

  clickGenerateContract: function (component, event, helper) {
    component.set("v.isModalOpen", false);
    component.set("v.isGenerateContractDecision", false);
    console.log("Event fire");
    var cmpEvent = component.getEvent("gcEvent");
    cmpEvent.setParams({
      message: "generate contract"
    });
    cmpEvent.fire();
  },

  clickGenerateContractAndSendToDocusign: function (component, event, helper) {
    component.set("v.isGenerateContractDecision", false);
    console.log("Event fire");
    var cmpEvent = component.getEvent("gcEvent");
    cmpEvent.setParams({
      message: "generate contract and send to docusign"
    });
    cmpEvent.fire();
  }
});
