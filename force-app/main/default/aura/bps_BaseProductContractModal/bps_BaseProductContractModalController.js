({
    doInit : function(component, event, helper) {
        helper.loadData(component);   
    },

    onCancelClick : function(component, event, helper) {
        component.set('v.isShown', false);
    },

    onAddValuesClick : function(component, event, helper) {
        component.set('v.shownAddValuesModal', true);
    },

    onSaveClick : function(component, event, helper) {
        component.set('v.isLoading',true);
        var fullNameListRaw = component.get('v.valuesListRaw');
        if(fullNameListRaw){
            helper.addWordListPicklistValue(component,helper,fullNameListRaw);
        } else {
            helper.showToast('error','Error!','Input is empty');
        }
    },

    onSaveEditedValuesClick: function(component, event, helper) {
        component.set('v.isLoading',true);
        var newLabel = component.get('v.newLabel');
        var fullName = component.get('v.selectedRow').value;
        if(newLabel){
            helper.editWordListPicklistValue(component,helper,newLabel,fullName);
        } else {
            helper.showToast('error','Error!','Input is empty');
        }
    },

    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'removeRecord':                
                component.set('v.isLoading',true);
                helper.deleteWordListPicklistValue(component,helper,row.value);
                break;          
            case 'editRecord':                
                component.set('v.selectedRow',row);
                component.set('v.shownEditValuesModal',true);
                break;
        }
    },
})