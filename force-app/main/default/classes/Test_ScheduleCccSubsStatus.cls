@isTest
private without sharing class Test_ScheduleCccSubsStatus {
    
  @testSetup
  static void setup() {
    Utils.isTest = true;
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Account a = TestObjectCreator.createAccount();
    insert a;
  }
        
    @isTest 
    static void testScheduleAccSubsCalc1() {
    Account a = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    Zuora__Subscription__c zs1 = TestObjectCreator.createZSubscription(a);
    zs1.Zuora__NextRenewalDate__c = Date.today().adddays(-1);
    insert zs1;
    
    String jobId1 = System.schedule(
      'Schedule_LeadAssignSelfService1', 
      Schedule_CalccSubsStatus.CRON_EXP, 
      new Schedule_CalccSubsStatus()
    );
    Test.stopTest();
  }

  @isTest   
    static void testScheduleAccSubsCalc2() {
    Account a = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    Zuora__Subscription__c zs2 = TestObjectCreator.createZSubscription(a);
    zs2.Zuora__NextRenewalDate__c = Date.today().adddays(-1);
    zs2.Zuora__Status__c = 'Cancelled';
    insert zs2;
    
    String jobId2 = System.schedule(
      'Schedule_LeadAssignSelfService2', 
      Schedule_CalccSubsStatus.CRON_EXP, 
      new Schedule_CalccSubsStatus()
    );
    Test.stopTest();
  }

  @isTest
  static void testScheduleAccSubsCalc3() {
    Account a = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    Zuora__Subscription__c zs3 = TestObjectCreator.createZSubscription(a);
    zs3.Zuora__NextRenewalDate__c = Date.today().adddays(1);
    insert zs3;
  
    String jobId3 = System.schedule(
      'Schedule_LeadAssignSelfService3', 
      Schedule_CalccSubsStatus.CRON_EXP, 
      new Schedule_CalccSubsStatus()
    );
    Test.stopTest();
  }
    
  @isTest
  static void TestvfTestBatch_CalculateAccSubStatus() {
    vfTestBatch_CalculateAccSubStatus cls = new vfTestBatch_CalculateAccSubStatus();
    vfTestBatch_CalculateAccSubStatus.RunSubBatch();
  }
}