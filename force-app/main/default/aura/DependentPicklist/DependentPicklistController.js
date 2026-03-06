({
	doInit : function(cmp, event, helper) {
        var sobjectName = cmp.get('v.sobjectName'), 
            parent		= cmp.get('v.parentField'),
            dependent	= cmp.get('v.dependentField');
		
        var parentLbl = cmp.get('v.parentLabel');
        var dependentLabel = cmp.get('v.dependentLabel');
        
        if (!parentLbl || !dependentLabel){
            
            var action = cmp.get("c.getFieldDetails");
            action.setParams({
                sobjectName : sobjectName, 
                parent		: parent,
                dependent	: dependent
            });
            action.setCallback(this, function(response) {
                var resp = response.getReturnValue();
                if (resp.success) {
                    if (!parentLbl) {
                        parentLbl = resp.content.parentLabel;
                        cmp.set("v.parentLabel", resp.content.parentLabel); 
                    }
                    if (!dependentLabel) {
                        dependentLabel = resp.content.dependentLabel;
                        cmp.set("v.dependentLabel", resp.content.dependentLabel); 
                    }
                }  else {
                    alert(resp.message);
                    console.log(resp.message);
                }
            });
            $A.enqueueAction(action);
        } 
        
        var parentArr = [];
        var picklistValuesAction = cmp.get('c.getDependedPicklist');
        picklistValuesAction.setParams({
            sobjectName : sobjectName, 
            parent		: parent,
            dependent	: dependent
        }); 
        picklistValuesAction.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            if (resp.success) {
                cmp.set("v.dependencyList", resp.content);  
                for (var i=0;i<resp.content.length;i++){
                    parentArr.push(resp.content[i].key);                    
                }   
                var currentParent = resp.content[0].key.value;
                
                helper.fillPicklist(cmp, 'parentField', parentArr);
                var dependentArr = [];
                for (var i=0;i<resp.content.length; i++){
                    if (resp.content[i].key.value == currentParent){
                        dependentArr = resp.content[i].valueList;
                    }
                }
                helper.fillPicklist(cmp, 'dependentField', dependentArr);

                cmp.set('v.parentValue', currentParent);
                
            } else {
                alert(resp.message);
                console.log(resp.message);
            }
        });
        $A.enqueueAction(picklistValuesAction);
	}, 
    
    changeParent : function (cmp, event, helper){
        var parent = cmp.get('v.parentField');
        
        var newValue = cmp.get("v.parentValue");
        var dependencyList = cmp.get("v.dependencyList");
        var input = event.getSource();
        var select = cmp.find('parentField');
        var newArr = [];
        for (var i=0;i<dependencyList.length; i++){
            if (dependencyList[i].key.value == newValue){
                newArr = dependencyList[i].valueList;
            }
        }
        helper.fillPicklist(cmp,'dependentField', newArr);
    }, 
    
    changeDependent : function (cmp, event, helper) {
        var value = cmp.get('v.dependentValue');
        //window[cmp.get('v.dependentField')] = value;
    }
})