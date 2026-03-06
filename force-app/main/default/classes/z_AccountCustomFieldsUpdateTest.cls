/*    Copyright (c) 2014 Zuora, Inc.
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of 
 *   this software and associated documentation files (the "Software"), to use copy, 
 *   modify, merge, publish the Software and to distribute, and sublicense copies of 
 *   the Software, provided no fee is charged for the Software.  In addition the
 *   rights specified above are conditioned upon the following:
 *
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *
 *   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *   or promote products derived from this Software without specific prior written
 *   permission from Zuora, Inc.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
 *
 *   IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED
 *
 *   BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
 */
@isTest (SeeAllData=true)
public class z_AccountCustomFieldsUpdateTest { 

    public static final String testSubName = 'Test Zuora Subscription';
    public static final String testSubId = '1111111111';
    public static final String testAccountId = '2222222222';
    public static final String testContactId = '3333333333';

    static testMethod void testSubmitNewSubQuote() {
        createQuoteZObjectMappings();

        Account account = createTestAccount(null, true);
        Contact contact = createTestContact(account, true);
        Opportunity opportunity = createTestOpportunity(account, true);
        zqu__Quote__c quote = createTestQuote(account, opportunity, contact, contact, true, true);
        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        //Change status on quote from "New" to "Sent to Z-Billing"
        quote.zqu_Quote_Status__c = 'Sent To Zuora';
        update quote;
        
        Test.stopTest();
        
    }

    static testMethod void testSubmitAmendQuote() {
        createQuoteZObjectMappings();

        Account account = createTestAccount(null, true);
        Contact contact = createTestContact(account, true);
        Opportunity opportunity = createTestOpportunity(account, true);
        zqu__Quote__c quote = createTestQuote(account, opportunity, contact, contact, false, true);
        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        //Change status on quote from "New" to "Sent to Z-Billing"
        quote.zqu_Quote_Status__c = 'Sent To Zuora';
        update quote;
        
        Test.stopTest();
        
    }
    
    /**
    * Create a test Account
    **/
    public static Account createTestAccount(Account parent, Boolean doInsert) 
    {
        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.BillingCity = 'Atlanta';
        testAcc.BillingStateCode = 'GA';
        testAcc.BillingCountryCode = 'US';
        testAcc.BillingPostalCode = '12345';
        testAcc.BillingStreet = '123 Main St';
        
        if (parent != null) {
            testAcc.ParentId = parent.Id;
        }
        if (doInsert) {
            insert testAcc;
        }
    
        return testAcc;
    }

    /**
    * Create a test Contact
    **/
    public static Contact createTestContact(Account acc, Boolean doInsert)
    {
        Contact con = new Contact();
        con.FirstName = 'John';
        con.LastName = 'Smith';
        con.Phone = '1111111111';
        con.Email = 'test@test.com';
        con.MailingStreet = '123 Main St';
        con.MailingCity = 'Atlanta';
        con.MailingCountryCode = 'US';
        con.MailingStateCode = 'GA';
        con.MailingPostalCode = '12345';
    
        if (acc != null) {
            con.AccountId = acc.Id;
        }
        if (doInsert) {
            insert con;
        }
        
        return con;
    }
    
    /**
    * Create a test Opportunity
    **/
    public static Opportunity createTestOpportunity(Account acc, Boolean doInsert)
    {                
        Opportunity opp = new Opportunity();    
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        opp.Closed_Won_Reason_2__c = 'Unknown';
        opp.Type = 'New Business';          
        opp.Name = 'Test Opportunity';
        opp.RecordTypeId = '01267000000Qgu1AAC';
        
        if (acc != null) {
            opp.AccountId = acc.Id;
        }        
        if (doInsert) {
            insert opp;
        }
    
        return opp;
    }
    
