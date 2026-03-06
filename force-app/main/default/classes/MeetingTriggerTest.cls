/**
 * Created by alonshalev on 25/01/2023.
 */
@isTest(SeeAllData=true)
public with sharing class MeetingTriggerTest {
  static testMethod void runTest() {
    Meeting__c obj = new Meeting__c();
    insert obj;
    System.assert(obj.Id != null);
  }
}
