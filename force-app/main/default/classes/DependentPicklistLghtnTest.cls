@istest
public class DependentPicklistLghtnTest {

    @istest public static void test(){
        DependentPicklistLghtn.getDependedPicklist('Task_Template__c', 'Task_Record_Type__c', 'Status__c');
        DependentPicklistLghtn.getFieldDetails('Task_Template__c', 'Task_Record_Type__c', 'Status__c');
    }
}