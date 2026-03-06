@isTest
global class QuoteAutoPopulateValuesTest {

    @testSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
    }
    
    @isTest
    global static void testController(){
        // Account acc = QuoteAutoPopulateValuesTest.makeAccount();
        // insert acc;
        // Contact cont = QuoteAutoPopulateValuesTest.makeContact(acc, 'United States');
        // insert cont;
        // Opportunity opp = QuoteAutoPopulateValuesTest.makeOpportunity(acc);
        // insert opp;
        // zqu__Quote__c zquote = QuoteAutoPopulateValuesTest.makeZQuote(opp, cont);
        // zquote.zqu__SoldToContact__c = cont.Id;
        QuoteAutoPopulateValues testEntity = new QuoteAutoPopulateValues();        
        testEntity.populateDefaultFieldValue(null, new zqu.PropertyComponentController.ParentController());   
        // PageReference createQuote = Page.CreateQuote2;        
        // createQuote.getParameters().put('stepNumber', '2');        
        // Test.setCurrentPage(createQuote); 
        // Test.startTest();
        // testEntity.populateDefaultFieldValue(zquote, new zqu.PropertyComponentController.ParentController());   
        // update cont;
        // testEntity.populateDefaultFieldValue(zquote, new zqu.PropertyComponentController.ParentController());   
        // Test.stopTest();
    }
    
    // @isTest
    // global static void testControllerElse(){
    //     Account acc = QuoteAutoPopulateValuesTest.makeAccount();
    //     insert acc;
    //     Contact cont = QuoteAutoPopulateValuesTest.makeContact(acc, 'Canada');
    //     insert cont;
    //     Opportunity opp = QuoteAutoPopulateValuesTest.makeOpportunity(acc);
    //     insert opp;
    //     zqu__Quote__c zquote = TestObjectCreator.CreateZQuote(opp, cont);
    //     zquote.zqu__SoldToContact__c = cont.Id;
    //     QuoteAutoPopulateValues testEntity = new QuoteAutoPopulateValues();        
    //     PageReference createQuote = Page.CreateQuote2;        
    //     createQuote.getParameters().put('stepNumber', '2');        
    //     Test.setCurrentPage(createQuote); 
    //     Test.startTest();
    //     testEntity.populateDefaultFieldValue(zquote, new zqu.PropertyComponentController.ParentController());   
    //     update cont;
    //     testEntity.populateDefaultFieldValue(zquote, new zqu.PropertyComponentController.ParentController());   
    //     Test.stopTest();
    // }
    
    // private static Account makeAccount(){
    //     Account testAcc = new Account();        
    //     testAcc.Name = 'Test Account';        
    //     testAcc.BillingState = 'California';        
    //     testAcc.BillingStreet = 'Test';        
    //     testAcc.BillingCity = 'San Mateo';        
    //     testAcc.BillingCountry = 'United States'; 
    //     return testAcc;
    // }
    
    // private static Contact makeContact(Account acc,  String country){
    //     Contact c = new Contact();        
    //     c.MailingCountry = country;     
    //     c.email = 'test@gmail.com';   
    //     c.AccountId = acc.Id;        
    //     c.LastName = 'Manojna';
    //     return c;
    // }
    
    // private static Opportunity makeOpportunity(Account testAcc) {
    //     Opportunity testOpp = new Opportunity();
    //     testOpp.Name = 'TEST';
    //     testOpp.StageName = 'New';
    //     testOpp.CloseDate = date.today();
    //     testOpp.AccountId = testAcc.Id;
    //     testOpp.Plan_Details__c = 'test';
    //     testOpp.Product_Sold__c = 'test';
    //     return testOpp;
    // }
    
    // private static zqu__Quote__c makeZQuote (Opportunity o){
    //     zqu__Quote__c q = new zqu__Quote__c();
    //     q.zqu__ZuoraAccountID__c = 'new';
    //     q.zqu__Account__c = o.accountid;
    //     return q;
    // }
    
    // private static zqu__Quote__c makeZQuote (Opportunity o,Contact c){
    //     zqu__Quote__c q = makeZQuote(o);
    //     q.zqu__SoldToContact__c = c.Id;
    //     q.zqu__ElectronicPaymentMethodId__c = '1234567980';
    //     q.zqu__PaymentMethod__c = randomPLEValue('zqu__Quote__c','zqu__PaymentMethod__c');        
    //     return q;
    // }
    
    // private static String randomPLEValue(DescribeFieldResult dfr) {
    //     List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
    //     return ple[randomInt(ple.size())].getValue();
    // }
    // private static String randomPLEValue(String table,String fieldName) {
    //     return randomPLEValue(getFieldResult(table,fieldName));
    // }
    // private static Integer randomInt(Integer max){
    //     return Integer.valueof(max*Math.random());
    // }
    // private static DescribeFieldResult getFieldResult(String objectName,String fieldName) {
    //     return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
    // }
}