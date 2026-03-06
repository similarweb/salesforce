@isTest
public class AccountRedirectControllerTest {

    @isTest
    static void controllerTest(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        List<String> countries =  TestDataFactory.getCountries(); 
        Account obj = TestDataFactory.createAccount();
        obj.billingcountry = countries[0];
        insert obj;
        PageReference pageRef = Page.AccountRedirect;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(obj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        Test.startTest();
        AccountRedirectController accountRedirectController = new AccountRedirectController(sc);
        PageReference responsePageRef = accountRedirectController.onLoad();
        Test.stopTest();
    }
}