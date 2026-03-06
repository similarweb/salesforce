({
    redirectToZuoraSubmitPage : function(cmp) {
        var quoteId = cmp.get('v.recordId');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/zqu__ZuoraQuoteSubmit?scontrolCaching=1&id="+quoteId
        });
        urlEvent.fire();
    },

    sendQuotaToZuora : function(component) {
        // this.showModalPopupLoading(component,'Loading...',true);
        var action = component.get('c.submitQuote');
        action.setParams({"quoteId" : component.get('v.recordId'),"emailCofirmationValidation" : component.get('v.emailCofirmationValidation')});
        action.setCallback(this, function(response) {
            this.showModalPopupLoading(component,'Loading...',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    debugger;
                    this.showModalPopup(component,'Success!', 'Success! The subscription was successfully created in Zuora and the billing account was processed with the relevant information. For any further question about the billing account or invoices, please reach out to <a href="mailto:billing@similarweb.com" id="mymailto">billing@similarweb.com</a>');
                } else {
                    this.showModalPopup(component,'Error',responseObj.message);
                }
            } else {
                this.showModalPopup(component,'Error','Fatal error');
            }
        });
        $A.enqueueAction(action); 
    },

    quoteSubmittingProcess : function(component, event, helper) {
        helper.showModalPopupLoading(component,'Loading...',true);
        var action = component.get('c.finalizeQuote');
        action.setParams({"quoteId" : component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();  
            if(state === "SUCCESS") {
                var submitMode = component.get('v.submitMode');
                if (submitMode == 'Submit manually') {
                    helper.sendQuotaToZuora(component);
                } else if(submitMode == 'Redirect to Zuora submit page') {
                    helper.redirectToZuoraSubmitPage(component);
                }
            } else {
                helper.showModalPopup(component,'Error','Fatal error');
            }
        });
        $A.enqueueAction(action);   
    },

    validateSubscription : function(component, event, helper) {
        let action = component.get('c.validateSubscription');
        action.setParams({
            'quoteId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            let responseData = response.getReturnValue();
            if(state === "SUCCESS" && responseData.success !== "false"){
                if(responseData.content){
                    component.set('v.isOpenModal', true);
                } else{
                    helper.quoteSubmittingProcess(component, event, helper);
                }
            } else if(responseData != undefined){
                this.showModalPopup(component,'Error',responseData.message);
            } else {
                this.showModalPopup(component,'Error','Unexpected error');
            }
        });
        $A.enqueueAction(action);
    }

    // finalizeQuota : function(component) {
    //     var action = component.get('c.finalizeQuote');
    //     action.setParams({"quoteId" : component.get('v.recordId')});
    //     action.setCallback(this, function(response) {
    //         this.showModalPopupLoading(component,'Loading...',false);
    //         var state = response.getState();        
    //         if(state === "SUCCESS") {
    //             var responseObj = response.getReturnValue();
    //             if(responseObj.success){
    //                 debugger;
    //                 this.showModalPopup(component,'Success!', 'Success!');                        
    //             } else {
    //                 this.showModalPopup(component,'Error',responseObj.message);
    //             }
    //         } else {
    //             this.showModalPopup(component,'Error','Fatal error');
    //         }
    //     });
    //     $A.enqueueAction(action); 
    // }
})