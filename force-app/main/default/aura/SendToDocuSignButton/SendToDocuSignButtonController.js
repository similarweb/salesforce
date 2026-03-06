({
    onInit : function(component, event, helper) {
        helper.obtainFilesFromRelatedOpp(component, helper);
    },
    handleApplicationRefreshFired : function(component, event, helper) {
        helper.obtainFilesFromRelatedOpp(component,helper);
    },
    sendToDocuSign : function(component, event, helper) {
        helper.sendToDocuSign(component,event,helper);
    },     
})