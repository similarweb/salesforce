@isTest
public with sharing class MetadataServiceFacadeTest {

    @TestSetup
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
    }
    
    @isTest
    static void test() {
        MetadataServiceFacade service = new MetadataServiceFacade('test','test','test');
        service = new MetadataServiceFacade(JwtCredentials.getInstance());
        service = new MetadataServiceFacade();
        MetadataService.CustomField packageCustomField = service.obtainCustomField('zqu__Quote__c.Package__c');
        Map<String,List<String>> packagePicklistValueDependentMap = service.obtainPicklistValueDependentMap(packageCustomField);
    }
}