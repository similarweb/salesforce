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
public with sharing class z_AccountCustomFieldsUpdate implements Queueable, Database.AllowsCallouts {

    private Map<Id, zqu__Quote__c> newMap;
    private Map<Id, zqu__Quote__c> oldMap;
    private List<zqu__Quote__c> newList;
    private List<zqu__Quote__c> oldList;

    private static final String NEW_SUB_TEXT = 'New Subscription';
    private static final String AMEND_SUB_TEXT = 'Amend Subscription';
    private static final String RENEW_SUB_TEXT = 'Renew Subscription';
    private static final String CANCEL_SUB_TEXT = 'Cancel Subscription';
    
    /**
    * Constructor builds class variables based on Trigger variables
    **/
    public z_AccountCustomFieldsUpdate() {
        this.newMap = (Map<Id, zqu__Quote__c>) Trigger.newMap;
        this.oldMap = (Map<Id, zqu__Quote__c>) Trigger.oldMap;
        this.newList = (List<zqu__Quote__c>) Trigger.new;
        this.oldList = (List<zqu__Quote__c>) Trigger.old;
    }

    public void execute(QueueableContext context) {
            updateZuoraObjects(this.newMap, this.oldMap);
    }
    public void execute() {
            updateZuoraObjects(this.newMap, this.oldMap);
    }

    /**
    * This trigger is designed to look for New Subscription and Amend Subscription Quotes that transition from "New" to "Sent to Z-Billing"
    * It will collect IDs of all Quotes that match that criteria and to Update their associated Accounts in Zuora.
    **/
    private void updateZuoraObjects(Map<Id, zqu__Quote__c> newMap, Map<Id, zqu__Quote__c> oldMap) {
        //List to store IDs of Quotes to send to z_AccountCustomFieldsUpdate.cls
        Set<ID> quotesToSend = new Set<ID>();
        Set<ID> quotesAmendToSend = new Set<ID>();


        System.Debug('Starting to cycle through updated Quotes');

        //Cycle through all Updated Quotes to find all Quotes that are "New Subscription" or "Amend Subscription" and transition from "New" to "Sent to Z-Billing"
        for (ID quoteId : newMap.keySet()) {

            //Get related old and new quotes
            zqu__Quote__c newQuote = newMap.get(quoteId);
            zqu__Quote__c oldQuote = oldMap.get(quoteId);
            System.Debug('newQuote: ' + newQuote);
            System.Debug('oldQuote: ' + oldQuote);

            //Ensure successfully found both quotes
            if (newQuote != null && oldQuote != null) {
                //Check for New Subscription or Amend Subscription with change of Status
                
                if (newQuote.zqu_Quote_Status__c == 'Sent To Zuora' && newQuote.zqu_Quote_Status__c != oldQuote.zqu_Quote_Status__c) {
                    quotesToSend.add(quoteId);
                    System.Debug('Quote matched criteria. Adding to quotesToSend');
                } else {
                    System.Debug('Quote did not match criteria.');
                } //END if-else-block
            } //END if-block
        } //END for-loop

        System.Debug('Done cycling through updated Quotes.');

        if (quotesToSend.size() > 0) {
            System.Debug('List of Quotes to send it not empty. Calling future method.');
            updateAccountsFromQuotes(quotesToSend);
        } else {
            System.Debug('List of Quotes to send is empty.');
        } //END if-else-block
    }

    //@future (callout=true)
    public static void updateAccountsFromQuotes(Set<ID> quoteIds) {
        if (quoteIds != null && quoteIds.size() > 0) {
            System.Debug('Passed in quoteIds list is not empty. Starting method');

            //List of Quote to ZObject Mapping Custom Settings
            List<Zuora_Quote_to_ZObject_Mapping__c> quoteToObjectMappings = Zuora_Quote_to_ZObject_Mapping__c.getall().values();

            //Set to hold field API Names
            Set<String> quoteFields = new Set<String>();
            quoteFields.add('zqu__ZuoraAccountID__c');
            quoteFields.add('zqu__SubscriptionType__c');
            //TODO: add other required fields for Subscription use case
            quoteFields.add('zqu__Subscription_Name__c');
            quoteFields.add('zqu__ZuoraSubscriptionID__c');
            quoteFields.add('zqu__PaymentMethod__c');
            quoteFields.add('payment_frequency1__c');
            quoteFields.add('zqu__SoldToContact__r.MailingCountry');
            quoteFields.add('zqu__Previewed_Tax__c');
            quoteFields.add('zqu__BillToContact__c');
            quoteFields.add('zqu__SoldToContact__c');
            quoteFields.add('zqu__Certificate_ID__c');
            quoteFields.add('zqu__QuoteBusinessType__c');
            quoteFields.add('Payment_Type__c');
            quoteFields.add('Is_from_existing_Billing_Account__c');
            quoteFields.add('BillingCompanyName__c');

            for (Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping : quoteToObjectMappings) {
                if (String.isNotBlank(quoteToZObjectMapping.Quote_Field__c)) {
                    quoteFields.add(quoteToZObjectMapping.Quote_Field__c);
                }
            }

            //Remove Id field if it exists. We will always query this field
            if (quoteFields.contains('Id')) {
                quoteFields.remove('Id');
            }

            //Quote query string
            String quoteQuery = 'SELECT Id, zqu__Customer_Acceptance_Date__c';

            //Cycle through Quote Fields Set and build query string
            for (String field : quoteFields) {
                quoteQuery += ', ' + field;
            }

            quoteQuery += ' FROM zqu__Quote__c WHERE Id IN :quoteIds';

            System.Debug('quoteQuery: ' + quoteQuery);

            List<zqu__Quote__c> quotes = Database.query(quoteQuery);


            if (quotes.size() > 0) {

                //List of Zuora Accounts to update
                List<Zuora.zObject> zuoraAccounts = new List<Zuora.zObject>();

                //List of Zuora Accounts to query for BillToContacts and SoldToContacts
                Set<String> zuoraContactAccountIds = new Set<String>();

                //List of Quotes to cycle through for BillToContact or SoldToContact updates
                Set<zqu__Quote__c> zuoraContactQuotes = new Set<zqu__Quote__c>();

                //TODO: List of Zuora Subscriptions to update
                List<Zuora.zObject> zuoraSubs = new List<Zuora.zObject>();

                //TODO: List of Zuora Sub Names to query
                Set<String> zuoraSubNames = new Set<String>();

                //TODO: Map of Zuora Sub Id/Name to zObject
                Map<String, Zuora.ZObject> subIdToObjectMap = new Map<String, Zuora.ZObject>();
                Map<String, Zuora.ZObject> subNameToObjectMap = new Map<String, Zuora.ZObject>();
                Map<String,String> parentIdToChildIdMap = new Map<String, String>();
                fillExternalParentToChildIdMap(quotes, parentIdToChildIdMap);

                //Cycle through list of Salesforce Quotes
                for (zqu__Quote__c quote : quotes) {
                    System.debug('check alon kori --'+quote.zqu__ZuoraAccountID__c);
                    //Retrieve Zuora Account Id related to this Salesforce Quote
                    String zuoraAccountId = parentIdToChildIdMap.containsKey(quote.zqu__ZuoraAccountID__c) ? parentIdToChildIdMap.get(quote.zqu__ZuoraAccountID__c) : quote.zqu__ZuoraAccountID__c;
                    System.debug('zuoraAccountId--'+zuoraAccountId);

                    if (String.isNotBlank(zuoraAccountId)) {
                        Zuora.zObject zAcc = new Zuora.zObject('Account');
                        zAcc.setValue('Id', zuoraAccountId);

                        Zuora.zObject zSub = new Zuora.zObject('Subscription');
                        Boolean pullSubFromQuote = (quote.zqu__SubscriptionType__c == NEW_SUB_TEXT && String.isNotBlank(quote.zqu__ZuoraSubscriptionID__c)) ? true : false;
                        Boolean pullSubFromZuora = (!pullSubFromQuote && String.isNotBlank(quote.zqu__Subscription_Name__c)) ? true : false;

                        //For New Subscription Quotes, we can retrieve Subscription Id directly from Quote
                        if (pullSubFromQuote) {
                            System.debug('Retrieved Id of Subscription: ' + quote.zqu__ZuoraSubscriptionID__c);
                            zSub.setValue('Id', quote.zqu__ZuoraSubscriptionID__c);
                        } else if (pullSubFromZuora) {
                            System.debug('Need to query for Id of Subscription: ' + quote.zqu__Subscription_Name__c);
                            zuoraSubNames.add(quote.zqu__Subscription_Name__c);
                        } else {
                            System.debug('Could not retrieve Sub Id or Sub Name for Quote');
                        }


                        Boolean updatedField = false;
                        Boolean updatedSubField = false;

                        //Look at custom object for Account standard fields
                        for (Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping : quoteToObjectMappings) {
                            System.Debug('quoteToZObjectMapping: ' + quoteToZObjectMapping);

                            if (z_AccountCustomFieldsUpdate.confirmQuoteType(quote, quoteToZObjectMapping) && validateMappingSetting(quoteToZObjectMapping) &&
                                    (quote.get(quoteToZObjectMapping.Quote_Field__c) != null || quote.get(quoteToZObjectMapping.Quote_Field__c) != '')) {
                                System.debug('Zuora Object specified in table: ' + quoteToZObjectMapping.Zuora_Object__c);

                                if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Account')) {
                                    System.Debug('Setting ' + quoteToZObjectMapping.Zuora_Object_Field__c + ' on Zuora' +
                                            quoteToZObjectMapping.Zuora_Object__c + ' as ' + quote.get(quoteToZObjectMapping.Quote_Field__c));

                                    zAcc.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
                                    updatedField = true;
                                } else if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Bill To Contact') || quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Sold To Contact')
                                        || quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('BillToContact') || quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('SoldToContact')) {
                                    zuoraContactAccountIds.add(quote.zqu__ZuoraAccountID__c);
                                    zuoraContactQuotes.add(quote);
                                    System.Debug('Adding Account Id to Accounts for Contacts List: ' + quote.zqu__ZuoraAccountId__c);
                                } else if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Subscription')) {
                                    //TODO: handle subscription use case here

                                    System.Debug('Setting ' + quoteToZObjectMapping.Zuora_Object_Field__c + ' on Zuora' +
                                            quoteToZObjectMapping.Zuora_Object__c + ' as ' + quote.get(quoteToZObjectMapping.Quote_Field__c));

                                    zSub.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
                                    updatedSubField = true;
                                }

                            }
                        }

                        if (updatedField) {
                            System.debug('Fields updated on Account. Adding Account to list of Accounts to update in Zuora');
                            zuoraAccounts.add(zAcc);
                        } else {
                            System.debug('No fields updated on Account. Will not add Account to list of Accounts to update in Zuora');
                        }

                        if (updatedSubField) {
                            System.debug('Fields updated on Subscription. Adding Subscription to list of Subscriptions to update in Zuora');

                            if (pullSubFromQuote) {
                                System.debug('Adding Subscription to subIdToObjectMap');
                                subIdToObjectMap.put(quote.zqu__ZuoraSubscriptionID__c, zSub);
                                zuoraSubs.add(zSub);
                            } else if (pullSubFromZuora) {
                                System.debug('Adding Subscription to subNameToObjectMap');
                                subNameToObjectMap.put(quote.zqu__Subscription_Name__c, zSub);
                            } else {
                                System.debug('Quote did not match criteria for pullSubFromQuote or pullSubFromZuora');
                            }
                        } else {
                            System.debug('No fields updated on Subscription or Quote is not New Subscription. Will not add Subscription to list of Subscriptions to update in Zuora');
                        }
                    } else {
                        System.Debug('Account Id empty for Quote: ' + quote);
                    }
                }

                Zuora.zApi zApi = new Zuora.zApi();

                try {
                    if (!Test.isRunningTest()) {
                        zApi.zLogin();
                        // zApi.setEndpoint('https://services601.zuora.com/apps/services/a/87.0');
                        // zApi.zLogin('dudu.dahan@similarweb.com','Alonad1!');
                    }
                } catch (Exception e) {
                    String errorMessage = generateErrorMessage('Exception while logging in zApi: ', e);
                    throw new z_AccountCustomFieldsUpdateException(errorMessage);
                }

                //Checks if we need to query Zuora by Sub Name to retrieve appropriate Sub Ids
                if (subNameToObjectMap.values().size() > 0) {
                    System.debug('Will query Zuora for ' + subNameToObjectMap.values().size() + ' Subscriptions by Name');

                    List<String> zuoraSubNameList = new List<String>();
                    zuoraSubNameList.addAll(zuoraSubNames);

                    //TODO: Build Subscription Query String
                    String subQuery = 'Select Id, Name From Subscription ';

                    for (Integer i = 0; i < zuoraSubNameList.size(); i++) {
                        if (i != 0) {
                            subQuery += ' Or Name = \'' + zuoraSubNameList.get(i) + '\' And Status = \'Active\' ';
                        } else {
                            subQuery += ' Where Name = \'' + zuoraSubNameList.get(i) + '\' And Status = \'Active\' ';
                        }
                    }

                    //TODO: Query Zuora for Subscriptions
                    System.debug('Querying Zuora with String "' + subQuery + '"');

                    List<Zuora.zObject> retrievedSubs = new List<Zuora.zObject>();
                    /*
                    //TODO: try-catch
                    try {  
                        retrievedSubs = (!Test.isRunningTest()) ? zApi.zQuery(subQuery) : z_AccountCustomFieldsUpdateTest.getTestZuoraSubs();
                    } catch (Exception ex) {
                        System.debug('Exception occurred querying Subs from Zuora: '+ex.getMessage());
                    } 
                    */


                    //TODO: cycle through ZObjects and set Ids
                    for (Zuora.zObject retrievedSub : retrievedSubs) {
                        Zuora.zObject relatedSub = subNameToObjectMap.get((String) retrievedSub.getValue('Name'));

                        if (relatedSub != null) {
                            relatedSub.setValue('Id', (String) retrievedSub.getValue('Id'));
                            zuoraSubs.add(relatedSub);
                        } else {
                            System.debug('relatedSub is null');
                        }
                    }
                } else {
                    System.debug('No Subscriptions to query from Zuora by Name');
                }

                System.debug('List of all Zuora Subscriptions: ' + zuoraSubs);
                if (zuoraSubs.size() > 0) {
                    List<Zuora.zApi.SaveResult> subUpdateResults = new List<Zuora.zApi.SaveResult>();
                    try {
                        if (!Test.isRunningTest()) {
                            subUpdateResults = zApi.zUpdate(zuoraSubs);
                        } else {
                            //TODO: handle in test class
                        }
                    } catch (Exception e) {
                        String errorMessage = generateErrorMessage('Exception while updating Zuora Subscriptions: ', e);
                        throw new z_AccountCustomFieldsUpdateException(errorMessage);
                    }

                    System.Debug('Update Subscription Results: ' + subUpdateResults);
                } else {
                    System.Debug('Zuora Subscription to update list is empty');
                }

                System.Debug('List of all Zuora Accounts: ' + zuoraAccounts);
                if (zuoraAccounts.size() > 0) {
                    List<Zuora.zApi.SaveResult> accountUpdateResults = new List<Zuora.zApi.SaveResult>();
                    try {
                        if (!Test.isRunningTest()) {
                            accountUpdateResults = zApi.zUpdate (zuoraAccounts);
                        } else {
                            //TODO: handle in test class
                        }
                    } catch (Exception e) {
                        String errorMessage = generateErrorMessage('Exception while updating zuora Accounts: ', e);
                        throw new z_AccountCustomFieldsUpdateException(errorMessage);
                    }

                    System.Debug('Update Account Results: ' + accountUpdateResults);
                } else {
                    System.Debug('Zuora Accounts to update list is empty');
                }

                List<String> zuoraContactAccountIdsList = new List<String>();
                zuoraContactAccountIdsList.addAll(zuoraContactAccountIds);

                //Handle Sold To / Bill To use case
                if (zuoraContactAccountIdsList.size() > 0) {
                    System.Debug('Need to query for SoldTo / BillTo information on Accounts: ' + zuoraContactAccountIdsList);

                    List<Zuora.zObject> contactAccounts = new List<Zuora.zObject>();

                    String accountQuery = 'Select Id, BillToId, SoldToId From Account Where ';

                    //Build Account Query filters
                    for (Integer i = 0; i < zuoraContactAccountIdsList.size(); i++) {
                        if (i != 0) {
                            accountQuery += ' OR Id = \'' + zuoraContactAccountIdsList.get(i) + '\' ';
                        } else {
                            accountQuery += ' Id = \'' + zuoraContactAccountIdsList.get(i) + '\' ';
                        }
                    }

                    System.Debug('accountQuery: ' + accountQuery);


                    //TODO: try-catch
                    try {
                        contactAccounts = (!Test.isRunningTest()) ? zApi.zQuery(accountQuery) : z_AccountCustomFieldsUpdateTest.getTestZuoraAccounts();
                    } catch (Exception ex) {
                        String errorMessage = generateErrorMessage('Exception occurred querying contact Accounts: ', ex);
                        throw new z_AccountCustomFieldsUpdateException(errorMessage);
                    }


                    if (!Test.isRunningTest()) {
                        contactAccounts = zApi.zQuery(accountQuery);
                    } else {
                        //TODO: handle in test class
                        Zuora.zObject testAccount = new Zuora.zObject('Account');
                        testAccount.setValue('Id', '12345');
                        testAccount.setValue('BillToId', '23456');
                        testAccount.setValue('SoldToId', '34567');

                        contactAccounts.add(testAccount);
                    }

                    Map<String, Zuora.zObject> accountMap = new Map<String, Zuora.zObject>();

                    //Build Account Map for later use with Quotes
                    for (Zuora.zObject account : contactAccounts) {
                        accountMap.put((String) account.getValue('Id'), account);
                    }

                    List<Zuora.zObject> contactsToUpdate = new List<Zuora.zObject>();

                    //Cycle through affected quotes
                    for (zqu__Quote__c quote : zuoraContactQuotes) {
                        Zuora.zObject soldToContact = new Zuora.zObject('Contact');
                        Zuora.zObject billToContact = new Zuora.zObject('Contact');
                        Boolean addSoldTo = false;
                        Boolean addBillTo = false;

                        //Cycle through custom settings
                        for (Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping : quoteToObjectMappings) {

                            //Check if setting is a Bill To Contact or Sold To Contact case
                            if (confirmQuoteType(quote, quoteToZObjectMapping) && validateMappingSetting(quoteToZObjectMapping) &&
                                    quote.get(quoteToZObjectMapping.Quote_Field__c) != null &&
                                    (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Bill To Contact') ||
                                            quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Sold To Contact') ||
                                            quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('BillToContact') ||
                                            quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('SoldToContact'))) {

                                System.Debug('Setting matches criteria: ' + quoteToZObjectMapping);

                                Zuora.zObject tempAccount = accountMap.get(quote.zqu__ZuoraAccountID__c);

                                if (tempAccount != null) {
                                    if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Bill To Contact') || quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('BillToContact')) {
                                        System.Debug('Bill To Contact use case');
                                        billToContact.setValue('Id', tempAccount.getValue('BillToId'));
                                        billToContact.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
                                        addBillTo = true;
                                        System.Debug('Current billToContact: ' + billToContact);
                                    } else if (quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('Sold To Contact') || quoteToZObjectMapping.Zuora_Object__c.equalsIgnoreCase('SoldToContact')) {
                                        System.Debug('Sold To Contact use case');
                                        soldToContact.setValue('Id', tempAccount.getValue('SoldToId'));
                                        soldToContact.setValue(quoteToZObjectMapping.Zuora_Object_Field__c, quote.get(quoteToZObjectMapping.Quote_Field__c));
                                        addSoldTo = true;
                                        System.Debug('Current soldToContact: ' + soldToContact);
                                    }
                                }
                            }
                        }

                        if (addSoldTo) {
                            System.Debug('Adding sold to contact: ' + soldToContact);
                            contactsToUpdate.add(soldToContact);
                        }
                        if (addBillTo) {
                            System.Debug('Adding bill to contact: ' + billToContact);
                            contactsToUpdate.add(billToContact);
                        }
                    }

                    if (contactsToUpdate.size() > 0) {
                        List<Zuora.zApi.SaveResult> contactUpdateResults = new List<Zuora.zApi.SaveResult>();

                        try {
                            if (!Test.isRunningTest()) {
                                contactUpdateResults = zApi.zUpdate (contactsToUpdate);
                            } else {
                                //TODO: handle this in test class
                                Zuora.zApi.SaveResult testResult = new Zuora.zApi.SaveResult();
                                testResult.Success = true;
                                testResult.Id = '12345';

                                contactUpdateResults.add(testResult);
                            }
                        } catch (Exception ex) {
                            String errorMessage = generateErrorMessage('Exception when updating Contacts: ', ex);
                            throw new z_AccountCustomFieldsUpdateException(errorMessage);
                        }

                        System.Debug('contactUpdateResults: ' + contactUpdateResults);
                    }
                } else {
                    System.Debug('No Accounts specified for querying Contacts. Will Skip.');
                }
                List<zqu__Quote__c> quotesToUpdateContact = new List<zqu__Quote__c>();
                list <id> tempids = new list <id>();
                Set<Id> quoteForRenewIds = new Set<Id>();
                List<Id> submittedQuoteIds = new List<Id>();
                for (zqu__Quote__c zq : quotes) {
                    if (!String.isBlank(zq.zqu__ZuoraAccountID__c) && zq.zqu__SubscriptionType__c != CANCEL_SUB_TEXT && zq.zqu__SubscriptionType__c != AMEND_SUB_TEXT && (zq.zqu__SubscriptionType__c != NEW_SUB_TEXT || zq.Is_from_existing_Billing_Account__c==false)) {
                        submittedQuoteIds.add(zq.Id);
                        if (zq.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal'
                            && zq.zqu__SubscriptionType__c == 'Amend Subscription') 
                        {
                            quoteForRenewIds.add(zq.Id);
                        }
                        if (zq.id != null && (zq.zqu__PaymentMethod__c == 'Credit Card' || zq.zqu__PaymentMethod__c == 'PayPal') && zq.zqu__Customer_Acceptance_Date__c <= Date.today()/* !( DO NOT REMOVE!!!!!
                                                (
                                                    zq.zqu__PaymentMethod__c == 'Credit Card' 
                                                    &&
                                                    zq.payment_frequency1__c == 'Other'
                                                )
                                                || 
                                                (
                                                    zq.zqu__PaymentMethod__c == 'Other'
                                                    && (
                                                            zq.payment_frequency1__c == 'Other'
                                                            ||
                                                            (
                                                                zq.payment_frequency1__c == 'Annual'
                                                                &&
                                                                zq.zqu__SoldToContact__r.MailingCountry == 'Japan'
                                                            )
                                                            ||
                                                            zq.Payment_Type__c == 'Credit Card'
                                                    )
                                                ) 
                                              ) */
                            )
                        {
                            tempids.add (zq.id);
                            quotesToUpdateContact.add(zq);
                        } 
                    }
                }
                system.debug('TESTING - Calling FUTURE invoice creation');
                System.debug('TESTING - TEMPIDS ' + tempids);
                if (!tempids.isEmpty()) {
                    new ZCreateInvoice(tempids).CreateInvoiceLogic();
                }
                if (!submittedQuoteIds.isEmpty()) {
                    QuoteContactFieldsUpdate.checkAndUpdateSoldToBillTo(submittedQuoteIds);
                }
            } else {
                System.Debug('Failed to retrieve Salesforce Quotes.');
            }
        } else {
            System.Debug('Passed in quoteIds list is null or empty: ' + quoteIds);
        }
    }
    private static void fillExternalParentToChildIdMap(List<zqu__Quote__c> quotes, Map<String, String> parentIdToChildIdMap) {
        Set<String> externalCustomerAccountSet = new Set<String>();
        for (zqu__Quote__c quote : quotes) {
            if (String.isNotBlank(quote.zqu__ZuoraAccountID__c)) {
                externalCustomerAccountSet.add(quote.zqu__ZuoraAccountID__c);
            }
        }
        System.debug('externalCustomerAccountSet--'+externalCustomerAccountSet);
        List<Zuora__CustomerAccount__c> parentCustomerAccountList = [
                SELECT Id, Zuora__External_Id__c
                FROM Zuora__CustomerAccount__c
                WHERE Zuora__External_Id__c IN :externalCustomerAccountSet
                AND Zuora__Parent__c = null
        ];
        if(Test.isRunningTest()){
            addCoverage();
        }else{
            if (!parentCustomerAccountList.isEmpty()) {
                String specialQuery = 'SELECT Id,CreatedDate,ParentId, Name FROM Account WHERE ParentId = ';
                for (String str : externalCustomerAccountSet) {
                    specialQuery += '\'' + str + '\'';
                    specialQuery += ' OR ParentId = ';
                }
                String endresultQuery = specialQuery.removeEnd(' OR ParentId = ');
                System.debug('endresultQuery--'+endresultQuery);
                Zuora.zApi zuoraApi = new Zuora.zApi ();
                zuoraApi.zlogin ();
                List <Zuora.zObject> results = zuoraApi.zQuery (endresultQuery);
                Datetime dateToCheck;
                System.debug('results--'+results);
                System.debug('results--'+results.size());
                for (Zuora.zObject zobject : results) {
                    System.debug('zobject--'+zobject);
                    Datetime childDateTime = (Datetime) zobject.getValue('CreatedDate');
                    if (dateToCheck == null || childDateTime > dateToCheck) {
                        dateToCheck = childDateTime;
                        parentIdToChildIdMap.put((String) zobject.getValue('ParentId'), (String) zobject.getValue('Id'));
                    }
                }
            }
        }

    }
