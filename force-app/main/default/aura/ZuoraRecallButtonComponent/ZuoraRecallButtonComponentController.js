({
    onButtonClick : function(component, event, helper) {
        helper.recallAction(component, helper);
    },

    onCancelClick : function(component, event, helper) {
        component.set('v.isModalOpen',false);
    }
})