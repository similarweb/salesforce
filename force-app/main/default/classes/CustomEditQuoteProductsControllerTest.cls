@isTest
public class CustomEditQuoteProductsControllerTest {
    
    @testSetup
    static void setup(){
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
    }

    @isTest
    static void customEditQuoteProductsControllerTest(){
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c,QuoteRegion__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.CustomEditQuoteProductsPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',quote.id);
        ApexPages.currentPage().getParameters().put('quoteType','Subscription');
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        CustomEditQuoteProductsController controller = new CustomEditQuoteProductsController(sc);
        Test.stopTest();
    }

    @isTest
    static void validateQuoteTest(){
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c,QuoteRegion__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        CustomEditQuoteProductsController.validateQuote(quote.Id);
        Test.stopTest();
    }

    // @isTest
    // static void removeOriginalProductsTest(){
    //     zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c FROM zqu__Quote__c LIMIT 1];
    //     Test.startTest();
    //     PageReference pageRef = Page.CustomEditQuoteProductsPage;
    //     Test.setCurrentPage(pageRef);
    //     ApexPages.currentPage().getParameters().put('id',quote.id);
    //     ApexPages.currentPage().getParameters().put('quoteType','Amendment');
    //     ApexPages.currentPage().getParameters().put('isMigration','true');
    //     ApexPages.currentPage().getParameters().put('editQuoteProductsMode','GuidedSelling');
    //     ApexPages.StandardController sc = new ApexPages.standardController(quote);
    //     CustomEditQuoteProductsController controller = new CustomEditQuoteProductsController(sc);
    //     controller.removeOriginalProducts();
    //     Test.stopTest();
    // }

    @isTest
    static void navigateBackTest(){
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c,QuoteRegion__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.CustomEditQuoteProductsPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',quote.id);
        ApexPages.currentPage().getParameters().put('quoteType','Subscription');
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        CustomEditQuoteProductsController controller = new CustomEditQuoteProductsController(sc);
        controller.navigateBack();
        Test.stopTest();
    }

    @isTest
    static void redirectToRecordPage(){
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c,QuoteRegion__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.CustomEditQuoteProductsPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',quote.id);
        ApexPages.currentPage().getParameters().put('quoteType','Subscription');
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        CustomEditQuoteProductsController controller = new CustomEditQuoteProductsController(sc);
        controller.redirectToRecordPage();
        Test.stopTest();
    }

    // @isTest
    // static void fixProductDiscountPercentageTest(){
    //     zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c,QuoteRegion__c FROM zqu__Quote__c LIMIT 1];
    //     Test.startTest();
    //     PageReference pageRef = Page.CustomEditQuoteProductsPage;
    //     Test.setCurrentPage(pageRef);
    //     ApexPages.currentPage().getParameters().put('id',quote.id);
    //     ApexPages.currentPage().getParameters().put('quoteType','Subscription');
    //     ApexPages.StandardController sc = new ApexPages.standardController(quote);
    //     CustomEditQuoteProductsController controller = new CustomEditQuoteProductsController(sc);
    //     controller.fixProductDiscountPercentage();
    //     Test.stopTest();
    // }

    @isTest
    static void parseRawResultMessageTest(){
        Test.startTest();
        CustomEditQuoteProductsController.parseRawResultMessage(', message=testError,');
        Test.stopTest();
    }
    
    @isTest
    static void checkIfOriginalProductsHaveChangedTest(){
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c,QuoteRegion__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.CustomEditQuoteProductsPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',quote.id);
        ApexPages.currentPage().getParameters().put('quoteType','Subscription');
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        CustomEditQuoteProductsController controller = new CustomEditQuoteProductsController(sc);
        controller.checkIfOriginalProductsHaveChanged();
        Test.stopTest();
    }
}