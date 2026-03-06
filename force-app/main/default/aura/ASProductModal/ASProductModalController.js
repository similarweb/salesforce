({
    doInit : function(component, event, helper) {
        helper.getQuoteValue(component, event, helper);
    },
    closeModal: function(component, event, helper) {
        component.set('v.isOpenModal', false);
    },

    skipAction: function(component, event, helper) {
        component.set('v.isOpenModal', false);
        helper.fireASEvent(component);
    },
    submitRequest : function(component, event, helper){
        helper.insertRequest(component,event, helper);
    },
    handleCustomLookupFieldEvent : function(component, event, helper){
        let message = event.getParam("message");
        let quoteFieldName = event.getParam("quoteFieldName");
        if(quoteFieldName == "recurring"){
            component.set('v.recurrencyRequest', message);
        } else if (quoteFieldName == "oneTime"){
            component.set('v.oneTimeRequest', message);
        }
    },
})