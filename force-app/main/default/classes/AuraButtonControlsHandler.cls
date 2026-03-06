public with sharing class AuraButtonControlsHandler {
    public static AuraResponse redirectOnAccountReadyBusiness(String pageName,String accountId) {
    	Id aid = Id.valueof(accountId);
    	list<Account> la = [SELECT Id,BillingCountry,Business_Unit__c FROM Account WHERE Id=:aid];
    	Boolean canReassign = la.size()>0&&la[0].BillingCountry!=null&&la[0].Business_Unit__c!=null&&la[0].BillingCountry!=''&&la[0].Business_Unit__c!='';
    	System.debug('canReassign? '+canReassign);
    	if ( canReassign ) {
    		if ( pageName == 'ManualReassignAcc' ) AssignmentButtonHandler.factory(aid).ManualAccAssignment(); // account reassign SDR
    		else if ( pageName == 'ManualRoundRobinAccountSMBAM' ) AssignmentButtonHandler.factory(aid).ManualAssignmentSMBAM(); // account inside CSM
    		else if ( pageName == 'ManualRoundRobinAccountSMB' ) AssignmentButtonHandler.factory(aid).ManualAssignmentSMB(); // account inside sales
    	}
    	return canReassign?AuraResponse.succeed('Command Complete',pageName+' success'):AuraResponse.failed('Command Failed',Label.pleaseSetBusiness);
    }
    public static AuraResponse redirectOnLeadReadyBusiness(String pageName,String leadId) {
    	Id lid = Id.valueof(leadId);
    	list<Lead> la = [SELECT Id,Country,Business_Unit__c FROM Lead WHERE Id=:lid];
    	Boolean canReassign = la.size()>0&&la[0].Country!=null&&la[0].Business_Unit__c!=null&&la[0].Country!=''&&la[0].Business_Unit__c!='';
    	System.debug('canReassign? '+canReassign);
    	if ( canReassign ) {
    		if ( pageName == 'ManualLeadReassignment' ) AssignmentButtonHandler.factory(lid).ManualLeadReassignment(); // account reassign SDR
    	}
    	return canReassign?AuraResponse.succeed('Command Complete',pageName+' success'):AuraResponse.failed('Command Failed',Label.pleaseSetBusiness);
    }
    
    public static AuraResponse finalizeQuote(String QuoteId) {
    	Id qid = Id.valueof(QuoteId);
    	String msg = ZQuoteHandler.testForErrors(qid);
    	return msg==null|msg==''?AuraResponse.succeed('Confirm','Finalize Quote Succed'):AuraResponse.failed('Failed',msg);
    }
    public static AuraResponse newQuote(String OpportunityId,Boolean forcePositive) {
    	Id oppId = Id.valueof(OpportunityId);
    	CloudiusWS.Result cwr =  CloudiusWS.CheckBillingAccountBasic(oppId,forcePositive);
    	AuraResponse au =  cwr.success?AuraResponse.succeed('Confirm',cwr.message):AuraResponse.failed('Failed',cwr.message);
    	au.page = cwr.page;
    	return au;
    }
    public static AuraResponse openModal(String OpportunityId) {
    	Id oppId = Id.valueof(OpportunityId);
    	Account a =  CloudiusWS.getBillingAccountBasic(oppId);
    	AuraResponse au =  a!=null&&a.R00N40000001kyLcEAI__r.size()>0&&a.R00N40000001kyLcEAI__r[0].Zuora__DefaultPaymentMethod__c!=null?AuraResponse.succeed('Confirm',a.R00N40000001kyLcEAI__r[0].Zuora__DefaultPaymentMethod__c):AuraResponse.failed('Failed','no payment method');
    	return au;
    }
}