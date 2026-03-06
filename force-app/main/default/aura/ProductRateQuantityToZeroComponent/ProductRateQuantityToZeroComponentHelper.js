({
	showToast : function(status,message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message" : message,
            "type" : status
        });
        toastEvent.fire();
    }
})