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
                    component.set('v.baseProductPicklistValues',responseContent);
                }
            }
        });
        $A.enqueueAction(action);
    }
})