    /**
    * Create a test Quote
    **/
    public static zqu__Quote__c createTestQuote(Account acc, Opportunity opp, Contact billTo, Contact soldTo, Boolean isNewSub, Boolean doInsert) {
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test Quote';
        quote.zqu__StartDate__c = System.today();
        quote.zqu__ValidUntil__c = System.today();
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        quote.zqu__InitialTerm__c = 12;
        quote.zqu__RenewalTerm__c = 12;
        quote.zqu__Account__c = (acc != null) ? acc.Id : null;
        quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
        quote.zqu__BillToContact__c = (billTo != null) ? billTo.Id : null;
        quote.zqu__SoldToContact__c = (soldTo != null) ? soldTo.Id : null;
        quote.zqu__Currency__c = 'USD';
        quote.zqu__ZuoraAccountID__c = testAccountId;
        quote.zqu__Status__c = 'New';

        if (isNewSub) {
            quote.zqu__SubscriptionType__c = 'New Subscription';
            quote.zqu__ZuoraSubscriptionID__c = testSubId;
        } else {
            quote.zqu__SubscriptionType__c = 'Amend Subscription';
            quote.zqu__Hidden_Subscription_Name__c = testSubName;
        }
    
        if (doInsert) {
            insert quote;
        }
    
        return quote;
    }
    
    /**
    * Creates mapping records in custom setting
    **/
    public static void createQuoteZObjectMappings() {
        Zuora_Quote_to_ZObject_Mapping__c accountMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        accountMapping.Name = 'Test Account Notes';
        accountMapping.Quote_Field__c = 'Name';
        accountMapping.Enable_for_New_Subscriptions__c = true;
        accountMapping.Enable_for_Amendments__c = true;
        accountMapping.Enable_for_Renewals__c = true;
        accountMapping.Zuora_Object__c = 'Account';
        accountMapping.Zuora_Object_Field__c = 'Notes';

        Zuora_Quote_to_ZObject_Mapping__c billToContactMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        billToContactMapping.Name = 'Test Bill To Description';
        billToContactMapping.Quote_Field__c = 'Name';
        billToContactMapping.Enable_for_New_Subscriptions__c = true;
        billToContactMapping.Enable_for_Amendments__c = true;
        billToContactMapping.Enable_for_Renewals__c = true;
        billToContactMapping.Zuora_Object__c = 'Bill To Contact';
        billToContactMapping.Zuora_Object_Field__c = 'Description';

        Zuora_Quote_to_ZObject_Mapping__c soldToContactMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        soldToContactMapping.Name = 'Test Sold To Description';
        soldToContactMapping.Quote_Field__c = 'Name';
        soldToContactMapping.Enable_for_New_Subscriptions__c = true;
        soldToContactMapping.Enable_for_Amendments__c = true;
        soldToContactMapping.Enable_for_Renewals__c = true;
        soldToContactMapping.Zuora_Object__c = 'Sold To Contact';
        soldToContactMapping.Zuora_Object_Field__c = 'Description';

        Zuora_Quote_to_ZObject_Mapping__c subMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        subMapping.Name = 'Test Subscription Notes';
        subMapping.Quote_Field__c = 'Name';
        subMapping.Enable_for_New_Subscriptions__c = true;
        subMapping.Enable_for_Amendments__c = true;
        subMapping.Enable_for_Renewals__c = true;
        subMapping.Zuora_Object__c = 'Subscription';
        subMapping.Zuora_Object_Field__c = 'Notes';

        insert new List<Zuora_Quote_to_ZObject_Mapping__c>{accountMapping, billToContactMapping, soldToContactMapping, subMapping};
    }

    /**
    * Returns Subscription ZObjects "queried" from Zuora
    **/
    public static List<Zuora.zObject> getTestZuoraSubs() {
        Zuora.zObject sub = new Zuora.zObject('Subscription');
        sub.setValue('Name', testSubName);
        sub.setValue('Id', testSubId);

        return new List<Zuora.zObject>{sub};
    }

    /**
    * Returns Account ZObjects "queried" from Zuora
    **/
    public static List<Zuora.zObject> getTestZuoraAccounts() {
        Zuora.zObject testAccount = new Zuora.zObject('Account');
        testAccount.setValue('Id', testAccountId);
        testAccount.setValue('BillToId', testContactId);
        testAccount.setValue('SoldToId', testContactId);

        return new List<Zuora.zObject>{testAccount};
    }
}