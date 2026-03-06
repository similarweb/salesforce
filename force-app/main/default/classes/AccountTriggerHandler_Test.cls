/******************************************************************************* 
Name : AccountTriggerHandler_Test
Description : test class for AccountTriggerHandler class
Created/Modified by Created/Modified Date Requested by Related Task/Issue 
---------------------------------------------------------------------------------------- 
1.Nevo Haarari			 04/03/2018			ARIEL LOPEZ				[SW-28689] 
*********************************************************************************** 
*/
@isTest   
public class AccountTriggerHandler_Test  {


	@isTest  
	 static void  AccountTriggerHandler_Insert_TEST() {
		Account a = new Account();
		a.name = 'test1';
		a.Business_Unit__c='SMB';
		a.AccountDomain__c = 'DIMA.com';
		a.Domain__c = 'DIMA.com';
		a.SW_Industry__c = 'test1';
		a.Sys_Hierarchy_Required__c = 'Yes';
		a.Email_address_domain_type_SFDC__c = 'Company';
		a.Website = 'DIMA.COM';
		insert a;
		a.Domain__c = 'Nevo2.com';
		update a;

	}

}