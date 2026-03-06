({
    handleSelectedContactsHelper : function(component, event, helper) {
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
         if(checkvalue != undefined){
            if(!Array.isArray(checkvalue)){
                if (checkvalue.get("v.value") == true) {
                    selectedContacts.push(checkvalue.get("v.text"));
                }
            }else{
                for (var i = 0; i < checkvalue.length; i++) {
                    if (checkvalue[i].get("v.value") == true) {
                        selectedContacts.push(checkvalue[i].get("v.text"));
                    }
                }
            }
         }
        component.set('v.selectedContactList', selectedContacts);
    },
    
    handleSelectAllContactHelper: function(component, event, helper) {
        var getID = component.get("v.contactList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
        helper.handleSelectedContactsHelper(component, event, helper);
    }
})