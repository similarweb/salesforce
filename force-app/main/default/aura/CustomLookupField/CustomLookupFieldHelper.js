({
	searchRecordsHelper : function(component, event, helper, value) {
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        component.set('v.message', '');
        component.set('v.recordsList', []);
		// Calling Apex Method
        let objectName = component.get('v.objectName');
        if(objectName == 'Request__c'){
            var action = component.get('c.fetchRequests');
            action.setParams({
                'searchString' : searchString,
                'quoteId' : component.get('v.recordId'),
                'requestType' : component.get('v.requestType')
            });
        } else {
            var action = component.get('c.fetchRecords');
            action.setParams({
                'objectName' : component.get('v.objectName'),
                'filterField' : component.get('v.fieldName'),
                'searchString' : searchString,
                'value' : value
            });
        }
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
					} else {
                        component.set('v.selectedRecord', result[0]);
					}
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + "'");
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
	},

    fireComponentEvent : function(component, event) {
        let clEvent = component.getEvent("clEvent");
        clEvent.setParams({
            "message" : component.get('v.selectedRecord').value,
            "quoteFieldName" : component.get('v.requestType')
        });
        clEvent.fire();
    }
})