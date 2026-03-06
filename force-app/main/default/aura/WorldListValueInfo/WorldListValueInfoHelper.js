({
    deleteWordListValue : function(component, helper) {
        var fullNameToDelete = component.get('v.fullName');
        component.set('v.isLoading',true);
        var action = component.get('c.deleteWorldListPicklistValue');
        action.setParams({
            'fullNameToDelete' : fullNameToDelete
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.showToast('success','Success!','\''+fullNameToDelete+'\' succesfully deleted!');
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            }
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
    }
})