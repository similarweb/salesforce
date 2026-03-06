({
	editCLCStage : function(cmp, event, helper) {
		cmp.set('v.currentLocation', 'record_detail');
    cmp.set('v.mode', 'edit_stage');
	},

  addStage : function(cmp, event, helper) {
    /*cmp.set('v.currentLocation', 'record_detail');
    cmp.set('v.mode', 'add_stage');*/
      var clcStage = cmp.get('v.recordId');
    var createRecordEvent = $A.get("e.force:createRecord");
    var currentHref = window.location.href;
    createRecordEvent.setParams({
        "entityApiName": "CLC_Stage__c", 
        "panelOnDestroyCallback": function(event) {
            window.location.href = currentHref + '?loc=record_detail&mode=stage_tasks&recordId='+clcStage;
        }
    });
    createRecordEvent.fire();
  },

  addTask : function(cmp, event, helper) {
    cmp.set('v.currentLocation', 'record_detail');
    cmp.set('v.mode', 'new_task');
      /*var clcStage = cmp.get('v.recordId');
      var currentHref = window.location.href;
      var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
        "entityApiName": "Task_Template__c",
        "defaultFieldValues": {
            'CLC_Stage__c' : clcStage
        }, 
        "panelOnDestroyCallback": function(event) {
            window.location.href = currentHref + '?loc=record_detail&mode=stage_tasks&recordId='+clcStage;
        }

    });
    createRecordEvent.fire();
    */
  }, 

  handleComponentEvent : function (cmp, event){
    var res = event.getParam('entityApiName');
    console.log('save');
  }
})