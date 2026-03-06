trigger ZQuoteTrigger on zqu__Quote__c(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  /* 
    map <string,CSTriggerControl__c> cstrigControl = CSTriggerControl__c.getall();
    List<Schema.SObjectType> objects = new List<Schema.SObjectType>{ zqu__Quote__c.SObjectType};
    List<String> ch = new List<String>();
    
    for(Schema.SObjectType objType: objects){
        for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
            
            ch.add(fld.getDescribe().getName());
        }
    }
     system.debug('TESTING fired zqu__Quote__c. Utils is '+Utils.CodeOff);
     if (!utils.CodeOff)
     {
         if (!cstrigControl.ContainsKey ('ZQuote') || (cstrigControl.ContainsKey('ZQuote') && cstrigControl.get('ZQuote').on__c))
         {
            if (trigger.IsBefore)
            {                       // BEFORE - START
                if (trigger.isInsert)
                {                       // INSERT - START
                    system.debug('TESTING TRIGGER Fired, Before Insert');
                    ZQuoteHandler.HandleBefore (trigger.new, null, 'Insert');
                }                       // INSERT - END
                
                
                if (trigger.isUpdate)
                {                       // UPDATE - START
                    for(zqu__Quote__c newQuote_i:trigger.new){
                        System.debug('Quote ID - ' + newQuote_i.Id);
                        zqu__Quote__c oldQuote_i = trigger.oldMap.get(newQuote_i.Id);
                        for(String fieldName_i :ch){
                            if(newQuote_i.get(fieldName_i)!=oldQuote_i.get(fieldName_i)){
                                System.debug('----------------');
                                System.debug('FIELDNAME - ' + fieldName_i);
                         		System.debug('NEW VALUE - ' + newQuote_i.get(fieldName_i) + ' OLD VALUE - ' + oldQuote_i.get(fieldName_i));       
                                System.debug('----------------');
                            }
                        }                        
                    }
                    system.debug('TESTING TRIGGER Fired, Before Update');
                    ZQuoteHandler.HandleBefore (trigger.new, trigger.oldmap, 'Update');
                }                       // UPDATE - END
            }                       // BEFORE - END

             system.debug('Trigger: After insert');
            
            if (trigger.isAfter && !Utility.isAfterDisabled)
            {                       // AFTER - START
                if (trigger.isUpdate)
                {                       // UPDATE - START
                    system.debug('TESTING TRIGGER Fired, After Update');
                     ZQuoteHandler.HandleAfter (trigger.new, trigger.oldmap, 'Update');
                    System.enqueueJob(new z_AccountCustomFieldsUpdate());
                        
                }                       // UPDATE - END
            }                       // AFTER - END
         }
     }
 */
}
