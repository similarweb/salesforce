/**
 * Created by Alon.Shalev on 8/6/2023.
 */
({
    startTheFlow : function(component) {
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name: "recordId",
                type: "String",
                value: component.get("v.recordId")
            }
        ];
        if(component.get('v.flowName') == 'Quote_QRPC_type_2'){
            let quantity = {
                name: "Quantity_var",
                type: "Number",
                value: component.get("v.quantity")
            }
            inputVariables.push(quantity);
        }
        debugger;
        flow.startFlow(component.get("v.flowName"), inputVariables);
    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component,event,helper);

    },

    statusChange : function (component, event, helper) {
        if (event.getParam("status") === "FINISHED") {
            helper.closeModal(component,event,helper);
        }
    }
})