/**
 * Created by Alon.Shalev on 11/13/2022.
 */
@IsTest
public with sharing class ChurnAccountsBatchTest {
    @testSetup
    public static void setup(){

        Territory__c territory = new Territory__c();
        territory.Sub_Division__c = 'test SubDivision';
        territory.SW_Industry__c = 'AdTech and AdNetwork';
        territory.Industry_Subtype__c = 'Other';
        territory.OwnerID = UserInfo.getUserId();
        insert territory;

        Account acc = new Account();
        acc.Name= 'test';
        acc.SW_Industry__c = 'AdTech and AdNetwork';
        acc.Industry_Subtype__c = 'Other';
        acc.Re_Evaluate_Territory__c = true;
        acc.Status__c = 'Expired';
//        acc.fr_Next_Renewal_Date__c = Date.today().addDays(-250);
        acc.Territory__c = territory.Id;
        acc.Last_Status_update_date__c = Datetime.now().addDays(-352);
        insert acc;

        Account acc2 = [SELECT BI_Data__c FROM Account WHERE Id =:acc.Id];
        BI_Data__c bi2 = [SELECT Sub_Division_Account__c FROM BI_Data__c WHERE Id = :acc2.BI_Data__c];
        bi2.Next_Renewal_Date__c = Date.today().addDays(-352);
        update bi2;


    }

    @istest
    public static void testBatch(){
        Account accAfterDataBase  = [SELECT OwnerId FROM Account];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduserForSimilarWeb@testorg.com');

        System.runAs(u) {
            // The following code runs as user 'u'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            AccountTeamMember accountTeamMember = new AccountTeamMember();
            accountTeamMember.AccountId = accAfterDataBase.Id;
            accountTeamMember.UserId = UserInfo.getUserId();
            accountTeamMember.TeamMemberRole = 'Sales Manager';
            accountTeamMember.Member_of_Territory__c = true;

            insert accountTeamMember;
        }

        AccountTeamMember teamMemberAfterDataBse = [SELECT UserId FROM AccountTeamMember];

        System.assertNotEquals(teamMemberAfterDataBse.UserId , accAfterDataBase.OwnerId);


        Test.startTest();
        Database.executeBatch(new ChurnAccountsBatch(),1);
        Test.stopTest();
        //assert
        Account accAfterBatch  = [SELECT OwnerId FROM Account];

//        System.assertEquals(teamMemberAfterDataBse.UserId , accAfterBatch.OwnerId);


    }


}