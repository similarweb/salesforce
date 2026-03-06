@isTest
public with sharing class GetQuoteTypeTest {
    
    @TestSetup
    static void setup(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS();
    }

    @isTest
    static void test(){
        GetQuoteType.getQType('test');
    }
}