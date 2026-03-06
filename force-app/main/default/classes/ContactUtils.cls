/**
* @author Itzik Winograd
* @date 16/02/2021
* @description General Contact functions that can help us throughout the code base
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/
 
public with sharing class ContactUtils {

    /**
    * @author Itzik Winograd
    * @date 16/02/2021
    * @description Create a List of Contacts
    * @param None.  
    * @return List<Contact> - list of contacts null if none requested
    */
    public static List<Contact>  getContacts(Integer numOfContacts){
        List<Contact> lst_Contact = new List<Contact>();
        if (numOfContacts > 0){
            for (Integer i = 0; i < numOfContacts; i++){
                lst_Contact.add(new Contact(
                    FirstName = 'FirstName',
                    LastName = 'LastName', 
                    Email = 'test'+i+'@test'+i+'.com',
                    MailingCity = 'Odessa',
                    MailingPostalCode = '212',
                    MailingCountry = 'Ukaraine',
                    MailingState = 'Odessa',
                    MailingStreet = 'test'
                ));
            }
            return lst_Contact;
        }
        return null;
    }

    /**
    * @author Itzik Winograd
    * @date 16/02/2021
    * @description Create a List of Contacts for specific contact
    * @param None.  
    * @return List<Contact> - list of contacts null if none requested
    */
    public static List<Contact>  getContactsForAccount(Integer numOfContacts, Account acc){
        List<Contact> lst_Contact = new List<Contact>();
        if (numOfContacts > 0){
            lst_Contact = ContactUtils.getContacts(numOfContacts);
            for(Contact con : lst_Contact){
                con.AccountId = acc.Id;
            }
            return lst_Contact;
        }
        return null;
    }
}