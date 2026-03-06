@isTest(SeeAllData=true)
    public class ImportToSalesLoftTest {
      // Create Data for StandardSetController
      static testmethod void handlesAccounts() {
        List<Account> accountList = [SELECT Id, Name FROM Account LIMIT 3];
        System.assert(accountList != null);
          
       	ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(accountList);
        stdSetCont.setSelected(accountList);
          
        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();
          
        String url = result.getUrl();
        String queryParam = result.getParameters().get('account');
          
        System.assertEquals(3, queryParam.split(',').size());
     }
        
     static testmethod void handlesLeads() {
        List<Lead> leadList = [SELECT Id, Name FROM Lead LIMIT 3];
        System.assert(leadList != null);
  	          
       	ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(leadList);
        stdSetCont.setSelected(leadList);
          
        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();
          
        String url = result.getUrl();
        String queryParam = result.getParameters().get('lead');
        
        System.assertEquals(3, queryParam.split(',').size());
     }
        
     static testmethod void handlesContacts() {
        List<Contact> contactList = [SELECT Id, Name FROM Contact LIMIT 3];
        System.assert(contactList != null);
  	   
       	ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(contactList);
        stdSetCont.setSelected(contactList);
          
        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();
      
        String url = result.getUrl();
        String queryParam = result.getParameters().get('contact');
          
        System.assertEquals(3, queryParam.split(',').size());
     }
        
     static testmethod void handlesUnselectedSets() {
        List<Contact> contactList = [SELECT Id, Name FROM Contact LIMIT 3];
        System.assert(contactList != null);

       	ApexPages.StandardSetController stdSetCont = new ApexPages.StandardSetController(contactList);

        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdSetCont);
        PageReference result = mainCont.redirect();

        String url = result.getUrl();
        String queryParam = result.getParameters().get('contact_listview');

        System.assertEquals(true, String.isNotBlank(queryParam));
        System.assertEquals(1, queryParam.split(',').size());
     }
     
     // Tests that the controller can hanldle importing 1 off sObjects as well.    
     static testmethod void handleOneoffContact() {
        List<Contact> contactList = [SELECT ID FROM Contact LIMIT 1];
        System.assert(contactList != null);
        ApexPages.StandardController stdController = new ApexPages.StandardController(contactList[0]);
        
        ImportToSalesLoft mainCont = new ImportToSalesLoft(stdController);
        PageReference result = mainCont.redirect(); 
        
        String url = result.getUrl();
        String queryParam = result.getParameters().get('contact');
        
 		System.assertEquals(true, String.isNotBlank(queryParam));
        System.assertEquals(1, queryParam.split(',').size());
     }
   }