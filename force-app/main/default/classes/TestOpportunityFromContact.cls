@isTest
public with sharing class TestOpportunityFromContact {
	@isTest
	public static void runTest() {
		Account a = TestObjectCreator.CreateAccount();
		insert a;
		Contact c = TestObjectCreator.CreateContact(a,'aaa@gmail.com');
		insert c;
		Test.startTest();
		ApexPages.currentPage().getParameters().put('retURL','/'+String.valueof(c.Id));
		ApexPages.StandardController cont = new  ApexPages.StandardController(new Opportunity());
		vfOpportunityFromContact vofc = new vfOpportunityFromContact(cont);
		vofc.redirect();
		Test.stopTest();
	}
}