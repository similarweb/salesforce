({
    doInit : function(component, event, helper) {
        helper.initHelper(component, helper);		
    },
    handleSaveClick : function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        var draftValues = event.getParam('draftValues');          
        helper.saveRecord(component,draftValues,helper);  
    },
    reindexData : function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        var action = component.get("c.recalculateIndex");     
        action.setParams({
            "type" : component.get('v.currentObject')
        });
        action.setCallback(this, function(response) {      
            component.set('v.loaded', !component.get('v.loaded'));
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseJson = JSON.parse(response.getReturnValue());
                if(responseJson.success){            
                    helper.showToast(component,'Success!','success');
                    helper.initHelper(component,helper);
                } else {
                    helper.showToast(component,responseJson.message,'error');
                }
            }
        });
        $A.enqueueAction(action);
    },    
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'removeRecord':                
                cmp.set('v.loaded', !cmp.get('v.loaded'));
                helper.removeRecord(cmp,row.Name,helper);
                break;          
            case 'editRecord':                
                cmp.set('v.modalMode','editRecord');
                cmp.set('v.modalHeader','Edit record');
                helper.editRecord(cmp,row);
                cmp.set("v.isModalOpen", true);
                break;
        }
    },
    openModel: function(component, event, helper) {
        var sourceTitle = event.getSource().get("v.title");        
        if(sourceTitle=='Create record'){
            component.set('v.modalMode','createRecord');
            component.set('v.modalHeader','Add line');
            helper.createRecord(component);
        } else if(sourceTitle=='Remove column'){
            component.set('v.modalMode','removeColumn');
            component.set('v.modalHeader','Remove column');
        } else if(sourceTitle=='Create column'){
            component.set('v.modalMode','createColumn');
            component.set('v.modalHeader','Create column');
            component.set('v.newColumn','');            
        } else if(sourceTitle=='Set default value'){
            component.set('v.modalMode','setDefaultValue');      
            component.set('v.modalHeader','Set default value');
        }else if(sourceTitle=='Apply logic to all objects'){
            component.set('v.additionalConditionCheckMessage', '');
            component.set('v.additionalCondition', '');
            component.set('v.isConditionEnabled', false);
            helper.checkBatch(component,helper);
            component.set('v.modalMode','runBatch');       
            component.set('v.modalHeader','Apply logic to all objects');
        }else if(sourceTitle=='Set Condition'){
            component.set('v.modalMode','setCondition');
            component.set('v.modalHeader','Set Condition');
        }
        component.set("v.isModalOpen", true);
    },
    resetCondition: function(component, event, helper) {
        component.set('v.additionalConditionCheckMessage', '');
        component.set('v.isConditionEnabled', false);
    },
    
    closeModel: function(component, event, helper) {       
        component.set("v.isModalOpen", false);
    },
    
    saveModal: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        debugger;
        var modalMode = component.get('v.modalMode');
        if(modalMode == 'createRecord'){
            var newRecord = component.get('v.newRecord');
            var mockList = [];
            mockList.push(newRecord);
            helper.saveRecord(component,mockList,helper);
        }       
        if(modalMode == 'createColumn'){
            helper.createColumn(component,helper);
        }if(modalMode == 'removeColumn'){
            helper.removeColumn(component,helper);
        }
        if(modalMode == 'editRecord'){
            var editedRecord = component.get('v.editedRecord');
            var mockList = [];
            mockList.push(editedRecord);
            helper.saveRecord(component,mockList,helper);
        }
        if(modalMode == 'setDefaultValue'){           
            helper.saveDefaultValue(component,helper);
        }
        if(modalMode == 'setCondition'){           
            helper.checkCondition(component,helper);
        } else{
            component.set("v.isModalOpen", false);
        }
    },    
    runBatch: function(component, event, helper) {
        debugger;
        component.set('v.loaded', !component.get('v.loaded'));
        var action = component.get("c.runLogic");     
        action.setParams({
            "type" : component.get('v.currentObject'),          
            "condition" : component.get('v.isConditionEnabled') ? component.get('v.additionalCondition') : null,        	
        });
        
        action.setCallback(this, function(response) {
            component.set('v.loaded', !component.get('v.loaded'));
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseJson = JSON.parse(response.getReturnValue());
                if(responseJson.success){            
                    helper.showToast(component,'Success!','success');
                } else {
                    helper.showToast(component,responseJson.message,'error');
                }
            } 
        });
        $A.enqueueAction(action);
        component.set("v.isModalOpen", false);
    },
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})