public class CLCStageTriggerhandler {
  public void beforeInsert() {
    validateCLCStages((List<CLC_Stage__c>) Trigger.new, null);
  }
  public void beforeUpdate() {
    validateCLCStages(
      (List<CLC_Stage__c>) Trigger.new,
      (Map<ID, CLC_Stage__c>) Trigger.oldMap
    );
  }

  public static void validateCLCStages(
    List<CLC_Stage__c> newList,
    Map<ID, CLC_Stage__c> oldMap
  ) {
    Map<Id, List<Clc_Stage__c>> lookups = new Map<Id, List<Clc_Stage__c>>();
    String orderDulpicateMessage = '2 or more CLC Stages on the same order with the same business unit aren\'t allowed.';

    if (oldMap == null) {
      for (CLC_Stage__c stage_i : newList) {
        if (stage_i.Insert_After__c != null) {
          if (!lookups.containsKey(stage_i.Insert_After__c))
            lookups.put(stage_i.Insert_After__c, new List<CLC_Stage__c>());
          lookups.get(stage_i.Insert_After__c).add(stage_i);
        }
      }
    } else {
      for (CLC_Stage__c stage_i : newList) {
        if (
          (stage_i.Insert_After__c != null &&
          stage_i.Insert_After__c != oldMap.get(stage_i.Id).Insert_After__c) ||
          (stage_i.Business_Unit__c != null &&
          stage_i.Business_Unit__c != oldMap.get(stage_i.Id).Business_Unit__c)
        ) {
          if (!lookups.containsKey(stage_i.Insert_After__c))
            lookups.put(stage_i.Insert_After__c, new List<CLC_Stage__c>());
          lookups.get(stage_i.Insert_After__c).add(stage_i);
        }
      }
    }

    List<Clc_Stage__c> existingStages = [
      SELECT ID, Insert_After__c, Business_Unit__c
      FROM CLC_Stage__c
      WHERE Insert_After__c IN :lookups.keySet()
    ];
    for (Clc_Stage__c exist_i : existingStages) {
      for (Clc_Stage__c newStage : lookups.get(exist_i.Insert_After__c)) {
        if (newStage.Business_Unit__c == exist_i.Business_Unit__c) {
          newStage.addError(orderDulpicateMessage);
        }
      }
    }
  }
}
