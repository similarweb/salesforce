({
    triggerSubmitForApproval : function(component, helper,comment) {
        //component.set('v.isLoading',true);
        helper.showModalPopupLoading(component,'Loading...',true);
        var label = component.get('v.label');
        var action = component.get('c.submitQuoteForApproval');
        var params = {}
        params.quoteId = component.get('v.recordId');
        params.sourceName = label;
        if (comment) {
            params.approvalRequestComment = comment
        }
        action.setParams(params);
        action.setCallback(this, function(response) {
            //component.set('v.isLoading',false);
            helper.showModalPopupLoading(component,'Loading...',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){  
                    if (responseObj.message == 'Add a comment') {
                        component.set('v.isModalOpen',true);
                        helper.showModalPopupComment(component,'Add comment for approval request');
                    } else if (responseObj.message == 'Rejected') {
                        helper.showModalPopup(component,'Error','Deal size less than $5000 is not approved according to the company policy.<br/>Please consult with your manager or change the deal size to meet this requirement.');
                    } else if (responseObj.message == 'Pending') {
                        var pendingMessage = responseObj.message;
                        if (label == 'Deal Approval') {
                            pendingMessage = 'The quote was submitted successfully and it\'s pending GTM approval';
                        } else if(label == 'Finance Approval') {
                            pendingMessage = 'The quote was submitted successfully and it\'s pending Finance approval';
                        }
                        helper.showModalPopup(component,'Pending',pendingMessage);
                    } else if(responseObj.message == 'Rejected by Approval process'){
                        helper.showModalPopup(component,'Error',responseObj.message);
                    } else if(responseObj.message == 'Do not show popup') {
                        console.log('Popup view is disabled');
                    } else {
                        //helper.showToast('success','Success!',responseObj.message);
                        helper.showModalPopup(component,'Success!',responseObj.message);
                    }                            
                } else {
                    //helper.showToast('error','Error!',responseObj.message);
                    helper.showModalPopup(component,'Error!',responseObj.message);
                }
            } else {
                helper.showModalPopup(component,'Error!',responseObj.message);
                //helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action); 
    },
    checkQuoteForASRequests : function(component, event, helper) {
        var action = component.get('c.checkForASRequests');
        action.setParams({
            'quoteId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                let responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.triggerSubmitForApproval(component, helper);
                } else {
                    component.set('v.targetTotal', responseObj.content.targetTotalValue);
                    component.set('v.renewalFee', responseObj.content.renewalFeeValue);
                    helper.triggerSubmitForApproval(component, helper);
                    // component.set('v.isASModal', true);
                }
            } else {
                helper.showToast('error','Error!','Fatal error!');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        var params = {
            "title"   : title,
            "type"    : type,
            "duration": 10000
        };
        if (message) {
            params.message = message;
        }
        toastEvent.setParams(params);
        toastEvent.fire();
    },

    showModalPopup : function(component,title, message) {
        var modalWindowData = {};
        modalWindowData.title = title;
        modalWindowData.message = message;
        modalWindowData.isComment = false;
        component.set('v.modalWindowData',modalWindowData);
        component.set('v.isModalOpen',true);
    },

    showModalPopupComment : function(component,title) {
        var modalWindowData = {};
        modalWindowData.title = title;
        modalWindowData.isComment = true;
        component.set('v.modalWindowData',modalWindowData);
        component.set('v.isModalOpen',true);
    },

    showModalPopupLoading : function(component,title,isLoading) {
        var modalWindowData = {};
        modalWindowData.title = title;
        modalWindowData.isComment = false;
        component.set('v.isLoading',isLoading);
        component.set('v.modalWindowData',modalWindowData);
        component.set('v.isModalOpen',isLoading);
    }
})