({  
    doInit : function(component, event, helper) {
        helper.getQuoteList(component, event, helper);
    },
    closeModal : function(component, event, helper) {
        component.set('v.isOpenModal', false);
    },
    onNextButtonClick : function(component, event, helper) {
        helper.voidQuote(component, event, helper);
    }
})