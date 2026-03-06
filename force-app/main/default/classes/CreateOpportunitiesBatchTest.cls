/**
* @author Itzik Winograd
* @date 10/10/2021
* @description CreateOpportunitiesBatch Test class
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
@isTest
public class CreateOpportunitiesBatchTest {
    private static FieldMappingNewUtils fmnu = new FieldMappingNewUtils('CreateOpps_Renewal');
    //Test setup. Create account, Zuora__Subscription__c, Zuora__CustomerAccount__c and update the BiData record.
    @testSetup
    public static void createRenewalBatchTestSetup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();

        Test.setMock(HttpCalloutMock.class, new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator());
        Account acc = AccountUtils.getAccounts(1)[0];
        acc.Primary_Solution__c = 'Marketing';
        acc.Secondary_Solution__c = 'Unable to identify';
        acc.Status__c = 'ACTIVE';
        acc.ownerId = getValidUsers()[0].Id;
        insert acc;
        Bi_Data__c bidata = [SELECT Id, ARR__C FROM Bi_Data__c WHERE Related_Record_ID__c = :acc.Id];
        bidata.ARR__c = 50;
        
        update biData;
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(acc);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(acc, billAcc);
        insert sub;

        Product2 p = new Product2(Family = 'Pricing', IsActive = true, Name = 'Test Pricing');
        insert p;
        PricebookEntry entry = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 123, IsActive = true);
        insert entry;

        //Run Renewal Batch
        Test.startTest();
        Id batchInstanceId = Database.executeBatch(new CreateOpportunitiesBatch('CreateOpps_Renewal'), 5); 
        Test.stopTest();
    }
	/** 
    * @author Itzik Winograd
    * @date 10/10/2021
    * @description: 1. Since the batch ran on the testSetup, 
    * 				   Assert all the fields on the account matches the fields on the Renewal Opportunity
    * 				2. Update the currency on the Zuora__CustomerAccount__c and insert relevant custom settings
    * @Expected:  2. Assert all the fields on the account matches the fields on the Upsell Opportunity
    */ 
    @isTest
    public static void createOppsBatchTestRenewals(){
        //Make assertions of the renewal opportunity
        Account acc = (Account)Database.query(fmnu.getSourceQuery('Account', ''))[0];
        Opportunity oppRenewal = (Opportunity)Database.query(fmnu.getDestinationQuery('Opportunity', ''))[0];
        for(String dest : fmnu.destinationVsMapping.keySet()){
            if(fmnu.destinationVsMapping.get(dest).fixedValue == null){
                System.assertEquals(oppRenewal.get(dest),acc.get(fmnu.destinationVsMapping.get(dest).source), 'Mismatch in Opportunity field ' + dest);
            }
        }
        //Update currency
        Zuora__CustomerAccount__c zca = [SELECT Id, Zuora__Currency__c FROM Zuora__CustomerAccount__c LIMIT 1];
        zca.Zuora__Currency__c = 'EUR';
        update zca;
        Netsuite_Daily_Exchange_Rate__c setting = new Netsuite_Daily_Exchange_Rate__c(
        	Name = 'EUR',
            Currency_DDL__c = 'EUR',
            USD_Exchange_Rate__c = 1.2
        );
        insert setting;
        //Run Upsell Batch
        Test.startTest();
        Id batchInstanceId = Database.executeBatch(new CreateOpportunitiesBatch('CreateOpps_Upsell'), 5); 
        Test.stopTest();
        Opportunity oppUpsell = (Opportunity)Database.query(fmnu.getDestinationQuery('Opportunity', '')+ ' WHERE Type = \'Upsell\'')[0];
        for(String dest : fmnu.destinationVsMapping.keySet()){
            if(fmnu.destinationVsMapping.get(dest).fixedValue == null){
                System.assertEquals(oppUpsell.get(dest),acc.get(fmnu.destinationVsMapping.get(dest).source), 'Mismatch in Opportunity field ' + dest);
            }
        }

    }
    
    private static List<Account> getValidAccounts(){
        List<Account> accountsList = [
            SELECT Id, Name, OwnerId, Primary_Solution__c, Secondary_Solution__c,
                ( SELECT Id, Zuora__NextRenewalDate__c, Zuora__MRR__c, Zuora__CustomerAccount__r.Zuora__Currency__c
                    FROM Zuora__Subscriptions__r
                ORDER BY CreatedDate DESC
                LIMIT 1)
             FROM Account
            WHERE (Status__c = 'ACTIVE' OR Status__c = 'Suspended')
              AND (Owner.userRole.Name LIKE '%Reseller%' OR Owner.userRole.Name LIKE '%CSM%' OR Owner.userRole.Name LIKE '%GM%')
              AND (NOT Owner_Division__c LIKE '%Business Operations%')
              AND (NOT Owner_Division__c LIKE '%Marketing%')
              AND (NOT Owner_Division__c LIKE '%MIR%')
              AND fr_ARR__c > 0
              AND fr_Next_Renewal_Date__c != 2100-01-01
              AND ID NOT IN(
                SELECT AccountId
                  FROM Opportunity
                 WHERE Type = 'Renewal'
                   AND CloseDate > LAST_MONTH)
              AND ID NOT IN(
                SELECT zqu__Account__c
                  FROM zqu__Quote__c
                 WHERE zqu__Status__c = 'Pending Renewal Date')
        ];
        System.debug('@@@ found accountsList: ' + accountsList);
        return accountsList;
    }
    
     private static List<User> getValidUsers(){
		return [ SELECT Id
                   FROM User
                  WHERE isActive = true
                    AND (userRole.Name LIKE '%Reseller%' OR userRole.Name LIKE '%CSM%' OR userRole.Name LIKE '%GM%')
                    AND (NOT Division LIKE '%Business Operations%')
                    AND (NOT Division LIKE '%Marketing%')
                    AND (NOT Division LIKE '%MIR%')];
     }
}