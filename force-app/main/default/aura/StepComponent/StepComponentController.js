({
	onStepClick : function(component, event, helper) {
        var stepName=component.get("v.stepName");
        var journeyName=component.get("v.journeyName");
        var stepClickEvent = $A.get("e.c:stepClickEvent");
        stepClickEvent.setParams({
            "journeyName":journeyName,
            "stepName":stepName,
        });
        stepClickEvent.fire();
	}
})