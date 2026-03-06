/**
* @author Itzik Winograd
* @date 29/12/2022
* @description MIS-3176: Schedulable class to delete et4ae5__IndividualEmailResult__c. Use current DeleteRecordsBatch.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      -
* date        -
* description -
* --------------------------------------------------------------------------------------
*/
@isTest
public class DeleteIndividualEmailSchedulerTest{
    @TestSetup
    public static void testSetup(){
        et4ae5__Automated_Send__c sender = new et4ae5__Automated_Send__c();
        insert sender;

        et4ae5__IndividualEmailResult__c email = new et4ae5__IndividualEmailResult__c(
                et4ae5__TriggeredSendDefinition__c = sender.Id,
                et4ae5__NumberOfUniqueClicks__c = 0
        );
        insert email;
        System.debug('@@@ inserted email: ' + email);
        Datetime oldDate = Datetime.now().addDays(-200);
        Test.setCreatedDate(email.Id, oldDate);
    }

    @IsTest
    public static void testDeleteIndividualEmilScheduler(){
        List<et4ae5__IndividualEmailResult__c> ieList = [SELECT Id, et4ae5__Clicked__c, et4ae5__Opened__c, CreatedDate FROM et4ae5__IndividualEmailResult__c];
        System.debug('@@@ before running scheduler - ieList: ' + ieList);
        String CRON_EXP = '0 0 0 3 9 ? 2100';
        Test.startTest();
            System.schedule('DeleteIndividualEmilSchedulerTest',CRON_EXP, new DeleteIndividualEmailScheduler());
            Database.executeBatch(new DeleteRecordsBatch('et4ae5__IndividualEmailResult__c'), 200);
        Test.stopTest();
        ieList = [SELECT Id FROM et4ae5__IndividualEmailResult__c];
        System.assertEquals(0, ieList.size(), 'not all emails were deleted!');
    }
}