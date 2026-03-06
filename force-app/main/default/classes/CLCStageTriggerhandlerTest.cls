@istest
public class CLCStageTriggerhandlerTest {
  @istest
  static void test() {
    List<CLC_Stage__c> parents = new List<CLC_Stage__c>{
      new CLC_Stage__c(Name = 'Activation', Business_Unit__c = 'Inside Sales'),
      new CLC_Stage__c(Name = 'Activation', Business_Unit__c = 'Enterprise')
    };
    insert parents;
    String orderDulpicateMessage = '2 or more CLC Stages on the same order with the same business unit aren\'t allowed.';
    CLC_Stage__c newOkStage = new CLC_Stage__c(
      Name = 'Adoption',
      Business_Unit__c = 'Inside Sales',
      Insert_After__c = parents[0].Id
    );
    try {
      insert newOkStage;
      insert new CLC_Stage__c(
        Name = 'Adoption 2',
        Business_Unit__c = 'Inside Sales',
        Insert_After__c = parents[0].Id
      );
    } catch (Exception e) {
      System.assert(e.getMessage().contains(orderDulpicateMessage));
    }

    try {
      parents[1].Business_Unit__c = 'Inside Sales';
      update parents[1];
    } catch (Exception e) {
      System.assert(e.getMessage().contains(orderDulpicateMessage));
    }
  }
}
