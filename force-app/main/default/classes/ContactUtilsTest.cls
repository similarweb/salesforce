/**
* @author Itzik Winograd
* @date 16/02/2021
* @description TestClass for ContactUtils
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/
@isTest
public with sharing class ContactUtilsTest {

    /**
    * @author Itzik Winograd
    * @date 16/02/2021
    * @description Create a List of Contacts using the utils class
    * @param None.  
    * @return None.
    */
    @testSetup
    public static void  contactUtilsInsertTestData(){
        //TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Test.setMock(HttpCalloutMock.class, new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator());

        Integer N = 2;
        List<Contact> lst_contact = ContactUtils.getContacts(N);
        insert lst_contact;
        
        Account acc = AccountUtils.getAccounts(1)[0];
        List<Contact> lst_contactWithAccount = ContactUtils.getContactsForAccount(N, acc);
        insert lst_contactWithAccount;
        
        System.debug('foundContacts.size(): ' +[SELECT Id FROM Contact].size());
        
        //test for 0 contacts
		lst_contact = ContactUtils.getContacts(0);
        lst_contact = ContactUtils.getContactsForAccount(0,acc);
    }

    /**
    * @author Itzik Winograd
    * @date 16/02/2021
    * @description Create a List of Contacts using the utils class
    * @Expected - the same amount of contacts were inserted to the system.
    * @param None.  
    * @return None.
    */
    @isTest
    public static void  contactUtilsCheck(){
        Integer N_2 = 4;
        List<Contact> foundContacts = new List<Contact>([SELECT Id FROM Contact]);
        System.debug('foundContacts.size(): ' + foundContacts.size());
        System.assertEquals(N_2, foundContacts.size(),'Wrong number of contacts found!');
    }
}