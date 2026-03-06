/*************************************************************************************************************
 * @name			ZuoraSObjectUpdatePluginTest
 * @author			Synebo Developer
 * @created			07 / 07 / 2022
 * @description		MQ-1582. Test class for ZuoraSObjectUpdatePlugin
 *
**************************************************************************************************************/
@isTest
public with sharing class ZuoraSObjectUpdatePluginTest {
    @TestSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();     
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
        List<String> countries =  TestObjectCreator.getCountries();
        Account a = TestObjectCreator.CreateAccount();
        a.billingcountry = countries[countries.size()-1];
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        c.MailingCountry = countries[countries.size()-1];
        insert c;
        list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        Opportunity o = TestObjectCreator.CreateOpportunity (a);
        insert o;                
    }

        
    @IsTest
    static void containsExceptionProductTest(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        insert quote; 

        Test.startTest();

        Map<String,Object> attributes = new Map<String,Object>();
        attributes.put('Exception_Product__c', 'true');
        attributes.put('Name', 'test');
        List<String> logs = new List<String>();
        ZuoraSObjectUpdatePlugin zuoraSObjectUpdatePlugin = new ZuoraSObjectUpdatePlugin();
        zuoraSObjectUpdatePlugin.perform(null,attributes,logs);
        Test.stopTest();
        zqu__Quote__c updatedQuote = [SELECT Id,Exception_Product__c FROM zqu__Quote__c WHERE Id =: quote.Id];
        System.assert(updatedQuote.Exception_Product__c);
    }
}