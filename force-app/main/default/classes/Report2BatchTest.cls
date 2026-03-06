@isTest
public class Report2BatchTest {
    
    @testSetup
    public static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Account a = TestObjectCreator.CreateAccount();
        insert a;
        Zuora__CustomerAccount__c zca = TestObjectCreator.CreateBillingAccount (a);
        zca.Zuora__BillToWorkEmail__c = 'test1@testing.com';
        zca.Zuora__SoldToWorkEmail__c = 'test2@testing.com';
        insert zca;
        Contact c1 = TestObjectCreator.CreateContact(a, 'test1@testing.com');
        insert c1;
        Contact c2 = TestObjectCreator.CreateContact(a, 'test1@testing.com');
        insert c2;
        Contact c3 = TestObjectCreator.CreateContact(a, 'test2@testing.com');
        insert c3;
        Contact c4 = TestObjectCreator.CreateContact(a, 'test2@testing.com');
        insert c4;
    }

    @isTest
    public static void testBillTo() {
        Test.startTest();
        Database.executeBatch(new Report2BatchBillTo());
        Test.stopTest();
    }
    
    @isTest
    public static void testSoldTo() {
        Test.startTest();
        Database.executeBatch(new Report2BatchSoldTo());
        Test.stopTest();
    }
}