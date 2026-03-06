/**
* @author Itzik Winograd
* @date 21/02/2020
* @description: Test class for the ContactGetValuesFromAccount class
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/
@isTest
public class ContactGetValuesFromAccountTest {
    @testSetup
    /**
    * @author Itzik Winograd
    * @date 21/02/2020
    * @description: Test setup. Create accounts,
    * 				and set values to the relevant fields in the custom metadata. 
    */
    public static void contactGetValuesFromAccountSetup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Test.setMock(HttpCalloutMock.class, new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator());
        
        List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList('New Contact - Values from Account');
        FieldMappingUtil.FieldMappingData fmd =  FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(fieldsMappingList);        
        //create account
        Account acc = AccountUtils.getAccounts(1)[0];
        Integer num = 5;
        for (String fieldName : fmd.sourceFieldSet){
            Schema.DisplayType fielddataType = Schema.getGlobalDescribe() 
                        .get('Account')
                        .getDescribe()
                        .fields
                        .getMap()
                        .get(fieldName)
                        .getDescribe()
                        .getType();
            if(fielddataType == Schema.DisplayType.TextArea) {
                acc.put(fieldName,'SomeValue'+num);
            }
            else if(fielddataType == Schema.DisplayType.String) {
                acc.put(fieldName,'SomeValue'+num);
            }   
            else if(fielddataType == Schema.DisplayType.Integer) {
                acc.put(fieldName,num);
            }    
            else if(fielddataType == Schema.DisplayType.Double) {
                acc.put(fieldName,num);
            } 
            else if(fielddataType == Schema.DisplayType.DateTime) {
                acc.put(fieldName,Datetime.now());
            }
        }
        Insert acc;
    }
    
    /**
    * @author Itzik Winograd
    * @date 21/02/2020
    * @description: Insert new contacts
    * @Expected: make sure the new contacts holds the values from account they were created under.
    */
    @isTest
    public static void contactGetValuesFromAccountCheckContacts(){
        Account acc = [SELECT Id FROM Account LIMIT 1][0];
        //create Contact
        List<Contact> contact_lst = ContactUtils.getContactsForAccount(5,acc);
        Test.startTest();
        insert contact_lst;
        Test.stopTest();
        
        List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList('New Contact - Values from Account');
        FieldMappingUtil.FieldMappingData fmd =  FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(fieldsMappingList);        
        
        String query = '';
        String source = '';
        String destination= '';
		Map<String, String> destinationVsSource = new Map<String,String>();
        for(Fields_Mapping__mdt fmp : fieldsMappingList){
            destination = fmp.Destination_Field__c;
            source = fmp.Source_Field__c;
            destinationVsSource.put(destination, source);
            query += ', ' + destination + ', Account.' + source + ' ';
        }
        String fullQuery = 'SELECT Id ' + query + ' FROM Contact';
        System.debug('### test fullQuery: ' + fullQuery);
        List<Contact> contactList = Database.query(fullQuery);
        for(Contact con : contactList){
            for(String  dest : destinationVsSource.keySet()){
                Object accValue = con.getSObject('Account').get(destinationVsSource.get(dest));
                Object conValue = con.get(dest);
                System.debug('### test accValue: ' + accValue +', conValue: ' + conValue);
                System.assertEquals(accValue, conValue, 
                                    'Error: ' + conValue + ' do not match!');
            }
        }
        
    }
}