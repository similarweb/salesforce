@istest public class CLCTaskGenerationBatchTest {

    @testSetup static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
    }
    
    @istest static void test1(){
        List<Account> accounts = new List<Account>{new Account(Name='Account 1', Business_Unit__c='Inside Sales', CLC_Start_Date__c=Date.today().addDays(-5), Status__c='Active'),  
            										new Account(Name='Account 2', Business_Unit__c='Enterprise', CLC_Start_Date__c=Date.today(), Status__c='Active')};
        insert accounts;
        List<CLC_Stage__c> stages = new List<CLC_Stage__c>{new CLC_Stage__c(Name='Activation', Business_Unit__c='Inside Sales'), 
            												new CLC_Stage__c(Name='Another Activation', Business_Unit__c='Enterprise')};
        insert stages;
            
        List<Task_Template__c> taskTemplateList = new List<Task_Template__c>{
            				new Task_Template__c(CLC_Stage__c=stages[0].Id, Due_date__c=10, Generation_date__c=5, Priority__c='Normal', Status__c='Not Started', Subject__c='Test Task1', Task_Record_type__c='Onboarding Task', Type__c='Call'),
                            new Task_Template__c(CLC_Stage__c=stages[1].Id, Due_date__c=2, Generation_date__c=0, Priority__c='Normal', Status__c='Not Started', Subject__c='Test Task2', Task_Record_type__c='Onboarding Task', Type__c='Call')
        };
        insert  taskTemplateList;
        
        Test.startTest();
        Database.executeBatch(new CLCTaskGenerationBatch());
        Test.stopTest();
        
        List<Task> newTasks = [SELECT Id, Subject, ActivityDate, WhatId FROM Task ORDER BY ActivityDate];
        System.debug('newTasks ' + newTasks);
        System.assertEquals(2, newTasks.size());
        System.assertEquals(accounts[1].Id, newTasks[0].WhatId);
        System.assertEquals('Test Task2', newTasks[0].Subject);
    }
    
    @istest static void testScheduler(){
        Test.startTest();
        System.schedule('Test CLC Job' , '0 0 10 * * ?' , new CLCTaskGenerationScheduler());
        Test.stopTest(); 
    }
}