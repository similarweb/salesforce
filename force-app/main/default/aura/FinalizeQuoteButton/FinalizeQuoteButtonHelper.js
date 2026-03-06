({
    finalizeQuote : function(component,helper) {
        var action = component.get('c.startFinalizeQuoteFlow');
        action.setParams({"quoteId" : component.get('v.recordId')});
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.showToast('success','Success!','Success!');  
                    var refreshEvent = $A.get("e.c:ApplicationRefresgEvent");
                    refreshEvent.fire();
                    $A.get('e.force:refreshView').fire();                           
                } else {
                    helper.showToast('error','Error!',responseObj.message);
                }
            } else {
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