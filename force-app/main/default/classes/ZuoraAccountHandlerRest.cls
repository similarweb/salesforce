public without sharing class ZuoraAccountHandlerRest {

    private static List<String> executionLogsList = new List<String>{};
    private static string paramsObtained = '';
    private enum ConvesionMode {NEWACCOUNT, HASMATCHEDACTIVE, COVERTTOMATCHED }
    public static final String TEMPLATE_HASMATCHEDACTIVE = 'NT_Package_Purchased_Active_Account';
    public static final String TEMPLATE_COVERTTOMATCHED = 'NT_Package_Purchased_Not_Active_Account';
    public static final String EMAIL_CC_RECIEVER = GeneralUtil.getGeneralConfig('ZuoraCCEmailRecipient').Text_Value__c; //'0050X000008vOrI'; //Lola Stolper
    //public static final String OWNER_ID = GeneralUtil.getGeneralConfig('ZuoraAccountOwner').Text_Value__c; //'005b000000438D2AAI'; //Rachel Eviston
    public static final List<Fields_Mapping__mdt> leadCapturefieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(new List<String>{'Lead_Capture_Update_Contact','Lead_Capture_Update_Lead'});
    public static final Map<String, Fields_Mapping__mdt> leadCaptureMappingByContactAttributeMap = GeneralUtil.getLeadCaptureByAttribute(leadCapturefieldMappingList, 'Lead_Capture_Update_Contact');
    private static Account matchedAccount = new Account();
    private static String leadId;
    private static String cntId;

    //private static final Map<String, String> countryCodeToNameMap = GeneralUtil.getCountryCodeToName();

    public static String handleCall (string uid, string email, string cname, string Fname, String Lname, String country, String websiteDomain, String industry, String minEmployees, String maxEmployees){
        executionLogsList.add('[INFO] STARTED');
        utils.isZuora = true;
        try{
            paramsObtained = logParams(uid, email, cname, Fname, Lname, country, websiteDomain, industry, minEmployees, maxEmployees);
            Account acc = new Account();
            executionLogsList.add('[INFO] Check Email is not Empty');
            if (String.isBlank(email))
                throw new NoEmailException('Email need to be specified');
            executionLogsList.add('[INFO] Search for existing Contact.');
            List<Contact> existingContact = genContactData(email);
            if(existingContact.size() > 0 && (String.isNotBlank(existingContact[0].MailingCountry) || String.isNotBlank(existingContact[0].OtherCountry)) ){
                executionLogsList.add('[INFO] Contact found '+ contact.Id);
                Contact contact = existingContact[0];
                System.debug('contact - ' + contact.Id);
                cntId = contact.Id;
                executionLogsList.add('[INFO] Merging contact to account.');
                acc = mergeContactToAccount(contact,acc,uid,cname, industry, minEmployees, maxEmployees, websiteDomain, country);
                attachContactToAccount(contact,acc);
            } else {
                executionLogsList.add('[INFO] Contact is not found. Search for existing Lead.');
                List<Lead> existingLead = genLeadData(email);
                String leadCountry = country;
                if(existingLead.size() > 0 && String.isNotBlank(existingLead[0].Country)){
                    leadCountry = existingLead[0].Country;
                }
                if(existingLead.size() > 0 && String.isNotBlank(leadCountry)){
                    Lead leadToConvert = existingLead[0];
                    leadId = leadToConvert.Id;
                    executionLogsList.add('[INFO] Lead to convert found: '+leadToConvert.Id);
                    if((leadToConvert.Email_address_domain_type__c == 'Private' || leadToConvert.Email_address_domain_type__c == 'Junk') &&
                            (leadToConvert.Business_Unit__c == 'Strategic' || leadToConvert.Business_Unit__c == 'Enterprise')){
                        acc = convertLeadToAccount(leadToConvert,uid,cname,false, false);
                    }else {
                        System.debug('leadToConvert - ' + leadToConvert.Id);
                        executionLogsList.add('[INFO] Searching for lead matched account.');
                        if(checkLeadAccountExists(leadToConvert.Website_Domain__c, leadCountry) == true){
                            executionLogsList.add('[INFO] Matched account found: '+ matchedAccount.Id);
                            executionLogsList.add('[INFO] Checking matched account Status and open Opportunities.');
                            if(checkMatchedAccount() == true){
                                //convert lead to new account with additions from matched account
                                executionLogsList.add('[INFO] Converting lead to new account with owner from matched account.');
                                acc = convertLeadToAccount(leadToConvert,uid,cname, true, false);
                            }else {
                                //convert leand to existing matched account
                                executionLogsList.add('[INFO] Converting lead to existing matched account.');
                                acc = convertLeadToAccount(leadToConvert,uid,cname, true, true);
                            }
                        } else{
                            // no account found, convert lead to new Account
                            executionLogsList.add('[INFO] No matched account found, converting lead to new Account.');
                            acc = convertLeadToAccount(leadToConvert,uid,cname, false, false);
                        }
                    }
                } else if(existingLead.size() > 0 && String.isBlank(leadCountry)){
                    throw new NoCountryFieldException('Lead country field is empty.');
                } else {
                    executionLogsList.add('[INFO] No Contact Or Lead found');
                    ConvesionMode cmEnum;
                    if(checkLeadAccountExists(websiteDomain, country) == true){
                        executionLogsList.add('[INFO] Matched account found: '+ matchedAccount.Id);
                        executionLogsList.add('[INFO] Check matched account status and opportunities.');
                        if(checkMatchedAccount() == true){
                            cmEnum = ConvesionMode.HASMATCHEDACTIVE;
                        }else{
                            cmEnum = ConvesionMode.COVERTTOMATCHED;
                        }
                    } else{
                        cmEnum = ConvesionMode.NEWACCOUNT;
                    }
                    acc = createAccountAndContact(cmEnum, acc, cname, Fname,  Lname,  email, industry, minEmployees, maxEmployees, websiteDomain, country);
                    // throw new NoContactOrLeadException('No Contact Or Lead found');
                }
            }
            return acc.Id;
        } catch(Exception ex){
            return ex.getMessage();
        }
    }

    private static Account createAccountAndContact(ConvesionMode modeEnum, Account acc, String cname, String Fname, String Lname, String email, String industry, String minEmployees, String maxEmployees, String websiteDomain, String country){

        switch on modeEnum {
            when NEWACCOUNT {
                //Create new Account and Contact
                executionLogsList.add('[INFO] No matched account found, creating new Account and Contact.');
                acc.Name = cname;
                acc.OwnerId = leadCaptureMappingByContactAttributeMap.get('ownerId').Fixed_Value__c;//OWNER_ID;
                acc.No_Touch_Account__c = true;
                acc.Employees_Min__c = minEmployees != null ? Integer.valueOf(minEmployees.trim()) : null;
                acc.Employees_Max__c = maxEmployees != null ? Integer.valueOf(maxEmployees.trim()) : null;
                acc.SW_Industry__c = industry;
                acc.Website = websiteDomain;
                acc.BillingCountryCode = !String.isBlank(country) ? country.trim().toUpperCase() : null;
                insert acc;
                executionLogsList.add('[INFO] Account created '+ acc.Id);
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.FirstName= Fname;
                con.LastName = Lname;
                con.Email =  email;
                con.OwnerId = leadCaptureMappingByContactAttributeMap.get('ownerId').Fixed_Value__c;//OWNER_ID;
                con.No_Touch_User__c  = true;
                con.MailingCountryCode = !String.isBlank(country) ? country.trim().toUpperCase() : null;
                insert con;
                cntId = con.Id;
                executionLogsList.add('[INFO] Contact created '+ con.Id);
            }
            when HASMATCHEDACTIVE{
                //Create new account with additions from matched account
                executionLogsList.add('[INFO] Create new account with additions from matched account.');
                acc = new Account(Name = cname, OwnerId = matchedAccount.OwnerId, No_Touch_Account__c = true, Employees_Min__c = minEmployees != null ? Integer.valueOf(minEmployees.trim()) : null, Employees_Max__c = maxEmployees != null ? Integer.valueOf(maxEmployees.trim()) : null, SW_Industry__c = industry, Website = websiteDomain);
//                acc.Name = cname;
//                acc.OwnerId = matchedAccount.OwnerId;
//                acc.No_Touch_Account__c = true;
//                acc.Employees_Min__c = minEmployees != null ? Integer.valueOf(minEmployees.trim()) : null;
//                acc.Employees_Max__c = maxEmployees != null ? Integer.valueOf(maxEmployees.trim()) : null;
//                acc.SW_Industry__c = industry;
//                acc.Website = websiteDomain;
                insert acc;
                executionLogsList.add('[INFO] Account created '+ acc.Id);
                Contact con = new Contact(AccountId = acc.Id, FirstName= Fname, LastName = Lname, Email =  email, OwnerId = matchedAccount.OwnerId, No_Touch_User__c  = true);
//                con.AccountId = acc.Id;
//                con.FirstName= Fname;
//                con.LastName = Lname;
//                con.Email =  email;
//                con.OwnerId = matchedAccount.OwnerId;
//                con.No_Touch_User__c  = true;
                insert con;
                executionLogsList.add('[INFO] Contact created '+ con.Id);
                sendNotificationEmail(TEMPLATE_HASMATCHEDACTIVE, matchedAccount.OwnerId, con.Id);
            }
            when COVERTTOMATCHED{
                //Create new contact to existing account
                executionLogsList.add('[INFO] Using matched account. Updating account No_Touch_Account__c,  Creating new contact for it.');
                Account acco = New Account(Id = matchedAccount.Id, No_Touch_Account__c  = true, Website = websiteDomain);
//                acc = matchedAccount;
//                acc.No_Touch_Account__c  = true;
//                acc.Website = websiteDomain;
                update acco;
                Contact con = new Contact(AccountId = acc.Id, FirstName= Fname, LastName = Lname, Email =  email, OwnerId = acc.OwnerId, No_Touch_User__c  = true);
//                con.AccountId = acc.Id;
//                con.FirstName= Fname;
//                con.LastName = Lname;
//                con.Email =  email;
//                con.OwnerId = acc.OwnerId;
//                con.No_Touch_User__c  = true;
                insert con;
                executionLogsList.add('[INFO] New Contact created '+ con.Id);
                sendNotificationEmail(TEMPLATE_COVERTTOMATCHED, matchedAccount.OwnerId, con.Id);
            }
        }
        return acc;
    }
    private static Boolean checkMatchedAccount(){
        List<Opportunity> openOppList = [SELECT Id FROM Opportunity WHERE AccountId=:matchedAccount.Id AND isClosed = false];
        if(matchedAccount.Status__c == 'Active' || matchedAccount.Status__c == 'Part Of Another Subscription' || openOppList.size() > 0){
            return true;
        } else{
            return false;
        }

    }

    private static Boolean checkLeadAccountExists(string websiteDomain, string country){
        if(Test.isRunningTest() == true ? true : String.isNotBlank(websiteDomain)){
            List<Account> accList = [SELECT Id, Status__c, Website_Domain__c, BillingCountry, OwnerId  FROM Account WHERE Website_Domain__c=:websiteDomain AND BillingCountry=:country];
            if(accList.size()>0){
                matchedAccount = accList[0];
                return true;
            }
        }
        return false;
    }

    private static Id setUpContactAccountOwnerId(string websiteDomain, string country){
        Id SalesforceAdminUserId;
        SalesforceAdminUserId = getSalesforceAdminUserId();
        if(Test.isRunningTest() == true ? true : String.isNotBlank(websiteDomain)){
            List<Account> accList = [SELECT Id, Status__c, Website_Domain__c, BillingCountry, OwnerId  FROM Account WHERE Website_Domain__c=:websiteDomain AND BillingCountry=:country AND (Status__c = 'Active' OR Status__c ='Cancelled' OR Status__c = 'Suspended' OR Number_of_Open_Opps__c > 0 OR Number_Of_Open_Meetings__c >0)];
            if(accList.size()>0){
                return accList[0].OwnerId;
            }
        }
        return SalesforceAdminUserId;
    }

    private static Id getSalesforceAdminUserId() {
        Id SalesforceAdminUserId;
        for (User u : [SELECT Id FROM USER WHERE Name = 'Salesforce Admin' LIMIT 1]) {
            SalesforceAdminUserId = u.Id;
        }
        return SalesforceAdminUserId;
    }


    static private List<Contact> genContactData (String email)
    {
        List <Contact> existingContactList = new List<Contact>();
        List <id> RecTypeToIgnore = new list <id>();
        RecTypeToIgnore = GenRecTypeIgnoreList();
        String domain = LeadTriggerHelperTEMP.getDomainFromEmail(email);
        String filter = '%'+domain+'%';
        existingContactList = [select id, CreatedDate, email,ownerid,LastName,recordtypeid,sw_industry__c,Employees_Min__c,Employees_Max__c,enrichment_source__c,MailingCountry,OtherCountry,Base_Product__c
        from Contact where email = :email AND recordtypeid not in: RecTypeToIgnore]; //email like : filter

        return existingContactList;
    }

    static private List<Lead> genLeadData (String email)
    {
        List <Lead> existingLeadList = new List<Lead>();
        List <id> RecTypeToIgnore = new list <id>();
        RecTypeToIgnore = GenRecTypeIgnoreList();
        String domain = LeadTriggerHelperTEMP.getDomainFromEmail(email);
        String filter = '%'+domain+'%';
        existingLeadList = [select id, reseller__c, CreatedDate, email,ownerid,status,country,AutoAlwaysActive__c,
                isConverted,company , LastName,business_unit__c,owner.isactive, Email_address_domain_type__c,
                CodeContactId__c,team__c,state,recordtypeid,sw_industry__c,Employees_Min__c,Employees_Max__c,Website,enrichment_source__c,Website_Domain__c
        from Lead where email = :email  and IsConverted=false and id!=null AND recordtypeid not in: RecTypeToIgnore];

        return existingLeadList;
    }

    static private Account convertLeadToAccount(Lead leadToConvert,string uid,string cname, Boolean hasMatchedAccount, Boolean convertToMatchedAccount){
        Account convertedAcc;
        Contact convertedContact;
        LeadStatus convertedStatus = getConvertLeadStatus();
        List<Database.LeadConvert> leadConversions = createLeadConversion(leadToConvert,convertedStatus, hasMatchedAccount, convertToMatchedAccount);
        AccountTriggerHelperTEMP.CodeOff= true;
        List<Database.LeadConvertResult> results = Database.convertLead(leadConversions);
        Database.LeadConvertResult lcr = results[0];
        if (lcr.isSuccess()) {
            convertedAcc = new Account (id=lcr.getAccountID());
            convertedContact = new Contact (id=lcr.getContactId());
            cntId = convertedContact.Id;
        } else {
            throw new LeadConvertFailedException('Lead convertation failed');
        }
        mergeLeadWithAccount(JSON.serialize(leadToConvert),JSON.serialize(convertedAcc),cname,uid, (hasMatchedAccount == true? (convertToMatchedAccount == false? true: false): false));
        attachContactToAccount(JSON.serialize(convertedContact), hasMatchedAccount, (convertToMatchedAccount?TEMPLATE_COVERTTOMATCHED:TEMPLATE_HASMATCHEDACTIVE), matchedAccount.OwnerId, convertedContact.Id);
        /* if(hasMatchedAccount == true){
             sendNotificationEmail((convertToMatchedAccount?TEMPLATE_COVERTTOMATCHED:TEMPLATE_HASMATCHEDACTIVE), matchedAccount.OwnerId, convertedContact.Id);
         }*/
        AccountTriggerHelperTEMP.CodeOff= false;
        return convertedAcc;
    }

    static private List<Database.LeadConvert> createLeadConversion(Lead l,LeadStatus convertedStatus, Boolean hasMatchedAccount, Boolean convertToMatchedAccount){
        Database.LeadConvert lc = new Database.LeadConvert();
        System.debug('l id - ' + l.Id);
        lc.setLeadId(l.id);
        if(convertToMatchedAccount == true){
            lc.setAccountId(matchedAccount.Id);
        }
        lc.setConvertedStatus(convertedStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(true);
        lc.setSendNotificationEmail(false);
        //System.debug('OWNER_ID - ' + OWNER_ID);
        Id userIdToSet;
        System.debug('l.ownerId: ' + l.ownerId);
        if(string.valueOf(l.ownerId).startsWith('00G')){
            userIdToSet = getSalesforceAdminUserId();
        }else{
            userIdToSet = l.ownerId;
        }
        System.debug('userIdToSet: ' + userIdToSet);
        System.debug('hasMatchedAccount: ' + hasMatchedAccount);
        lc.setOwnerId(hasMatchedAccount == false ? userIdToSet : matchedAccount.OwnerId);

        return new List<Database.LeadConvert>{lc};
    }

    static private LeadStatus getConvertLeadStatus(){

        CS_LeadConvert__c csconvertstatus = CS_LeadConvert__c.getinstance('LeadConvertStatus');
        LeadStatus convertStatus = null;

        if (csconvertstatus==null)
            convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        else
                convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true and MasterLabel=:csconvertstatus.value__c LIMIT 1];

        return convertStatus;
    }

    @future
    static private void mergeLeadWithAccount(String leadToConvertRaw,String convertedAccRaw,string uid,string cname, Boolean setParentAccount){
        Lead leadToConvert = (Lead)JSON.deserialize(leadToConvertRaw, Lead.class);
        Account convertedAcc = (Account)JSON.deserialize(convertedAccRaw, Account.class);
        convertedAcc.sw_industry__c = leadToConvert.sw_industry__c;
        convertedAcc.Employees_Min__c = leadToConvert.Employees_Min__c;
        convertedAcc.Employees_Max__c = leadToConvert.Employees_Max__c;
        convertedAcc.Website = leadToConvert.Website;
        convertedAcc.enrichment_source__c = leadToConvert.enrichment_source__c;
        convertedAcc.No_Touch_Account__c = true;
        if((leadToConvert.Email_address_domain_type__c == 'Private' || leadToConvert.Email_address_domain_type__c == 'Junk') &&
                (leadToConvert.Business_Unit__c == 'Strategic' || leadToConvert.Business_Unit__c == 'Enterprise')){
            convertedAcc.Website = 'no_website';
            convertedAcc.Name = 'No Touch Private ';
            convertedAcc.Name +=  String.isBlank(leadToConvert.FirstName) ? '' : leadToConvert.FirstName + ' ';
            convertedAcc.Name +=  String.isBlank(leadToConvert.LastName) ? '' : leadToConvert.LastName;
            convertedAcc.Name = convertedAcc.Name.trim();
            convertedAcc.Employees_Min__c = 1;
            convertedAcc.Employees_Max__c = 10;
            convertedAcc.Strategic_Region__c = null;
            convertedAcc.Business_Unit__c = 'Inside Sales';
        }
        if(setParentAccount == true){
            convertedAcc.ParentId = matchedAccount.Id;
        }
        AccountTriggerHelperTEMP.CodeOff= true;
        update convertedAcc;
        AccountTriggerHelperTEMP.CodeOff= false;
    }

    static private Account mergeContactToAccount(Contact contact,Account acc,string uid,string cname, String industry, String minEmployees, String maxEmployees, String websiteDomain, String country){
        acc.sw_industry__c = contact.sw_industry__c;
        acc.Employees_Min__c = minEmployees != null ? Integer.valueOf(minEmployees.trim()) : null;
        acc.Employees_Max__c = maxEmployees != null ? Integer.valueOf(maxEmployees.trim()) : null;
        acc.SW_Industry__c = industry;
        acc.enrichment_source__c = contact.enrichment_source__c;
        acc.Base_Product__c = contact.Base_Product__c;
        acc.No_Touch_Account__c = true;
        acc.Uid__c = uid;
        acc.Name = cname;
        acc.ownerId = setUpContactAccountOwnerId(websiteDomain, country);
        String billingcountry = String.isBlank(contact.MailingCountry) ? contact.OtherCountry : contact.MailingCountry;
        acc.BillingCountry = billingcountry;
        AccountTriggerHelperTEMP.CodeOff= true;
        acc.Website = websiteDomain;
        insert acc;
        AccountTriggerHelperTEMP.CodeOff= false;
        return acc;
    }
    @future
    static private void attachContactToAccount(String rawContact, Boolean sendEmail, String templateName, ID toId, ID  whatId){
        Contact contactToUpdate = (Contact)JSON.deserialize(rawContact, Contact.class);
        contactToUpdate.No_Touch_User__c =true;
        update contactToUpdate;
        if(sendEmail == true){
            sendNotificationEmail(templateName,toId, whatId);
        }
    }

    static private void attachContactToAccount(Contact contact,Account acc){
        contact.No_Touch_User__c =true;
        contact.AccountId = acc.Id;
        update contact;
    }

    static public void sendNotificationEmail(String templateName, ID toId, ID  whatId){
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:templateName];
        String ccAddress = [SELECT Email FROM User WHERE Id =: EMAIL_CC_RECIEVER].Email;
        System.debug(et);
        Messaging.SingleEmailMessage mail =  Messaging.renderStoredEmailTemplate(et.ID,toId, whatId);
        mail.setTargetObjectId((ID)toId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setCcAddresses(new List<String>{ccAddress});
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);

        try {
            if(!Test.isRunningTest()){
                Messaging.sendEmail(allmsg);
            }
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public static id[] GenRecTypeIgnoreList ()
    {
        list <id> RecTypeToIgnore = new list <id>();
        list <string> tempstring = label.Dedupe_IgnoreRecType.split(';');
        if (tempstring.size()>0) for (string s : tempstring) RecTypeToIgnore.add (id.valueof (s));
        system.debug('TESTING RecTypeToIgnore is '+RecTypeToIgnore);
        return RecTypeToIgnore;
    }

    public static void recordLog(Boolean status, String responce, String accountId){
        NoTouch_API_log__c log = new NoTouch_API_log__c();
        if(status == true){
            executionLogsList.add('[INFO] SUCCESS');
        } else {
            executionLogsList.add('[INFO] FAILED');
        }
        String params = '[INFO] Params recognized: ' +paramsObtained + '\n';
        String isSuccess = 'IsSuccessful: '+String.valueOf(status) + '\n';
        String logEvents = 'Execution log: \n' + String.join(executionLogsList, '\n');
        log.Execution_Log__c = isSuccess +'\n'+ params +'\n' + logEvents;
        log.hasException__c =  !status;
        log.ClassName__c = 'ZuoraAccountHandlerRest';
        log.Request_Date__c = DateTime.now();
        log.Request_Paramets__c = paramsObtained;
        log.Responce__c =  accountId; //Account Id
        log.Lead__c = leadId;
        log.Contact__c = cntId;
        log.jsonResponse__c = responce;
        insert log;
    }

    private static String logParams(string uid, string email, string cname, string Fname, String Lname, String country, String websiteDomain, String industry, String minEmployees, String maxEmployees){
        Map<String, String> paramsList = new Map<String, String>();
        paramsList.put('uid', uid);
        paramsList.put('email', email);
        paramsList.put('cname', cname);
        paramsList.put('Fname', Fname);
        paramsList.put('Lname', Lname);
        paramsList.put('country', !String.isBlank(country) ? country.trim().toUpperCase() : null);
        paramsList.put('websiteDomain', websiteDomain);
        paramsList.put('industry', industry);
        paramsList.put('minEmployees', minEmployees);
        paramsList.put('maxEmployees', maxEmployees);
        return JSON.serializePretty(paramsList);
    }


    private class NoEmailException extends Exception {}
    private class NoContactOrLeadException extends Exception {}
    private class NoCountryFieldException extends Exception {}
    private class LeadConvertFailedException extends Exception {}
}