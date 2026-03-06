@isTest
global class GuidedSellingFlowPluginImplTest {
    
    @testSetup
    global static void testSetup(){        
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        List<String> countries =  TestDataFactory.getCountries();
        Account account = TestDataFactory.createAccount();
        account.billingcountry = countries[countries.size()-1];
        insert account;
        Contact contact = TestDataFactory.createContact(account, 'test@testing.com');
        contact.MailingCountry = countries[countries.size()-1];
        insert contact;
        List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
        insert lcsc;
        Opportunity opp = TestDataFactory.createOpportunity (account);
        insert opp;                
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact); 
        insert quote;        
        zqu__GuidedSellingFlow__c guidedSellingFlow = TestDataFactory.createGuidedSellingFlow();
        insert guidedSellingFlow;
        zqu__GuidedSellingStep__c guidedSellingStep = TestDataFactory.createGuidedSellingStep();
        insert guidedSellingStep;
        zqu__StepToFlowMap__c stepToFlowMap = TestDataFactory.createGuidedSellingFlowToStep(guidedSellingFlow,guidedSellingStep);
        insert stepToFlowMap;
        zqu__List_Filter__c listFilter = TestDataFactory.createListFilter();
        insert listFilter;
        zqu__List_Filter_Item__c listFilterItem = TestDataFactory.createListFilterItem(listFilter);
        insert listFilterItem;
        TestDataFactory.prepareProductCatalog();
    }
    
    @isTest
    global static void testController(){     
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        GuidedSellingFlowPluginImpl cntrl = new GuidedSellingFlowPluginImpl();
        cntrl.getFlows(quote.Id);
    }
}