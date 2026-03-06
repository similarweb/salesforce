({
	handleClick : function(component, event, helper) {
        component.set('v.loading',true); // enable spinner
        var action = component.get('c.defaultQuantityToZero');
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var responseWrapper = JSON.parse(response.getReturnValue()); // checking if execution was successful
                if(responseWrapper.success) {
                    component.set('v.loading',false);
                    helper.showToast('success','Record updated - ' + responseWrapper.data);
                } else {
                    component.set('v.loading',false); // disable spinner
                    helper.showToast('error', responseWrapper.data); // show toast with error message
                }
            }     
            $A.get("e.force:closeQuickAction").fire()
        });
        $A.enqueueAction(action);
	}
})