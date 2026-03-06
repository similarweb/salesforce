({
    doInit : function(component, event, helper) {
        var action = component.get("c.obtainContactList");
        let quoteRecordId = component.get('v.quoteRecordId');
        let emailList = component.get('v.emailList');
        let defaultChecked = component.get('v.defaultChecked');
        let contactList = [];
        action.setParams({
            'quoteId' : quoteRecordId
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var responseArr = result.getReturnValue();
                for (var i = 0; i < responseArr.length; i++) {
                    contactList.push(responseArr[i]);
                }
                component.set("v.contactList",contactList); 
                if(defaultChecked){
                    var checkContact = component.find("checkContact"); 
                    if(checkContact != undefined){
                        if(!Array.isArray(checkContact)){
                            if(emailList.includes(checkContact.get('v.text'))){
                                checkContact.set("v.value",true);
                            }
                        }else{
                            if(checkContact != undefined){
                                for(var i=0; i<checkContact.length; i++){
                                    if(emailList.includes(checkContact[i].get('v.text'))){
                                        checkContact[i].set("v.value",true);
                                    }
                                }
                            }
                        }
                    }
                }
                helper.handleSelectedContactsHelper(component, event, helper);
            }
        });
        $A.enqueueAction(action);

    },
     
    handleSelectAllContact: function(component, event, helper) {
        helper.handleSelectAllContactHelper(component, event, helper);
    },
     
    handleSelectedContacts: function(component, event, helper) {
        helper.handleSelectedContactsHelper(component, event, helper);
    }
})