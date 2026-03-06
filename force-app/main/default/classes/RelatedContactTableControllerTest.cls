@isTest
private class RelatedContactTableControllerTest {
    @testSetup 
    static void setup() {
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();     
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
    }

    @isTest 
    static void testObtainContactList() {
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;                
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
        //Test.startTest();
        List<Contact> res = RelatedContactTableController.obtainContactList(quote.Id);
        //Test.stopTest();
        System.assertNotEquals(null, res);
        System.assert(!res.isEmpty());
        System.assertEquals(c.Id, res.get(0).Id);
    }

    @isTest
    static void testObtainContactListNoQuote() {
        List<Contact> res = RelatedContactTableController.obtainContactList(null);
        System.assertEquals(null, res);
    }
}