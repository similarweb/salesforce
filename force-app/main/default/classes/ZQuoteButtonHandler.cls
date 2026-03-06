public with sharing class ZQuoteButtonHandler {
	
	public ApexPages.StandardController con;
	
	public static boolean IsTest = false;
	
	public ZQuoteButtonHandler(apexPages.StandardController con)
	{
		this.con = con;
	}
	
	public static pagereference CloneQuote()
	{
		system.debug('TESTING CloneQuote fired');
		id qid =apexpages.currentpage().getParameters().get('id');
		zqu__Quote__c q = [select id,zqu__ApprovalStatus__c,zqu_Quote_Status__c  from zqu__Quote__c where id=:qid limit 1];
		system.debug('TESTING q found: '+q.id);
		boolean allowredirect = false;
		
		system.debug('TESTING q.zqu__ApprovalStatus__c is '+q.zqu__ApprovalStatus__c);
		system.debug('TESTING q.zqu_Quote_Status__c is '+q.zqu_Quote_Status__c);
		
		if (q.zqu__ApprovalStatus__c!=null && 
		     (q.zqu__ApprovalStatus__c.EqualsIgnoreCase('new') ||
			  q.zqu__ApprovalStatus__c.EqualsIgnoreCase('rejected') ||
			  q.zqu__approvalstatus__c.EqualsIgnoreCase('In Progress') ||
			  IsTest
			 )
			&& !q.zqu_Quote_Status__c.EqualsIgnoreCase('Ready for Billing')
		) allowredirect = true;
		
		system.debug('TESTING allowredirect is '+allowredirect);
		PageReference pr = new PageReference('/apex/zqu__CloneQuote?id='+qid);
		
		if (allowredirect) return pr; else return null; 
	}
    
}