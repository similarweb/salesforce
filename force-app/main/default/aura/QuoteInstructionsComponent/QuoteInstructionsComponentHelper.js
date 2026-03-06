({
    getQuoteInstructions : function(component) {
        var action = component.get('c.obtainQuoteInstructions');
        action.setParams({"quoteStatus" : component.get('v.quoteStatus')});
        action.setCallback(this, function(response) {
            component.set('v.isLoading',false);
            var state = response.getState();        
            if(state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    var instructionsArray = []
                    for (const instr_i of responseObj.content) {
                        if (instr_i.Instructions__c) {
                            instr_i.Instructions__c = instr_i.Instructions__c.replace(/(?:\r\n|\r|\n)/g, '<br>')
                        }
                        instructionsArray.push(instr_i);
                    }
                    component.set('v.instructionsArray',instructionsArray);
                } else {
                    //helper.showToast('error','Error!',responseObj.message);
                }
            } else {
            }
        });
        $A.enqueueAction(action); 
    }
})