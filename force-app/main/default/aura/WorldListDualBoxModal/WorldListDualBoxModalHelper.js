({
    saveWordPicklistValues : function(component, event, helper) {
        component.set('v.isLoading',true);

        var selectedWorldListPicklistValueFullNames = component.get('v.selectedWorldListPicklistValueFullNames');
        var controllingFieldValue = component.get('v.controllingFieldValue');
        var action = component.get('c.addDependencyWorldListPicklistValue');
        action.setParams({
            'controllingFieldValue' : controllingFieldValue,
            'fullNameListRaw' : JSON.stringify(selectedWorldListPicklistValueFullNames)
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    helper.showToast('success','Success!','Values succesfylly assigned to \''+controllingFieldValue+'\'!');
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