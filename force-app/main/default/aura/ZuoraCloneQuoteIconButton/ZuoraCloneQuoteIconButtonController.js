({
    doInit: function(component, event, helper) {
		var action = component.get("c.getUrl");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseJson = response.getReturnValue();
                if(!!responseJson){
                    component.set("v.orgUrl", responseJson.message);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    onButtonClick : function(component, event, helper) {
        console.log(component.get('v.orgUrl'));
        var urlEvent = $A.get("e.force:navigateToURL");
        var quoteId = component.get('v.recordId');
        var zuoraVisualforceUrl = component.get("v.zuoraVisualforceUrl");
        urlEvent.setParams({
            "url": component.get('v.orgUrl') + "/apex/CustomCloneQuote?scontrolCaching=1&id=" + quoteId
        });
        urlEvent.fire();
    }
})