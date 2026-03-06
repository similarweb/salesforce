({
    obtainFilesFromRelatedOpp : function(component, helper) {
        var action = component.get('c.obtainFilesFromRelatedOpportunity');
        action.setParams({
            'quoteId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    component.set('v.opportunityAttachments',responseObj.content.fileWrapperList);
                    if( responseObj.content.fileWrapperList[0] != null &&
                        responseObj.content.fileWrapperList[0].ownerName == 'Salesforce Admin'){
                        component.set('v.isSendToDocuSignAvailable',true);
                    }else{
                        component.set('v.isSendToDocuSignAvailable',false);
                    }
                    component.set('v.relatedOpportunityId',responseObj.content.relatedOpportunityId);
                    component.set('v.isMoreFiles',responseObj.content.isMoreFiles);
                    component.set('v.docusignLink',responseObj.content.docusignLink);
                    component.set('v.isGreenLine',responseObj.content.isGreenLine);
                    if(responseObj.content.startUpon == "Signature Date"){
                        component.set('v.signatureDateMode',true);
                    }else{ 
                        component.set('v.signatureDateMode',false);
                    }
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            } else {
                helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action);
    },
    sendToDocuSign : function(component, event, helper) {

        var action = component.get('c.validateQuoteStatus');
        action.setParams({
            'quoteId' : component.get('v.recordId'),
            'isSendToDocusign' : true
        });
        action.setCallback(this, function(response) {
            var isValidStatus = helper.validateQuoteStatus(helper,response);
            if(isValidStatus){
                var navService = component.find("navService");
                var docuSignLink = component.get("v.docusignLink");
                var pageReference = {
                    type: 'standard__webPage',
                    attributes: {
                        url: docuSignLink
                    }
                };
                navService.navigate(pageReference);
            }
        });
        $A.enqueueAction(action);
    },
    validateQuoteStatus : function(helper,response){
        var state = response.getState();
        var isValidStatus = false;
        if(state === "SUCCESS") {
            var responseObj = response.getReturnValue();
            if(responseObj.success){
                isValidStatus = true;
            } else {
                helper.showToast('error','Error!',responseObj.message);
            }
        } else {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    helper.showToast('error','Error!','Fatal error: '+ errors[0].message);
                } else if(errors[0] && errors[0].pageErrors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message){
                    helper.showToast('error','Error!','Fatal error: '+ errors[0].pageErrors[0].message);
                } else {
                    helper.showToast('error','Error!','Fatal error: Unknown error');
                }
            } else {
                helper.showToast('error','Error!','Fatal error: Unknown error');
            }
        }
        return isValidStatus;
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