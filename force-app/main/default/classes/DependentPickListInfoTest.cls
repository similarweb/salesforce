@istest public class DependentPickListInfoTest {

    @istest public static void test(){
        DependentPickListInfo.getFieldDependencies('Task_Template__c', 'Task_Record_Type__c', 'Status__c');
    }
}