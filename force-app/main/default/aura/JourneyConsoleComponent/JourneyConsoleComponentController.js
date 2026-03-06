({
	handleStepClickEvent : function(component, event, helper) {   
        var journeyName = event.getParam("journeyName");
        var stepName = event.getParam("stepName");
        var isReport = event.getParam("isReport");
        debugger;
        component.set("v.journeyName",journeyName);
        component.set("v.stepName",stepName);
        component.set("v.isReport",isReport !=null ? isReport : false);
        component.set("v.isStepClicked",true);
	},
    handleClick: function (component, event, helper) {
        component.set("v.isStepClicked",false);
    },
    selectedTabChange : function (component, event, helper) {
        var journeyConsoleTabEvent = $A.get("e.c:JourneyConsoleTabEvent");
        journeyConsoleTabEvent.fire();
    }
})