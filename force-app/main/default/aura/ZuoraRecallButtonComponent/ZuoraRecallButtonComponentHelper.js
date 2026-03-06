({
    recallAction : function(component, helper) {
        //component.set('v.isLoading',true);
        helper.showModalPopupLoading(component,'Loading...',true);
        var action = component.get('c.recallQuote');
        var params = {};
        params.quoteId = component.get('v.recordId');
        action.setParams(params);
        action.setCallback(this, function(response) {
            //component.set('v.isLoading',false);
            helper.showModalPopupLoading(component,'Loading...',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){  
                    //helper.showToast('success','Success!','Success!');
                    helper.showModalPopup(component,'Success!','You have just recall your quote.');
                } else {
                    //helper.showToast('error','Error!',responseObj.message);
                    helper.showModalPopup(component,'Error!',responseObj.message);
                }
            } else {
                helper.showModalPopup(component,'Error!','Fatal error!');
                //helper.showToast('error','Error!','Fatal error!');
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