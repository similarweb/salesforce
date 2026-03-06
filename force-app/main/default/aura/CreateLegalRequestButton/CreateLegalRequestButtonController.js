({
    onInit: function(component, event, helper) {
        helper.obtainLegalRequestRecordTypeId(component, event, helper);
    },
     
    onButtonClick : function(component, event, helper) {
        helper.redirectToCreateRequest(component,event,helper);
    }
})