({
    generatePreviewContract : function(component, helper, isSendToZuora) {
        var date1 = new Date();
        component.set('v.isLoading',true);
        var action = component.get('c.generatePreviewContract');
        action.setParams({"quoteId" : component.get('v.recordId'), "isValidate" : component.get('v.isValidate')});
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    component.set('v.isLoading',true);
                    component.set('v.zuoraFileUrl',responseObj.content);
                    helper.checkIfContractGeneratedAndSaveInSf(component,helper,date1,isSendToZuora);
                } else {
                    /* helper.showToast('error','Error!',responseObj.message); */
                    helper.showModalPopup(component,'Error',responseObj.message);
                    $A.get("e.force:closeQuickAction").fire();
                }
            } else {
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    checkIfContractGeneratedAndSaveInSf : function(component, helper,date1,isSendToZuora) {
        component.set('v.isLoading',true);
        var action = component.get('c.obtainAndSaveContract');
        var buttonLabel = component.get('v.buttonLabel');
        action.setParams(
            {
                "quoteId" : component.get('v.recordId') || component.get('v.storedQuoteId'),
                "fileUrl" : component.get('v.zuoraFileUrl'),
                "buttonMode" : buttonLabel,
                "modeRaw" : 'saving',
                "isFinalize" : component.get('v.finalizeQuote')
            });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();
            if(state === "SUCCESS") {

                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    component.set('v.salesforceFileId',responseObj.message);
                    var date2 = new Date();
                    console.log(diff_seconds(date2,date1));
                    if (buttonLabel == 'Proforma Invoice' || buttonLabel == 'Generate Proforma') {
                        helper.showModalPopupOptions(component
                            , 'Success!'
                            , 'Please note as soon as payment has been received, the quote will be processed by the billing team and the account will be activated.'
                            , [{'title' : 'Next', 'event' : {'name' : 'e.lightning:openFiles', 'body' : {'recordIds': [responseObj.message]}}}]);
                    } else {
                        if(isSendToZuora === true){
                            helper.sendToDocuSign(component, helper);
                        } else {
                            setTimeout($A.getCallback(function(){
                                $A.get('e.lightning:openFiles')
                                  .fire({
                                    recordIds: [responseObj.message]
                                   });
                            }), 1000);
                        }
                    }
                    //if(isSendToZuora !== true){
                        var refreshEvent = $A.get("e.c:ApplicationRefresgEvent");
                        refreshEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    //}
                    //window.open(responseObj.message);
                    function diff_seconds(dt2, dt1) {
                        var diff =(dt2.getTime() - dt1.getTime()) / 1000;
                        return Math.abs(Math.round(diff));
                    }
                } else {
                    //helper.showToast('error','Error!',responseObj.message);
                    helper.showModalPopup(component,'Error',responseObj.message);
                }
            } else {
            }
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);

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

    openGenerateContractDecision : function(component, helper) {
        component.set('v.isGenerateContractDecision',true);
    },

    sendToDocuSign : function(component, helper) {
        var action = component.get('c.sendToDocuSign');
        action.setParams({
            'quoteId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    var isValidStatus = helper.validateQuoteStatus(helper,response);
                    if(isValidStatus){
                        var navService = component.find("navService");
                        var docuSignLink = responseObj.content.docusignLink;
                        var pageReference = {
                            type: 'standard__webPage',
                            attributes: {
                                url: docuSignLink
                            }
                        };
                        navService.navigate(pageReference);
                    }
                } else {
                    helper.showModalPopup(component,'Error',responseObj.message);
                }
            } else {
                console.log('State is not SUCCESS');
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
    },

    checkQuoteForASRequests : function(component, event, helper){
        console.log('stop!!!!')
        var action = component.get('c.checkForASRequests');
        if(component.get('v.recordId')){
            component.set('v.storedQuoteId',component.get('v.recordId'));
        }
        action.setParams({
            'quoteId' : component.get('v.recordId') || component.get('v.storedQuoteId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                let responseObj = response.getReturnValue();
                if(responseObj.content.isValidQuote){
                    helper.generatePreviewContract(component,helper);
                } else {
                    component.set('v.targetTotal', responseObj.content.targetTotalValue);
                    component.set('v.renewalFee', responseObj.content.renewalFeeValue);
                    helper.generatePreviewContract(component, helper);
                    // component.set('v.isOpenModal', true);
                }
            } else {
                console.log('error error');
                helper.showToast('error','Error!','Fatal error!');
            }
            component.set('v.isSpinner', false);
        });
        $A.enqueueAction(action);
        component.set('v.isSpinner', true);

    },
})