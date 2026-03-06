({
    onNumOfUsersChange : function(component, event, helper) {
        component.set('v.isLoading',true);
        var baseProductFullName = component.get('v.baseProductFullName');
        var numberOfUsers = event.getSource().get("v.value");
        var action = component.get('c.setDefaultNumberOfUsersForBaseProduct');
        action.setParams({
            'numberOfUsers' : numberOfUsers,
            'controllingName' : baseProductFullName 
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.showToast('success','Success!','Success!');
                    var baseProductValueSelectedEvent = $A.get("e.c:bps_BaseProductValueSelected");        
                    baseProductValueSelectedEvent.fire();
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
                
            }
        });
        $A.enqueueAction(action);
    }
})