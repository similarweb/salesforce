public class NewRequestOverrideButtonController {
  @AuraEnabled
  public static String obtainRequestRecordTypes(String oppId) {
    Map<String, Object> responseMap = new Map<String, Object>();
    List<RecordTypeWrapper> rtwList = new List<RecordTypeWrapper>();
    for (
      RecordTypeInfo info : Schema.Request__c.SobjectType.getDescribe()
        .getRecordTypeInfos()
    ) {
      if (info.isAvailable() && !info.isMaster()) {
        rtwList.add(new RecordTypeWrapper(info));
      }
    }
    responseMap.put('rtwList', rtwList);
    responseMap.put(
      'oppType',
      [SELECT Type FROM Opportunity WHERE Id = :oppId].Type
    );
    return JSON.serialize(responseMap);
  }

  public class RecordTypeWrapper {
    public String label;
    public String value;

    public RecordTypeWrapper(Schema.RecordTypeInfo rti) {
      this.label = rti.getName();
      this.value = rti.getRecordTypeId();
    }
  }
}
