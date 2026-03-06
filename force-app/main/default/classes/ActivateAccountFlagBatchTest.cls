/**
 * Created by Alon.Shalev on 7/26/2022.
 */
@IsTest
public with sharing class ActivateAccountFlagBatchTest {

    @testSetup
    public static void setup(){
        Territory__c territory = new Territory__c();
//        territory.Sub_Division__c = 'test SubDivision';
        territory.Re_evaluate__c = true;
        territory.Strategic_Pod__c = 'NAL-US-FinServ';
        insert territory;

        Account acc = new Account(Name='test', ARR__c = 5);
        acc.Territory__c = territory.Id;
        insert acc;

    }

    @istest
    public static void testBatch(){
        Test.startTest();
        Database.executeBatch(new ActivateAccountFlagBatch(),1);
        Test.stopTest();

        // assert
        Territory__c afterBatchTerritory = [SELECT Re_evaluate__c FROM Territory__c LIMIT 1];
        Account afterBatchAccount = [SELECT Re_Evaluate_Territory__c FROM Account LIMIT 1];
        System.assertEquals(afterBatchAccount.Re_Evaluate_Territory__c,true);
        System.assertEquals(afterBatchTerritory.Re_evaluate__c,false);


    }



}