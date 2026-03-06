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
                    component.set('v.isRelatedEnvelopesCompleted',responseObj.content.isRelatedEnvelopesCompleted);
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

    fileItemClickHandler : function(component, event) {
        var targer = event.currentTarget;
        var index = targer.getAttribute("data-index");
        var fileItem = component.get('{!v.opportunityAttachments}')[index];
        if (fileItem.isContentDocument) {
            $A.get('e.lightning:openFiles').fire({
                recordIds: [fileItem.recordId]
            });
        } else {
            window.open(window.location.origin + '/servlet/servlet.FileDownload?file=' + fileItem.recordId);
        }
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

    deleteRecord : function(component, helper, index) {
        var fileItem = component.get('{!v.opportunityAttachments}')[index];
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
                    helper.obtainFilesFromRelatedOpp(component, helper);
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            } else {
                helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action);
    },

    /*
    *   Author: Synebo Developer
    *   Last modified: 09/02/2022
    *   Description: MQ-1192. Method for editing a file.
    */
    editRecord : function(component, helper, index) {
        let fileItem = component.get('{!v.opportunityAttachments}')[index];
        let action = component.get('c.editFile');
        let titlteVar = component.get('v.titleText');
        let descriptionVar = component.get('v.descriptionText');

        action.setParams({
            'fileId' : fileItem.recordId,
            'title' : titlteVar,
            'description' : descriptionVar
        });

        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.showToast('success','Success!','File was updated.');
                    helper.obtainFilesFromRelatedOpp(component, helper);
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            } else {
                helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action);
        
    },

    viewAllClickHandler : function(component, event) {
        var relatedOpportunityId = component.get('{!v.relatedOpportunityId}');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/"+relatedOpportunityId+"/related/CombinedAttachments/view"
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

    uploadFile : function(component, event, helper){
        var action = component.get('c.validateQuoteStatus');
        action.setParams({
            'quoteId' : component.get('v.recordId'),
            'isSendToDocusign' : false
        });
        action.setCallback(this, function(response) {
            var isValidStatus = helper.validateQuoteStatus(helper,response);
            if(isValidStatus){
                component.set("v.showModal",true);
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
            helper.showToast('error','Error!','Fatal error!');
        }
        return isValidStatus;
    }
})