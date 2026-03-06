({
    obtailnRelatedQuotesAction : function(component, helper) {
        var action = component.get('c.obtailnRelatedQuotes');
        action.setParams({
            'quoteId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    console.log('SUCCES OBTAIN');
                    component.set('v.relatedOppList',responseObj.content.itemWrapperList);
                    component.set('v.relatedOpportunityId',responseObj.content.relatedOpportunityId);
                    component.set('v.isMoreItems',responseObj.content.isMoreItems);
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            } else {
                helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action);
    },

    fileItemClickHandler : function(component, event) {
        var targer = event.currentTarget;
        var index = targer.getAttribute("data-index");
        var fileItem = component.get('{!v.relatedOppList}')[index];
        if (fileItem.isContentDocument) {
            $A.get('e.lightning:openFiles').fire({
                recordIds: [fileItem.recordId]
            });
        } else {
            window.open(window.location.origin + '/' + fileItem.recordId);
        }
    },

    /* deleteRecord : function(component, helper, index) {
        var fileItem = component.get('{!v.relatedOppList}')[index];
        var action = component.get('c.deleteFile');
        action.setParams({
            'fileId' : fileItem.recordId
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.showToast('success','Success!','File was deleted.');
                    helper.obtailnRelatedQuotesAction(component, helper);
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            } else {
                helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action);
    }, */

    viewAllClickHandler : function(component, event) {
        var relatedOpportunityId = component.get('{!v.relatedOpportunityId}');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/"+relatedOpportunityId+"/related/zqu__Quotes__r/view"
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
    },
})