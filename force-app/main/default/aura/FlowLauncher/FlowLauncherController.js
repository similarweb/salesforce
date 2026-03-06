({
  doInit: function (component, event, helper) {
    var flow = component.find("flowData");
    var flowName = "Case_Sc_Create_a_Case";
    var inputVariables = [
      {
        name: "recordId",
        type: "String",
        value: component.get("v.recordId")
      }
    ];

    // Start the flow with input variables
    flow.startFlow(flowName, inputVariables);
  },
  handleFlowStatusChange: function (component, event, helper) {
    let status = event.getParam("status");
    if (status === "FINISHED" || status === "FINISHED_SCREEN") {
      // You can call a method to close the modal or perform any other action
      // For example, you might close a quick action modal like this:
      $A.get("e.force:closeQuickAction").fire();
    }
  }
});
