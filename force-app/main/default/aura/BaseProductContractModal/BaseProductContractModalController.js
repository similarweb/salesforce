({
    doInit : function(component, event, helper) {
        var columns = [
            {
                fieldName : "label",
                label : "Label",
                type : 'text'
            },
            {
                fieldName : "value",
                label : "Value",
                type : 'text'
            }
        ];
        var actions = [
            {
                'label': 'Delete record',
                'iconName': 'utility:delete',
                'name': 'removeRecord'
            },
            
            {
                'label': 'Edit records',
                'iconName': 'utility:edit',
                'name': 'editRecord'
            }
            ];
        var column={};
        column.typeAttributes={ rowActions: actions };
        column.type='action';
        columns.push(column);
        component.set('v.columns', columns);

        var action = component.get("c.retreiveBaseProductContractValues");
        component.set('v.isLoading', true);
        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                if(responseObj.success){
                    var responseContent = responseObj.content;
                    component.set('v.data',responseContent);
                }
            }
        });
        $A.enqueueAction(action);   
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
            var action = component.get('c.addBaseProductContractValues');
            action.setParams({
                'valuesListRaw' : fullNameListRaw
            });
            action.setCallback(this, function(response) {
                var state = response.getState();        
                if(state === "SUCCESS") {
                    var responseObj = response.getReturnValue();
                    if(responseObj.success){
                        helper.addWordListPicklistValue(component,helper,fullNameListRaw); 
                    } else {
                        component.set('v.isLoading',false);
                        helper.showToast('error','Error!',responseObj.message);
                    }
                    
                } else {
                    component.set('v.isLoading',false);
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.showToast('error','Error!','Input is empty');
        }
    },

    onSaveEditedValuesClick: function(component, event, helper) {
        component.set('v.isLoading',true);
        var newLabel = component.get('v.newLabel');
        var fullName = component.get('v.selectedRow').value;
        if(newLabel){
            var action = component.get('c.editBaseProductContractValues');
            action.setParams({
                'label' : newLabel,
                'value' : fullName
            });
            action.setCallback(this, function(response) {
                component.set('v.isLoading',false);
                var state = response.getState();        
                if(state === "SUCCESS") {
                    var responseObj = response.getReturnValue();
                    if(responseObj.success){
                        helper.editWordListPicklistValue(component,helper,newLabel,fullName);    
                    } else {
                        helper.showToast('error','Error!',responseObj.message);
                    }
                    
                }
            });
            $A.enqueueAction(action);
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
                helper.removeRecord(component,row.value,helper);
                break;          
            case 'editRecord':                
                component.set('v.selectedRow',row);
                component.set('v.shownEditValuesModal',true);
                break;
        }
    },
})