/**
 * Created by Alon.Shalev on 11/7/2022.
 */
@istest
public with sharing class ActivateUnMappedAccountOfTerritoryTest {

    /**
     * @description test setup, create a Territory and an Account with the same territory
     * */
    @testSetup
    public static void setup(){
        System.runAs(getUser()) {
            String INDUSTRY = 'Education';
            String SUB_DIVISION = 'test SubDivision';
            List<String> industrySubTypes = new List<String>{
                    'Universities'};
            Territory__c territoryIndustry = new Territory__c(
                    Re_evaluate__c = true,
                    SW_Industry__c = INDUSTRY,
                    Sub_Division__c = SUB_DIVISION,
                    Industry_Subtype__c = String.join(industrySubTypes, ';')
            );
            insert territoryIndustry;
            Account accIndustry = AccountUtils.getAccounts(1)[0];
            accIndustry.ARR__c = 5;
            accIndustry.SW_Industry__c = INDUSTRY;
            insert accIndustry;
        }
    }

    /**
     * @description run the batch on Strategic pod match. Delete existing territories to ensure running on the desired territories
     * @expected 'before' account will remain Re_Evaluate_Territory__c false,
     *           'after' account will change to Re_Evaluate_Territory__c true,
     * */
    @istest
    public static void testBatchStrategicPod(){
        System.runAs(getUser()) {
            String STRATEGIC_POD = 'NAL-US-FinServ';

            Territory__c territoryPod = [SELECT Id FROM Territory__c];
            territoryPod.Strategic_Pod__c = STRATEGIC_POD;
            territoryPod.SW_Industry__c = '';
            territoryPod.Sub_Division__c = '';
            territoryPod.Industry_Subtype__c = null;
            update territoryPod;
//            System.debug('@@@ testBatchStrategicPod: ' + [SELECT ID, Strategic_Pod__c, Sub_Division__c, SW_Industry__c FROM Territory__c]);

            Account accountPod = [SELECT Id FROM Account];
            accountPod.Strategic_Pod__c = STRATEGIC_POD;
            update accountPod;

            Test.startTest();
                accountPod.Re_Evaluate_Territory__c = false;
                update accountPod;
                Account beforeBatchAccount = [SELECT Id, Re_Evaluate_Territory__c, Strategic_Pod__c, owner.UserRole.Name FROM Account WHERE Id = :accountPod.Id LIMIT 1];
                System.debug('@@@ ActivateUnMappedAccountOfTerritoryTest - beforeBatchAccount: ' + beforeBatchAccount);
                String CRON_EXP = '0 0 0 3 9 ? 2100';
                System.schedule('ActivateUnMappedAccountOfTerritoryTest', CRON_EXP, new ActivateUnMappedAccountOfTerritory());
                Database.executeBatch(new ActivateUnMappedAccountOfTerritory(), 1);
            Test.stopTest();

            // assert
            Account afterBatchAccount = [SELECT Id, Re_Evaluate_Territory__c FROM Account WHERE Strategic_Pod__c != null LIMIT 1];
//            system.assertEquals(false, beforeBatchAccount.Re_Evaluate_Territory__c, 'before account should remain false');
//            system.assertEquals(true, afterBatchAccount.Re_Evaluate_Territory__c, 'after account should have true');
        }
    }

    /**
     * @description run the batch.
     * @expected 'before' account will remain Re_Evaluate_Territory__c false,
     *           'after' account will change to Re_Evaluate_Territory__c true,
     * */
    @istest
    public static void testBatchIndustry(){
//        System.debug('@@@ testBatchIndustry: ' + [SELECT ID, Strategic_Pod__c, Sub_Division__c, SW_Industry__c FROM Territory__c]);
        Account beforeBatchAccount = [SELECT Id,Re_Evaluate_Territory__c,BI_Data__c FROM Account WHERE SW_Industry__c !=null LIMIT 1];
        BI_Data__c bi = [SELECT Sub_Division_Account__c FROM BI_Data__c WHERE Id = :beforeBatchAccount.BI_Data__c LIMIT 1];
        bi.Sub_Division_Account__c = 'test SubDivision';
        Test.startTest();
        update bi;
        Database.executeBatch(new ActivateUnMappedAccountOfTerritory(),1);
        Test.stopTest();
        // assert
        Account afterBatchAccount = [SELECT Id, Re_Evaluate_Territory__c FROM Account WHERE SW_Industry__c !=null LIMIT 1];
        system.assertEquals(false, beforeBatchAccount.Re_Evaluate_Territory__c, 'before account should remain false');
        system.assertEquals(true, afterBatchAccount.Re_Evaluate_Territory__c, 'after account should have true');
    }

    private static User getUser(){
        User u = [SELECT Id, UserRole.Name
        FROM User
        WHERE IsActive = true
        AND Profile.Name LIKE '%admin%'
        AND (NOT UserRole.Name LIKE '%Reseller%')
        AND (NOT UserRole.Name LIKE '%Internal%')
        AND (NOT UserRole.Name LIKE '%Product Marketing & Strategy%')
        AND (NOT UserRole.Name LIKE '%Channel%')
        AND (NOT UserRole.Name LIKE '%OEM%')
        AND (NOT UserRole.Name LIKE '%Panel Acquisition%')
        AND (NOT UserRole.Name LIKE '%Self Services%')
        LIMIT 1][0];
        System.debug('@@@ Running test as user: ' + u.UserRole);
        return u;
    }

}