/**
 * @author          Itzik Winograd
 * @date            24/07/2022
 * @description     MIS-2458. Test for the BillingExpertBatch class
 */
@IsTest
public with sharing class BillingExpertBatchTest {
    private static FINAL Integer BATCH_SIZE = Integer.valueOf(
            GeneralUtil.getGeneralConfig('BillingExpertBatchSize').Number_Value__c
    );
    private static FINAL Integer N = 2;

    /**
     * @author          Itzik Winograd
     * @date            25/07/2022
     * @description     Create accounts and Billing_expert_Mapping__c record.
     *                  The account's billing_expert__c should be null.
     */
    
    @TestSetup
    public static void billingExpertTestSetup(){
		
        List<Account> accountsList = AccountUtils.getAccounts(N);
        insert accountsList;
        for(Integer i=0; i<N; i++){
            accountsList[i].Billing_Expert__c = null;
        }
        update accountsList;
        
        accountsList = [SELECT Id, OwnerId, Owner.Division FROM Account];
        
        List<Billing_expert_Mapping__c> billingExpertList = new List<Billing_expert_Mapping__c>();
        for(Integer i=0; i<N; i++){
            billingExpertList.add(new Billing_expert_Mapping__c(
                    Billing_Expert__c = accountsList[0].OwnerId,
                    Change_in_Mapping__c = true,
                    Owner_Division__c = accountsList[0].Owner.Division
            ));
        }
        insert billingExpertList;
    }

    /**
     * @author          Itzik Winograd
     * @date            25/07/2022
     * @description     Run the batch. verify that the
     * @Expected        After the batch run the BillingExpertRecord will be changed
     */
    @IsTest
    public static void billingExpertBatchChangedMappingTest(){
        List<Account> accountsList = [SELECT Id, Billing_expert__c, Owner_Division__c FROM Account];
        System.debug('@@@ Found accounts before update: ' + accountsList);
        
        Map<String, Billing_expert_Mapping__c> ownerDivisionToBillingExpert = getOwnerDivisonToBillingExpertMap();
        System.debug('@@@ Found ownerDivisionToBillingExpert: ' + ownerDivisionToBillingExpert);

        Test.setMock(HttpCalloutMock.class, new YayPaySetARSpecialistBatchTest.YayPayARSpecialistMock());

        Test.startTest();
        Database.executeBatch(new BillingExpertBatch(), BATCH_SIZE);
        Test.stopTest();
        
        ownerDivisionToBillingExpert = getOwnerDivisonToBillingExpertMap();
        accountsList = [SELECT Id, Billing_expert__c, Owner_Division__c FROM Account];
        System.debug('@@@ Found accounts after update: ' + accountsList);
        for(Integer i=0;i<N; i++){
            System.assertEquals(accountsList[i].Billing_expert__c , ownerDivisionToBillingExpert.get(accountsList[i].Owner_Division__c).Billing_expert__c, 'Error: billing expert mismatch!');
        }
        
        
    }
    
    //return a map of OwnerDivison to Billing_expert_Mapping__c record
    public static Map<String, Billing_expert_Mapping__c> getOwnerDivisonToBillingExpertMap(){
        Map<String, Billing_expert_Mapping__c> ownerDivisionToBillingExpert = new Map<String, Billing_expert_Mapping__c>();
        for (Billing_expert_Mapping__c bem : [SELECT Id, Billing_Expert__c, Owner_Division__c, Change_in_Mapping__c FROM Billing_expert_Mapping__c]){
            ownerDivisionToBillingExpert.put(bem.Owner_Division__c, bem);
        }
        return ownerDivisionToBillingExpert;
    } 
}