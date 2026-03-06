({
    onSaveClick : function(component, event, helper) {
        component.set('v.isLoading',true);
        var newLabel = component.get('v.newLabel');
        var fullName = component.get('v.fullName');
        if(newLabel){
            var action = component.get('c.editBaseProductPicklistValues');
            action.setParams({
                'label' : newLabel,
                'fullName' : fullName
            });
            action.setCallback(this, function(response) {
                component.set('v.isLoading',false);
                var state = response.getState();        
                if(state === "SUCCESS") {
                    var responseObj = response.getReturnValue();
                    if(responseObj.success){
                        helper.showToast('success','Success!','Label is succesfully changed to \''+ newLabel +'\'!');
                        $A.get('e.force:refreshView').fire();    
                    } else {
                        helper.showToast('error','Error!',responseObj.message);
                    }
                    
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.showToast('error','Error!','Input is empty');
        }
    },

    onCancelClick : function(component, event, helper) {
        component.set('v.isShown', false);
    }
})