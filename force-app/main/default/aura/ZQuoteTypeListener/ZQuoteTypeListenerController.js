({
	doInit : function(component, event, helper) {
        
        
        var action = component.get('c.getQType'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "firstName" : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                if(a.getReturnValue() == true){
                	component.set("v.isDisplay", true);
                }
                
            }
        });
        $A.enqueueAction(action);

	}
})