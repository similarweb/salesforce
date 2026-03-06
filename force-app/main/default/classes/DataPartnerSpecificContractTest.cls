/**
 * Created by zohar.sinay on 02/03/2022.
 */

@IsTest
private class DataPartnerSpecificContractTest {

    @testSetup
    public static void setup(){
         String dataPartnerRecordTypeId = Utility.getRecordTypeIdForObject(New Account().getSObjectType(), 'Wolves');
        Account acc = new Account(Name='test', ARR__c = 5, RecordTypeId = dataPartnerRecordTypeId,Wolves_Status__c = 'Active');
        insert acc;
        Contract cont = new Contract(Name = 'Test', StartDate = date.today(), AccountId = acc.id,
                ContractTerm = 36, Status = 'Draft', OwnerExpirationNotice = '60', Payment_Method__c = 'Monthly', Payment_Cap__c = 12000);
        insert cont;
        cont.Status = 'Activated';
        update cont;
        Source__c source = new Source__c(Name = 'zohar test', Contract__c = cont.Id, Source_Number__c = 1441,Solution__c = 'Apps');
        insert source;
        Rate__c rate = new Rate__c(Name = 'zohar test', Request_Type__c = 1001, Rate__c = 0.1, Source__c = source.Id, Country_Tier__c = 'Tier 1',
                Data_Type__c = 'DAU', Effective_Date__c = Date.today() - 1, End_Date__c = Date.today() + 100);
        insert rate;
    }

    @IsTest
    static void testBehavior() {
        Test.startTest();
        Database.executeBatch(new DataPartnerManagementBatch(), 20);
        Test.stopTest();
        Source__c source = [SELECT Id,Contract__c FROM Source__c LIMIT 1];
        Source__c source1 = new Source__c(Name = 'zohar test2', Contract__c = source.Contract__c, Source_Number__c = 1442,Solution__c = 'Apps');
        insert source1;
        Rate__c rate = new Rate__c(Name = 'zohar test2', Request_Type__c = 1001, Rate__c = 0.1, Source__c = source1.Id, Country_Tier__c = 'Tier 1',
                Data_Type__c = 'DAU', Effective_Date__c = Date.today() - 1, End_Date__c = Date.today() + 100);
        insert rate;
        DataPartnersSpecificContractAController.createNewDataPartnersForContract(source.Contract__c);
    }
}