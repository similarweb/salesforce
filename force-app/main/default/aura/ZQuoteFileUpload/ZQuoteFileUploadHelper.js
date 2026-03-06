({
    initialize: function (component, event, helper) {
        var action = component.get("c.getUserProfileName");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                console.log('here');
                component.set("v.userProfileName", response.getReturnValue());
                // if (longTextExist && component.get("v.userProfileName") !== "SW Legal") {
                //     var longTextField = component.find("longTextField");
                //     longTextField.set("v.required", true);
                // }
            } else {
                console.error("Failed to retrieve profile name:", response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        component.set('v.uploadedFiles',uploadedFiles);
        var qId = component.get("v.quoteId");
        var action = component.get('c.setLookup'); 
        let signDate = component.get("v.dateAttr");
        let isFinalContract = component.get("v.isFinalContract");
        let longTextValue = component.get("v.longTextValue");
        
        action.setParams({
            "filesJson" : JSON.stringify(uploadedFiles),
            "quoteId" : qId,
            "oppId" : component.get("v.oppId"),
            "signDate" : signDate,
            "isFinalContract" : isFinalContract,
            "longTextValue" : longTextValue
        });
        action.setCallback(this, function(response, helper){
            var state = response.getState();
            if(state == 'SUCCESS') {
                console.log("success");
                component.set("v.showModal",false);
                var appEvent = $A.get("e.c:ApplicationRefresgEvent");
                appEvent.fire();
                $A.get('e.force:refreshView').fire();

            }else{
                var error = response.getError();
                console.log(error[0].message);
                helper.showToast('error', 'Error!', error[0].message);
                
            }
        });
        $A.enqueueAction(action);
        
    },
    handleProcessUpload: function(component, helper){
        var qId = component.get("v.quoteId");
        var action = component.get('c.validate');
        let isFinalContract = component.get("v.isFinalContract");

        action.setParams({
            "quoteId" : qId,
            "isFinalContract" : isFinalContract
        });
        action.setCallback(this, function(response,helper){
            var state = response.getState();
            if(state == 'SUCCESS') {
                console.log("success");
                component.set('v.currStep',2);
            }else{
                var error = response.getError();
                console.log(error[0].message);
                helper.showToast('error', 'Error!', error[0].message);
            }
        });
        $A.enqueueAction(action);

    },
    closeModal: function (component, event, helper){
        // This will contain the List of File uploaded data and status
        component.set("v.showModal",false);
    },
    
    showToast : function(type, title, message) {
        var toastEvent = $A.get('e.force:showToast');
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
    }
})