({
	doInit : function(component, event, helper) {
		var action = component.get("c.obtainJorneySettingList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseJson = JSON.parse(response.getReturnValue());                
                console.log(responseJson);
                component.set('v.jorneyList',responseJson);
                component.set('v.jorneyName',responseJson[0]);
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    
    handleJourneyInfoEvent: function(component, event, helper) {
        component.set('v.recordsInTheJourney',event.getParam('recordsInTheJourney'));
        component.set('v.averageJourneyTimeLastThreeHours',event.getParam('averageJourneyTimeLastThreeHours'));
        component.set('v.completedRecordsInTheJourney',event.getParam('recordBrichingSLA'));
	},
    handleClick: function(component, event, helper) {
        var a = component.find('input').get('v.value');
        if(a){
            component.set('v.pathMode',2);
            var pathCmp = component.find('path');        
            pathCmp.searchLead(component.find('input').get('v.value'),component.find('select').get('v.value'));
        }
	},
    handleClickCancel: function(component, event, helper) {
        component.set('v.pathMode',1);
        var pathCmp = component.find('path');
        var a = component.find('input').get('v.value');
        pathCmp.searchLead();
        
	},
    onStepClick : function(component, event, helper) {
        var journeyName=component.get("v.jorneyName");
        var stepClickEvent = $A.get("e.c:stepClickEvent");
        stepClickEvent.setParams({
            "journeyName":journeyName,
            "stepName" : 'Completed Journey',
            "isReport" : true
        });
        stepClickEvent.fire();
	}
})