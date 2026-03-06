@isTest
public with sharing class GenericDomainTest {

    @TestSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createAccount();
    }
    
    @isTest
    static void test(){
        List<Account> accList = [SELECT Id FROM Account];
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.putAll(accList);
        GenericDomain.triggerHandler(true,false,true,false,false,false,accList,accMap,AccountDomain.class);
        GenericDomain.triggerHandler(true,false,false,true,false,false,accList,accMap,AccountDomain.class);
        GenericDomain.triggerHandler(true,false,false,false,true,false,accList,accMap,AccountDomain.class);
        GenericDomain.triggerHandler(true,false,false,false,false,true,accList,accMap,AccountDomain.class);
        
        GenericDomain.triggerHandler(false,true,true,false,false,false,accList,accMap,AccountDomain.class);
        GenericDomain.triggerHandler(false,true,false,true,false,false,accList,accMap,AccountDomain.class);
        GenericDomain.triggerHandler(false,true,false,false,true,false,accList,accMap,AccountDomain.class);
        GenericDomain.triggerHandler(false,true,false,false,false,true,accList,accMap,AccountDomain.class);
    }
}