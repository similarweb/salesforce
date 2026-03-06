({
    obtainRequestsFromRelatedOpp : function(component, helper) {
        var action = component.get('c.obtainRequestsFromRelatedOpportunity');
        action.setParams({
            'quoteId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    component.set('v.opportunityRequests',responseObj.content.requestWrapperList);
                    component.set('v.relatedOpportunityId',responseObj.content.relatedOpportunityId);
                    component.set('v.isMoreRequests',responseObj.content.isMoreRequests);
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            } else {
                helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action);
    },

    requestItemClickHandler : function(component, event) {
        var targer = event.currentTarget;
        var index = targer.getAttribute("data-index");
        var requestItem = component.get('{!v.opportunityRequests}')[index];
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": requestItem.recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },

    viewAllClickHandler : function(component, event) {
        var relatedOpportunityId = component.get('{!v.relatedOpportunityId}');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/"+relatedOpportunityId+"/related/Requests__r/view"
        });
        urlEvent.fire();
    },

    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        var params = {
            "title"   : title,
            "type"    : type
        };
        if (message) {
            params.message = message;
        }
        toastEvent.setParams(params);
        toastEvent.fire();
    }
})