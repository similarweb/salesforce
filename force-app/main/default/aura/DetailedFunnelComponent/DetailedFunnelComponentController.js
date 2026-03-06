({
	doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Lead URL link', fieldName: 'Id', type: 'url', typeAttributes: { label: 'Show lead' }},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true, typeAttributes:{year:'numeric',month:'numeric',day:'numeric',hour:'numeric',minute:'numeric',second:'numeric'}},
            {label: 'Name', fieldName: 'Name', type: 'text', sortable: true},
            {label: 'Email', fieldName: 'Email', type: 'email', sortable: true}            
        ]);
        var action = component.get("c.obtainLeadList");
        action.setParams({
            "journeyName": component.get('v.journeyName'),
            "stepName": component.get('v.stepName'),
            "isReport": component.get('v.isReport'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseJson = JSON.parse(response.getReturnValue());
                if(responseJson.success){
                    var data = responseJson.data;
                    data.leads.forEach(function(element) {
                        element['Id'] = '/'+ element['Id'];    
                    });				
                    console.log(data.leads);
                    component.set('v.leadList',data.leads);
                    component.set('v.averageTimeOnStep',data.averageTimeOnStep);
                    component.set('v.queue',data.queue);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    handleStepClickEvent : function(component, event, helper) {
        console.log('journeyName');
		var action = component.get("c.obtainLeadList");
        var journeyName = event.getParam("journeyName");
        var stepName = event.getParam("stepName");
        console.log(journeyName);
        console.log(stepName);
        
        var action = component.get("c.obtainLeadList");
        action.setParams({
            "journeyName": journeyName,
            "stepName": stepName,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseJson = JSON.parse(response.getReturnValue());
                if(responseJson.success){
                    var data = responseJson.data;
                    data.leads.forEach(function(element) {
                        element['Id'] = data.orgUrl +'/'+ element['Id'];    
                    });				
                    console.log(data);
                    component.set('v.leadList',data.leads);
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection'); 
        console.log(sortDirection);        
        helper.sortData(component, fieldName, sortDirection);        
        if(sortDirection == 'asc'){
            component.set("v.sortedDir", 'desc');
        } else {
           component.set("v.sortedDir", 'asc'); 
        }        
    }    
})