({
    obtainBaseProductPicklistValues : function(component) {
        component.set('v.isLoading',true);
        var action = component.get('c.retreiveBaseProductPicklistValues');
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    var responseContent = responseObj.content;
                    
                    responseContent.sort(function (a, b) {
                        if (a.label > b.label) {
                            return 1;
                        }
                        if (b.label > a.label) {
                            return -1;
                        }
                        return 0;
                    });
                    component.set('v.baseProductPicklistValues',responseContent);
                }
            }
        });
        $A.enqueueAction(action);
    },

    deleteBaseProductValue : function(component, helper) {
        var fullNameToDelete = component.get('v.baseProductFullName');
        component.set('v.isLoading',true);
        var action = component.get('c.deleteBaseProductPicklistValues');
        action.setParams({
            'fullNameToDelete' : fullNameToDelete
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.showToast('success','Success!','\ '+fullNameToDelete+'\' succesfully deleted!');
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