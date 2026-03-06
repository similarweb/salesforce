trigger TraceLogOpportunityTrigger on Opportunity(after update) {
  List<Trace_Log__c> traceLogs = new List<Trace_Log__c>();
  System.debug('!!! TRIGGER FIRED !!!');
  for (Opportunity newOpp : (List<Opportunity>) Trigger.new) {
    try {
      System.debug('!!! TRIGGER in try block !!!');
      if (newOpp.Name != Trigger.oldMap.get(newOpp.Id).get('Name')) {
        Trace_Log__c traceLog = new Trace_Log__c();
        traceLog.Log__c =
          System.Request.getCurrent().getQuiddity() + '  | *********** |  ';
        traceLog.Log__c +=
          ' Username : ' +
          UserInfo.getUserName() +
          '  | *********** |  ';
        traceLog.Context__c = newOpp.Id;
        traceLog.Name = 'BUG MIS-8338';
        Map<String, Object> fieldMap = newOpp.getPopulatedFieldsAsMap();
        for (String fieldName : fieldMap.keySet()) {
          Object newVal = fieldMap.get(fieldName);
          Object oldVal = Trigger.oldMap.get(newOpp.Id).get(fieldName);
          if (newVal != oldVal) {
            traceLog.Log__c +=
              fieldName +
              ' : ' +
              (newVal != null ? String.valueOf(newVal) : 'null') +
              ' ->->-> ' +
              (oldVal != null ? String.valueOf(oldVal) : 'null') +
              '  |---------------------------------------------------|  ';
          }
        }
        traceLogs.add(traceLog);
      }
      System.debug('!!! TRIGGER END !!!');
    } catch (Exception e) {
      System.debug('Error: ' + e.getMessage());
    }
  }
  if (!traceLogs.isEmpty()) {
    insert traceLogs;
  }
}
