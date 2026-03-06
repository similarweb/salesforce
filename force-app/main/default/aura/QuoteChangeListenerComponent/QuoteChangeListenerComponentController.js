({
  doInit: function (component, event, helper) {
    //MQ-1371
    //This functionality is transported to the "ReassignButtons" component
    // var channel='/data/zqu__Quote__ChangeEvent';
    // var sub;
    // var replayId=-1;
    // var empApi = component.find('empApi');
    // empApi.subscribe(channel, replayId, $A.getCallback(message => {
    //     var isSelfSaving = component.get('v.isSelfSaving');
    //     //if(!isSelfSaving){
    //         var modifiedRecords = message.data.payload.ChangeEventHeader.recordIds;
    //         var changedFields = message.data.payload.ChangeEventHeader.changedFields;
    //         var commitUser = message.data.payload.ChangeEventHeader.commitUser;
    //         var currentRecordId = component.get('v.recordId');
    //         var userId = $A.get("$SObjectType.CurrentUser.Id");
    //         var allowedFieldsArr = ['Total_Discount__c','zqu_Quote_Status__c','zqu__Previewed_SubTotal__c'];
    //         var isRefreshAllowed = component.get('v.isRefreshAllowed');
    //         for (const changedField_i of changedFields) {
    //             if (allowedFieldsArr.includes(changedField_i)) {
    //                 isRefreshAllowed = true;
    //                 component.set('v.isRefreshAllowed',isRefreshAllowed);
    //                 break;
    //             }
    //         }
    //         if (modifiedRecords.includes(currentRecordId)
    //             && commitUser == userId
    //             && (message.data.payload.zqu__Is_Charge_Expired__c ||
    //                 message.data.payload.zqu_Quote_Status__c ||
    //                 message.data.payload.zqu__Previewed_SubTotal__c /* ||
    //                 changedFields.some(r=> allowedFieldsArr.indexOf(r) >= 0) */)
    //             && isRefreshAllowed)
    //         {
    //             isRefreshAllowed = false;
    //             component.set('v.isRefreshAllowed',isRefreshAllowed);
    //             /* var toastEvent = $A.get("e.force:showToast");
    //             toastEvent.setParams({
    //                 "message": $A.get("$Label.c.Record_has_been_modified_by_Zuora_package"),
    //                 "type": "warning"
    //             });
    //             toastEvent.fire(); */
    // 			//component.find('recordLoader').reloadRecord(true,$A.getCallback(function() {console.log(lal)}));
    //             component.set('v.isSelfSaving',false);
    //             if (changedFields.includes('zqu_Quote_Status__c') && !message.data.payload.zqu_Quote_Status__c) {
    //                 location.reload();
    //             } else {
    //                 $A.get('e.force:refreshView').fire();
    //             }
    //         }
    // 	//}
    // })).then(function(value) {
    //     console.log("Subscribed to channel " + channel);
    // });
  },

  recordUpdated: function (component, event, helper) {
    var eventParams = event.getParams();
    var changeType = eventParams.changeType;
    if (changeType === "LOADED") {
      /* var ff = component.get('v.record');
            ff.fields.zqu__Amendment_Name__c.displayValue = 'dsdasd';
            ff.fields.zqu__Amendment_Name__c.value = 'dsdasd';
            component.set('v.record',ff);
            console.log(component.get('v.isSelfSaving')); */
    } else if (changeType === "CHANGED") {
      component.set("v.isSelfSaving", true);
      console.log("SelfSaving");
    }
  }
});
