/**
* @author Itzik Winograd
* @date 24/12/2020
* @description Test EmailDomain__c Class
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------                     
*/
@isTest
public with sharing class EmailDomainUtilsTest {
    /**
    * @author Itzik Winograd
    * @date 29/12/2020
    * @description: Create a list of EmailDomain__c records and get the list of inserted domains. 
    * @desired: check that the number of email domain were created indeed, check that null is returned for 0 domains. 
    */
    @isTest
    public static void getEmailDomains(){
        Integer NUMBER_OF_DOMAINS = 5;
        List<EmailDomain__c> domains = EmailDomainUtils.getEmailDomains(NUMBER_OF_DOMAINS);
        insert domains;

        System.assertEquals(NUMBER_OF_DOMAINS,domains.size(), 'Error in testEmailDomains - ' + NUMBER_OF_DOMAINS);
        //Test for 0 accounts
       	System.assertEquals(EmailDomainUtils.getEmailDomains(0), null, 'Error in testEmailDomains - 0!');
    }
    
}