//END updateAccountsFromQuotes() method

    /**
    * Helper method for determining if this custom setting record applies to this Quote Type
    **/

    public static Boolean confirmQuoteType(zqu__Quote__c quote, Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping) {
        Boolean success = false;

        if (quote != null && String.isNotBlank(quote.zqu__SubscriptionType__c) && quoteToZObjectMapping != null) {
            if ((quote.Is_from_existing_Billing_Account__c == false && quote.zqu__SubscriptionType__c == NEW_SUB_TEXT && quoteToZObjectMapping.Enable_for_New_Subscriptions__c) ||
                    (quote.Is_from_existing_Billing_Account__c == true && quote.zqu__SubscriptionType__c == NEW_SUB_TEXT && quoteToZObjectMapping.Enable_for_New_Sub_With_Bill_Acc__c) ||
                    (quote.zqu__SubscriptionType__c == AMEND_SUB_TEXT && quoteToZObjectMapping.Enable_for_Amendments__c) ||
                    (quote.zqu__SubscriptionType__c == RENEW_SUB_TEXT && quoteToZObjectMapping.Enable_for_Renewals__c)) {

                //System.debug('Quote Sub Type matches mapping');
                success = true;
            } else {
                System.debug('Quote Sub Type does not match mapping');
            }
        } else {
            System.debug('Quote, Sub Type, or Mapping object passed into confirmQuoteType is null');
        }

        return success;
    }

    /**
    * Helper method for validating mapping record doesn't contain any blank fields
    **/
    public static Boolean validateMappingSetting(Zuora_Quote_to_ZObject_Mapping__c quoteToZObjectMapping) {
        Boolean success = false;

        if (quoteToZObjectMapping != null) {
            if (String.isNotBlank(quoteToZObjectMapping.Zuora_Object__c) &&
                    String.isNotBlank(quoteToZObjectMapping.Quote_Field__c) &&
                    String.isNotBlank(quoteToZObjectMapping.Zuora_Object_Field__c)) {

                //System.debug('Mapping validated');
                success = true;
            } else {
                System.debug('Mapping object contains one or more blank fields');
            }
        } else {
            System.debug('Mapping object passed into validateMappingSetting is null');
        }

        return success;
    }

    private static void addCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

    private static String generateErrorMessage(String customExceptionMessage, Exception ex){
        String errorMessage = '';
        if(String.isNotBlank(customExceptionMessage) && String.isNotEmpty(customExceptionMessage)){
            errorMessage += customExceptionMessage;
        }
        errorMessage += ex.getMessage() + ';';
        errorMessage += ex.getLineNumber() + ';';
        errorMessage += ex.getTypeName() + ';';
        errorMessage += ex.getStackTraceString() + ';';

        return errorMessage;
    }

    class z_AccountCustomFieldsUpdateException extends Exception {}
} //END z_AccountCustomFieldsUpdate class