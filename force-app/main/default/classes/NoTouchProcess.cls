/**
 * dupd by Alon.Shalev on 11/28/2023.
 */

/**
 * Created by Alon.Shalev on 11/20/2023.
 */

public with sharing class NoTouchProcess {

    private Contact contact;
    private Lead lead;
    private Account existingAccount;
    private Account dupAccount;
    private Account newAccount;
    private Account additionalAccount; // only for scenario 2 and 5
    private Id convertedAccountId;
    private Id convertedContactId;
    private String sfAdminId = getSfAdminId();
    public NoTouchObj noTouchObj;
    private static final String RECORDTYPE_NAME = 'Default';
    private  List<String> executionLogsList = new List<String>{};
    private  string paramsObtained = '';
    private boolean isPrivate = false;
    private String scenario;
    private String cleanDomain;
    private String emailAddress;
    public Integer numberOfRetries;
    public boolean retryNeeded = false;

    public String handleNoTouch(String uid, String email, string cname, string fName, String lName, String country, String websiteDomain, String industry, String minEmployees, String maxEmployees,String NT_Subscription_FirstCharge_Date,Integer retryCounter){
        this.numberOfRetries = retryCounter;
        try{
            if(String.isBlank(email)){
                throw new NoTouchProcessException('no email in the call');
            }
            this.emailAddress = email;
            System.debug('email---'+email);
            paramsObtained = logParams(uid, email, cname, Fname, Lname, country, websiteDomain, industry, minEmployees, maxEmployees,NT_Subscription_FirstCharge_Date);
            fillNoTouchObj(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,NT_Subscription_FirstCharge_Date != null ? Date.valueOf(NT_Subscription_FirstCharge_Date) : null);
            calculateIsPrivate();
            searchContact(email);
            if(this.contact != null){
                this.cleanDomain = this.contact.Clean_Domain__c;
                return contactWasFoundLogic();
            }
            executionLogsList.add('no contact was found .. searching for lead with email:  '+email);
            System.debug('no contact was found .. searching for lead with email:  '+email);
            searchLead(email);
            if(this.lead != null){
                this.cleanDomain = this.lead.Clean_Domain__c;
                return leadWasFoundLogic(country, websiteDomain); // 'Scenario 3'; , 'Scenario 4'; , 'Scenario 7'; , 'Scenario 5';
            }else{
                executionLogsList.add('no lead and no contact found...that is wierd but im creating new ones');
                return createNewContactAndAccount(); //'Scenario 8';
//                throw new NoTouchProcessException('no lead and no contact found...that is wierd');
            }
        }catch (Exception ex){
            System.debug('ex.getMsg--'+ex.getMessage());
            System.debug('ex.getStackTraceString--'+ex.getStackTraceString());
            executionLogsList.add('ex.getMsg--'+ex.getMessage());
            executionLogsList.add('ex.getStackTraceString--'+ex.getStackTraceString());
            return ex.getMessage();
        }

    }

    private String createNewContactAndAccount(){
        Savepoint sp = Database.setSavepoint();
        executionLogsList.add('Scenario 8  No matched Lead found');
        try{
            this.scenario = 'Scenario 8';
            executionLogsList.add('creating new Account');
            this.newAccount = new Account();
            this.newAccount.Employees_Min__c = this.noTouchObj.minEmployees != null ?  Decimal.valueOf(this.noTouchObj.minEmployees) : null;
            this.newAccount.Employees_Max__c = this.noTouchObj.maxEmployees != null ?  Decimal.valueOf(this.noTouchObj.maxEmployees) : null;
            this.newAccount.Name = this.isPrivate ? 'Private Account - '+this.noTouchObj.fName +' '+this.noTouchObj.lName : this.noTouchObj.websiteDomain + ' - No Touch';
            this.newAccount.NT_CC_Holder_Name__c = this.isPrivate ? 'Private Account - '+this.noTouchObj.fName +' '+this.noTouchObj.lName : null ;
            this.newAccount.Website = this.noTouchObj.websiteDomain;
            this.newAccount.Industry = this.noTouchObj.industry;
            this.newAccount.BillingCountryCode = this.noTouchObj.country;
            this.newAccount.No_Touch_Account__c = true;
            this.newAccount.Exclude_From_Territory_Owner_Change__c = true;
            this.newAccount.NT_BU_override_one_time__c = this.isPrivate;
            this.newAccount.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
            this.newAccount.NT_Scenario__c = this.scenario;
            System.debug('this.newAccount----'+this.newAccount);
            System.debug('this.newAccount----'+this.newAccount.Name);
            insert this.newAccount;
            executionLogsList.add('new Account created  '+this.newAccount.Id+'  '+this.newAccount.Name);
            executionLogsList.add('creating new Contact');
            this.contact = new Contact();
            System.debug('this noTouchObj---'+noTouchObj);
            this.contact.LastName = this.noTouchObj.lName;
            this.contact.FirstName = this.noTouchObj.fName;
            this.contact.Email = this.noTouchObj.email;
            this.contact.AccountId = this.newAccount.Id;
            this.contact.No_Touch_User__c = true;
            insert this.contact;
            executionLogsList.add('new Contact created  '+this.contact.Id+'  '+this.contact.Name);
        }catch (Exception ex){
            Database.rollback(sp);
            this.numberOfRetries  ++;
            System.debug('ERROR: ' + ex.getMessage());
            executionLogsList.add('the process rolledBack error happened in the middle, number of retries :  '+this.numberOfRetries );
            executionLogsList.add(ex.getMessage());
            if(this.numberOfRetries < 3){ // todo:think of a number and maybe catch the specific exception
                this.retryNeeded = true;
            }
            return '';
        }
        return this.newAccount.Id;
    }

    private void calculateIsPrivate(){
        String domain = this.noTouchObj.email.substringAfter('@').trim();
        List<EmailDomain__c> emailDomains = [SELECT Name, RecordType.DeveloperName FROM EmailDomain__c WHERE Name = :domain];
        System.debug('emailDomains--'+emailDomains);
        this.isPrivate = emailDomains.isEmpty() ? false : emailDomains[0].RecordType.DeveloperName == 'Free'  ? true : false;
        System.debug('this is private ?? '+this.isPrivate);
    }

    private String leadWasFoundLogic(String country, String websiteDomain) {
        executionLogsList.add('lead was found :' + this.lead.Id);
        System.debug('lead was found :' + this.lead);
        System.debug('searching for existing account with billingCountry = ' + country + ' and websiteDomain = ' + websiteDomain);
        if(this.isPrivate) {
            leadIsPrivateLogic(); // 'Scenario 7';
        }else{
            executionLogsList.add('lead is non-private searching for existing account');
            country = String.isNotBlank(country) ? country : this.lead.CountryCode;
            websiteDomain = String.isNotBlank(websiteDomain) && websiteDomain != 'no_website' ? websiteDomain : this.lead.Website_Domain__c;
            if(String.isBlank(websiteDomain) || String.isBlank(country)){
                executionLogsList.add('the country or website is blank switching to scenario 8 ');
                return createNewContactAndAccount(); // 'Scenario 8';
            }
            searchAccount(country, websiteDomain);
            executionLogsList.add('searching for existing account with billingCountry = ' + country + ' and websiteDomain = ' + websiteDomain);
            if (this.existingAccount != null) {
                accountFoundLogic(); // 'Scenario 5'; , 'Scenario 4';
            } else {
                accountWasNotFoundLogic();
            }
        }
        return this.convertedAccountId;
    }

    private void accountWasNotFoundLogic() {
        executionLogsList.add('Scenario 3 (Lead Non-Private): No matched Account found');
        this.scenario = 'Scenario 3';
        executionLogsList.add('no account was found converting lead to new account');
        System.debug('no account was found converting lead to new account');
        convertLeadToNewAccount();
        this.newAccount = new Account(Id = this.convertedAccountId);
        this.newAccount.Name = this.cleanDomain+  ' - No Touch';
        this.newAccount.No_Touch_Account__c = true;
        this.newAccount.Exclude_From_Territory_Owner_Change__c = true;
        this.newAccount.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        this.newAccount.NT_Scenario__c = this.scenario;
        this.newAccount.SW_Industry__c = this.noTouchObj.industry;
        this.newAccount.Website = String.isNotBlank(this.noTouchObj.websiteDomain) ? this.noTouchObj.websiteDomain : this.lead.Website;
        this.newAccount.Employees_Max__c = String.isNotBlank(this.noTouchObj.maxEmployees) ? Decimal.valueOf(this.noTouchObj.maxEmployees) : this.lead.Employees_Max__c;
        this.newAccount.Employees_Min__c = String.isNotBlank(this.noTouchObj.minEmployees) ? Decimal.valueOf(this.noTouchObj.minEmployees) : this.lead.Employees_Min__c;

        update this.newAccount;
        executionLogsList.add('the account was  created--' + this.convertedAccountId);
        System.debug('the account was  created--' + this.convertedAccountId);
    }

    private void accountFoundLogic() {
        executionLogsList.add('account found--' + this.existingAccount.Id);
        executionLogsList.add('this account status is : ' + this.existingAccount.Status__c);
        System.debug('account found--' + this.existingAccount);
        System.debug('this account status is : ' + this.existingAccount.Status__c);
        if (this.existingAccount.Status__c == 'Active') {
            accountFoundStatusActiveLogic(); // 'Scenario 4'
        } else {
            accountFoundStatusNotActiveLogic(); // 'Scenario 5';
        }
    }

    private void accountFoundStatusNotActiveLogic() {
        executionLogsList.add('Scenario 5 (Lead Non-Private): Matched Account found & Account non-active');
        this.scenario = 'Scenario 5';
        if (String.isNotBlank(this.existingAccount.Strategic_Pod__c)) {
            executionLogsList.add('the existing account business unit equals "Strategic" switching to scenario 4');
            accountFoundStatusActiveLogic();
            return;
        }
        executionLogsList.add('the account status is not active so im converting the lead to the existing account : ' + this.existingAccount.Id);
        System.debug('the account status is not active so im converting the lead to the existing account : ' + this.existingAccount);
        convertLeadToExistingAccount();
    }

    private void accountFoundStatusActiveLogic() {
        executionLogsList.add('Scenario 4 ( Lead Non-Private): Matched Account found & Account active');
        this.scenario = 'Scenario 4';
        executionLogsList.add('this account status is active so im converting the lead into a duplicate account');
        System.debug('this account status is active so im converting the lead into a duplicate account');
        convertLeadToExistingAccountAfterClone();
        executionLogsList.add('the duplicate account is :--' + this.dupAccount.Id);
        System.debug('the duplicate account is :--' + this.dupAccount);
    }

    private void leadIsPrivateLogic() {
        executionLogsList.add('Scenario 7 (Lead Private): Matched Lead found');
        this.scenario = 'Scenario 7';
        executionLogsList.add('lead is private creating new account with leadInfo');
        convertLeadToNewAccount();
        this.newAccount = new Account(Id = this.convertedAccountId);
        updateNewAccount(this.newAccount);
        this.newAccount.NT_BU_override_one_time__c = true;
        update this.newAccount;
    }

    private void updateNewAccount(Account account) {
        account.Name = 'Private Account - ' + this.noTouchObj.websiteDomain;
        account.NT_CC_Holder_Name__c = 'Private Account - ' + this.noTouchObj.fName + ' '+this.noTouchObj.lName;
//        account.Website = 'no_website';
//        account.Employees_Min__c = 1;
//        account.Employees_Max__c = 10;
        account.Website = this.noTouchObj.websiteDomain;
        account.Employees_Min__c = this.noTouchObj.minEmployees != null ? Decimal.valueOf(this.noTouchObj.minEmployees) : null;
        account.Employees_Max__c = this.noTouchObj.maxEmployees != null ? Decimal.valueOf(this.noTouchObj.maxEmployees) : null;
        account.SW_Industry__c = this.noTouchObj.Industry;
        account.BillingCountryCode = this.noTouchObj.country;
        account.NT_master_website__c = this.noTouchObj.websiteDomain;
        account.EmployeesMax_registration__c = this.noTouchObj.maxEmployees != null ? Decimal.valueOf(this.noTouchObj.maxEmployees) : null;
        account.EmployeesMin_registration__c = this.noTouchObj.minEmployees != null ?  Decimal.valueOf(this.noTouchObj.minEmployees) : null;
        account.No_Touch_Account__c = true;
        account.Exclude_From_Territory_Owner_Change__c = true;
        account.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        account.NT_Scenario__c = this.scenario;
    }

    private String contactWasFoundLogic() {
        executionLogsList.add('found a contact --' + this.contact.id+' - '+this.contact.Name);
        System.debug('found a contact --' + this.contact);
        queryExistingAccountWithAllInfo(this.contact.AccountId);
        if(this.isPrivate){
            return contactIsPrivateLogic();
        }
        executionLogsList.add('this contact account status is-- ' + this.contact.Account.Status__c);
        System.debug('this contact account status is-- ' + this.contact.Account.Status__c);
        if(this.contact.Account.Website_Domain__c == 'no_website' || String.isBlank(this.contact.Account.Website_Domain__c)){
            return createNewContactAndAccount(); // 'Scenario 8';
        }
        if (this.contact.Account.Status__c == 'Active') {
            return contactAccountActiveLogic(); // Scenario 1';
        } else {
            return contactAccountStatusNotActiveLogic(); // 'Scenario 2';
        }
    }

    private String contactAccountStatusNotActiveLogic() {
        executionLogsList.add('Scenario 2 (Contact Non-Private): Matched Contact found & Account non-active');
        this.scenario = 'Scenario 2';
        if (String.isNotBlank(this.existingAccount.Strategic_Pod__c)) {
            executionLogsList.add('the existing account business unit equals "Strategic" switching to scenario 1');
            return contactAccountActiveLogic();
        }
        executionLogsList.add('account status is not active updating account info from noTouchObj');
        System.debug('account status is not active updating account info from noTouchObj');
        updateAccountInfo();
        this.contact.No_Touch_User__c = true;
        this.contact.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        update this.contact;
        executionLogsList.add('account updated--');
        System.debug('account updated--' + this.existingAccount);
        return existingAccount.Id;
    }

    private String contactAccountActiveLogic() {
        executionLogsList.add('Scenario 1 (Contact Non-Private): Matched Contact found & Account active');
        this.scenario = 'Scenario 1';
        System.debug('account status is active creating dupAccount');
        executionLogsList.add('account status is active creating dupAccount');
        createDupAccount(String.isNotBlank(this.contact.Department__c) ?  ' - '+this.contact.Department__c : '' );
        this.contact.AccountId = this.dupAccount.Id;
        this.contact.No_Touch_User__c = true;
        this.contact.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        update this.contact;
        executionLogsList.add('dupAccount created--' + this.dupAccount.id + ' - ' + this.dupAccount.Name);
        System.debug('dupAccount created--' + this.dupAccount);
        return dupAccount.Id;
    }

    private String contactIsPrivateLogic() {
        executionLogsList.add('Scenario 6 (Contact Private): Matched Contact found');
        this.scenario = 'Scenario 6';
        this.newAccount = new Account();
        updateNewAccount(this.newAccount);
        this.newAccount.NT_BU_override_one_time__c = true;
        insert this.newAccount;
        executionLogsList.add('created new account ' + this.newAccount.id);
        this.contact.AccountId = this.newAccount.Id;
        this.contact.No_Touch_User__c = true;
        this.contact.Employees_Min__c = 1;
        this.contact.Employees_Max__c = 10;
        this.contact.MailingCountryCode = this.noTouchObj.country;
        this.contact.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        update this.contact;
        return newAccount.id;
    }

    private void fillNoTouchObj(String uid, String email, String cname, String fName, String lName, String country, String websiteDomain, String industry, String minEmployees, String maxEmployees,Date NT_Subscription_FirstCharge_Date) {
        this.noTouchObj = new NoTouchObj();
        this.noTouchObj.uid = uid;
        this.noTouchObj.email = email;
        this.noTouchObj.cname = cname;
        this.noTouchObj.fname = fName;
        this.noTouchObj.lname = lName;
        this.noTouchObj.country = country;
        this.noTouchObj.websiteDomain = websiteDomain;
        this.noTouchObj.industry = industry;
        this.noTouchObj.minEmployees = minEmployees;
        this.noTouchObj.maxEmployees = maxEmployees;
        this.noTouchObj.NT_Subscription_FirstCharge_Date = NT_Subscription_FirstCharge_Date;
    }

    private void createDupAccount(String department){
        this.dupAccount = this.existingAccount.clone(false,false,false,false);
        this.dupAccount.Name = this.existingAccount.Name.contains('No Touch') ? this.existingAccount.Name  : this.existingAccount.Name+ ' - No Touch';
        String websiteForName = String.isNotBlank(this.noTouchObj.websiteDomain) ? this.noTouchObj.websiteDomain : this.existingAccount.Website_Domain__c;
        this.dupAccount.Name = this.existingAccount.Business_Unit__c == 'Strategic' ? websiteForName + ' - No Touch' + department : this.dupAccount.Name;
        this.dupAccount.Top_Level_Parent__c = false;
        this.dupAccount.OwnerId =  this.existingAccount.OwnerId;
        this.dupAccount.No_Touch_Account__c = true;
        this.dupAccount.Exclude_From_Territory_Owner_Change__c = true;
        this.dupAccount.Named_Sales_Manager__c = this.existingAccount.OwnerId;
        this.dupAccount.ParentId = this.existingAccount.Id;
        this.dupAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RECORDTYPE_NAME).getRecordTypeId();
        this.dupAccount.Parent_Company_Domain__c = this.existingAccount.Parent_Company_Domain__c;
        this.dupAccount.Parent_Company_HQ_Country__c = this.existingAccount.Parent_Company_HQ_Country__c;
        this.dupAccount.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        this.dupAccount.NT_Scenario__c = this.scenario;
        insert this.dupAccount;
    }

    private String getSfAdminId(){
        List<User> salesforceAdminUserList = [SELECT Id FROM User WHERE Name = 'Salesforce Admin'];

        return salesforceAdminUserList.isEmpty() ? null : salesforceAdminUserList[0].Id;
    }

    private void updateAccountInfo(){
        this.existingAccount.Name = this.cleanDomain + ' - No Touch';
        this.existingAccount.No_Touch_Account__c = true;
        this.existingAccount.Exclude_From_Territory_Owner_Change__c = true;
        this.existingAccount.Employees_Max__c = this.existingAccount.Employees_Max__c == null  ? this.noTouchObj.maxEmployees != null ?  Decimal.valueOf(this.noTouchObj.maxEmployees) : null : this.existingAccount.Employees_Max__c;
        this.existingAccount.Employees_Min__c = this.existingAccount.Employees_Min__c == null  ?this.noTouchObj.minEmployees != null ?  Decimal.valueOf(this.noTouchObj.minEmployees) : null : this.existingAccount.Employees_Min__c;
//        this.existingAccount.Industry = this.existingAccount.Industry == null  ?  this.noTouchObj.industry : this.existingAccount.Industry;
        this.existingAccount.SW_Industry__c = this.existingAccount.SW_Industry__c == null  ?  this.noTouchObj.industry : this.existingAccount.SW_Industry__c;
        this.existingAccount.Website = this.existingAccount.Website == null  ?  this.noTouchObj.websiteDomain : this.existingAccount.Website;
        this.existingAccount.BillingCountryCode = this.existingAccount.BillingCountryCode == null  ?  this.noTouchObj.country : this.existingAccount.BillingCountryCode;
        this.existingAccount.Company_Name_2__c = this.existingAccount.Company_Name_2__c == null  ?  this.noTouchObj.cname : this.existingAccount.Company_Name_2__c;
        this.existingAccount.NT_Subscription_FirstCharge_Date__c = this.existingAccount.NT_Subscription_FirstCharge_Date__c == null ? this.noTouchObj.NT_Subscription_FirstCharge_Date : this.existingAccount.NT_Subscription_FirstCharge_Date__c;
        this.existingAccount.NT_Scenario__c = this.scenario;
        update this.existingAccount;
    }

    private void convertLeadToExistingAccountAfterClone(){
        createDupAccount(String.isNotBlank(this.lead.Department__c) ? ' - '+this.lead.Department__c : '');
        convertLead(this.dupAccount.Id);
        this.contact = new Contact(Id = this.convertedContactId);
        this.contact.AccountId = this.dupAccount.Id;
        this.contact.No_Touch_User__c = true;
        this.contact.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        update this.contact;

    }
    private void convertLeadToExistingAccount(){
        convertLead(this.existingAccount.Id);
        updateAccountInfo();
        this.contact = new Contact(Id = this.convertedContactId);
        this.contact.AccountId = this.existingAccount.Id;
        this.contact.No_Touch_User__c = true;
        this.contact.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        update this.contact;
    }
    private void convertLeadToNewAccount(){
        convertLead(null);
        this.contact = new Contact(Id = this.convertedContactId);
        this.contact.AccountId = this.convertedAccountId;
        this.contact.No_Touch_User__c = true;
        this.contact.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;
        update this.contact;
    }

    private void convertLead(String accountIdToConvertTo){
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(this.lead.Id);
        LeadStatus convertedStatus = getConvertLeadStatus();
        lc.setConvertedStatus(convertedStatus.MasterLabel);
        if(String.isNotBlank(accountIdToConvertTo)){
            lc.setAccountId(accountIdToConvertTo);
        }
        Id userIdToSet = this.lead.OwnerId;
        if(string.valueOf(this.lead.ownerId).startsWith('00G')){
            userIdToSet = this.sfAdminId;
        }
        lc.setOwnerId(userIdToSet);
        lc.setDoNotCreateOpportunity(true);
        lc.setSendNotificationEmail(false);
        List<Database.LeadConvertResult> results = Database.convertLead(new List<Database.LeadConvert>{lc});
        Database.LeadConvertResult lcr = results[0];
        if (!lcr.isSuccess()) {
            throw new NoTouchProcessException('Lead convertation failed');
        }
        this.convertedAccountId = lcr.getAccountId();
        this.convertedContactId = lcr.getContactId();
    }
    private LeadStatus getConvertLeadStatus(){


        LeadStatus convertStatus = null;
        CS_LeadConvert__c leadConvertSettings = CS_LeadConvert__c.getinstance('LeadConvertStatus');
        if(leadConvertSettings == null){
            convertStatus = [SELECT Id, MasterLabel
            FROM LeadStatus
            WHERE IsConverted = TRUE LIMIT 1];

        }else{
            convertStatus = [SELECT Id, MasterLabel
            FROM LeadStatus
            WHERE IsConverted = TRUE
            AND MasterLabel =: leadConvertSettings.value__c LIMIT 1];
        }

        return convertStatus;
    }

    private void queryExistingAccountWithAllInfo(String existingAccountId){
        List<String> fieldSet = GeneralUtil.getFieldSet('Account','NoTouchProcess_Account_fields');
        if(fieldSet == null){
            throw new NoTouchProcessException('field Set NoTouchProcess_Account_fields does not exist');
        }

        String fieldsFromFieldsSet = String.join(fieldSet,',');
        String query = 'SELECT Id,OwnerId,Name,ARR__c,Strategic_Pod__c,Stage__c,Website_Domain__c,Parent_Company_Domain__c,No_Touch_Account__c,Owner.Name,Parent_Company_HQ_Country__c,NT_Subscription_FirstCharge_Date__c, ';
        query += fieldsFromFieldsSet;
        query += ' FROM Account';
        query += ' WHERE Id =: existingAccountId';
        List<Account> accList = Database.query(query);

        this.existingAccount = accList.isEmpty() ? null : accList[0];

    }

    private void searchAccount(String country , String webSiteDomain){
        List<String> fieldSet = GeneralUtil.getFieldSet('Account','NoTouchProcess_Account_fields');
        if(fieldSet == null){
            throw new NoTouchProcessException('field Set NoTouchProcess_Account_fields does not exist');
        }

        String fieldsFromFieldsSet = String.join(fieldSet,',');
        String query = 'SELECT Id,OwnerId,Name,ARR__c,Strategic_Pod__c,Stage__c,Website_Domain__c,Parent_Company_Domain__c,No_Touch_Account__c,Owner.Name,Parent_Company_HQ_Country__c,NT_Subscription_FirstCharge_Date__c, ';
        query += fieldsFromFieldsSet;
        query += ' FROM Account';
        query += ' WHERE Website_Domain__c =: websiteDomain';
        query += ' AND (BillingCountry =: country OR BillingCountryCode =: country)';
        query += ' AND RecordType.Name = :RECORDTYPE_NAME';
        List<Account> accList = Database.query(query);
//        List<Account> accList = [SELECT Id, Status__c, Website, BillingCountry, OwnerId
//                                FROM Account
//                                WHERE Website_Domain__c =: websiteDomain
//                                AND BillingCountry =: country
//                                AND RecordType.DeveloperName = :RECORDTYPE_NAME];
        boolean notActiveIsFound = false;
        for(Account existingAccount : accList){
            if(existingAccount.Status__c != 'Active') {
                this.existingAccount = existingAccount;
                notActiveIsFound = true;
            }else{
                if(!notActiveIsFound){
                    this.existingAccount = existingAccount;
                }else if(existingAccount.No_Touch_Account__c == false){
                    this.additionalAccount = existingAccount;
                }
            }
        }
    }

    private void searchLead(String email){
        List<Lead> existingLeadList =  [SELECT id, reseller__c, CreatedDate, email,ownerid,status,country,AutoAlwaysActive__c,
                isConverted,company , LastName,business_unit__c,owner.isactive, Email_address_domain_type__c,Name,Clean_Domain__c,Department__c,
                CodeContactId__c,team__c,state,recordtypeid,sw_industry__c,Employees_Min__c,Employees_Max__c,Website,enrichment_source__c,Website_Domain__c,Industry,CountryCode
        FROM Lead
        WHERE email = :email
        AND IsConverted = FALSE
        AND recordtype.DeveloperName = : RECORDTYPE_NAME];
        this.lead = existingLeadList.isEmpty() ? null : existingLeadList[0];

    }

    private void searchContact(String email){
        List<Contact> existingContactList = [SELECT Id,CreatedDate, email,ownerid,LastName,recordtypeid,sw_industry__c,Employees_Min__c,Employees_Max__c,Name,Account.Name,Clean_Domain__c,
                enrichment_source__c,MailingCountry,OtherCountry,Account.Status__c,AccountId,Department__c,Account.Website_Domain__c
        FROM Contact
        WHERE Email = :email
        AND recordtype.DeveloperName = :RECORDTYPE_NAME];
        this.contact =  existingContactList.isEmpty() ? null : existingContactList[0];
    }

    private static String logParams(string uid, string email, string cname, string Fname, String Lname, String country, String websiteDomain, String industry, String minEmployees, String maxEmployees,String NT_Subscription_FirstCharge_Date){
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
        paramsList.put('NT_Subscription_FirstCharge_Date',NT_Subscription_FirstCharge_Date);
        return JSON.serializePretty(paramsList);
    }

    public void recordLog(Boolean status, String response, String accountId){
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
        log.ClassName__c = 'the new NoTouchProcess';
        log.Request_Date__c = DateTime.now();
        log.Request_Paramets__c = paramsObtained;
        log.Responce__c =  accountId; //Account Id
        log.Lead__c = this.lead != null ? this.lead.Id : null;
        log.Contact__c = this.contact != null ? this.contact.Id : null;
        log.jsonResponse__c = trimObjectValue(log,response,'jsonResponse__c');
        log.Email__c = this.emailAddress != null ? this.emailAddress : ' no email was provide the process failed';
        if(this.noTouchObj != null){
            log.Country__c = this.noTouchObj.country;
            log.Industry__c = this.noTouchObj.industry;
            log.MaxEmployees__c = this.noTouchObj.maxEmployees;
            log.minEmployees__c = this.noTouchObj.minEmployees;
            log.websiteDomain__c = this.noTouchObj.websiteDomain;
        }
        log.Matched_Account__c = this.existingAccount != null ? this.existingAccount.Id : null;
        log.Matched_Account_Name__c = this.existingAccount != null ? this.existingAccount.Id : null;
        log.Matched_Account_Stage__c = this.existingAccount != null ? this.existingAccount.Stage__c : null;
        log.Matched_Account_Arr__c = this.existingAccount != null ? this.existingAccount.ARR__c : null;
        log.Matched_Account_Base_Product__c = this.existingAccount != null ? this.existingAccount.Base_Product__c : null;
        log.Matched_Account_Country__c = this.existingAccount != null ? this.existingAccount.BillingCountryCode : null;
        log.Matched_Account_OwnerName__c = this.existingAccount != null ? this.existingAccount.Owner.Name : null;
        log.Matched_Account_Strategic_Pod__c = this.existingAccount != null ? this.existingAccount.Strategic_Pod__c : null;
        log.Additional_Account_Country__c = this.additionalAccount != null ? this.additionalAccount.BillingCountryCode : null;
        log.Additional_Account_OwnerName__c = this.additionalAccount != null ? this.additionalAccount.Owner.Name : null;
        log.Additional_Account_Stage__c = this.additionalAccount != null ? this.additionalAccount.Stage__c : null;
        log.Additional_Account__c = this.additionalAccount != null ? this.additionalAccount.Id : null;
        log.Additional_Account_Arr__c = this.additionalAccount != null ? this.additionalAccount.ARR__c : null;
        log.Additional_Account_Base_Product__c = this.additionalAccount != null ? this.additionalAccount.Base_Product__c : null;
        log.Additional_Account_Strategic_Pod__c = this.additionalAccount != null ? this.additionalAccount.Strategic_Pod__c : null;
        log.scenario__c = this.scenario;
        log.NT_Subscription_FirstCharge_Date__c = this.noTouchObj.NT_Subscription_FirstCharge_Date;

        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> responseMap = (Map<String, Object>) jsonMap.get('response');
        String logId = (String) responseMap.get('logId');

        if (String.isNotBlank(logId)) {
            log.Id = logId;
        }

        upsert log;
    }

    private static String trimObjectValue(NoTouch_API_log__c notouch,String fieldValueBefore , String fieldName){
        String afterTrimValue = '';
        Schema.SObjectType sobjectType = notouch.getSObjectType();
        System.debug('sobjectType--'+sobjectType);
        String objectName = sobjectType.getDescribe().getName();
        System.debug('objectName--'+objectName);
        DescribeSObjectResult objResult = Schema.getGlobalDescribe()
                .get(objectName).getDescribe();
        System.debug('objResult--'+objResult);


        DescribeFieldResult fieldResult = objResult.fields.getMap()
                .get(fieldName).getDescribe();
        System.debug('fieldResult.getType()--'+fieldResult.getType());
        if(fieldResult.getType() == DisplayType.STRING || fieldResult.getType() == DisplayType.TEXTAREA){
            System.debug('i am here');
            String originalValue = String.valueOf(fieldValueBefore);
            if(fieldResult.getLength() < originalValue.length()){
                System.debug('removing data');
                // removing data
                afterTrimValue = originalValue.substring(0,fieldResult.getLength());
                System.debug('fieldValueBefore--'+fieldValueBefore);
            }
        }
        return afterTrimValue;
    }


//    public void updateAccountWhenNoTouchFieldChange(List<Contact> newList , Map<Id,Contact> oldMap){// MIS-4614
//        List<String> fieldSet = GeneralUtil.getFieldSet('Contact','NoTouchProcess_Contact_fields');
//        System.debug('fieldSet--'+fieldSet);
//        Set<Id> accountIdSet = new Set<Id>();
//        List<Account> accountToUpdateList = new List<Account>();
//        List<Contact> contactChangedList = new List<Contact>();
//        for(Contact conItem : newList){
//            System.debug('conItem--'+conItem.id);
//            if(String.isNotBlank(conItem.AccountId)){
//                for(String fieldName : fieldSet){
//                    System.debug('fieldName--'+fieldName);
//                    System.debug(conItem.get(fieldName)+'  this is the new field value');
//                    if(conItem.get(fieldName) != oldMap.get(conItem.Id).get(fieldName)){
//                        System.debug('fieldName--'+fieldName);
//                        System.debug('conItem.get(fieldName--'+conItem.get(fieldName));
//                        contactChangedList.add(conItem);
//                        accountIdSet.add(conItem.AccountId);
//                        break;
//                    }
//                }
//            }
//        }
//        if(!contactChangedList.isEmpty()){
//            Map<Id,Account> accountToUpdateMap = new Map<Id, Account>([SELECT Id
//                                                                    FROM Account
//                                                                    WHERE Id IN: accountIdSet]);
//
//            for(Contact contactChanged : contactChangedList){
//                Account accountToChange = accountToUpdateMap.get(contactChanged.AccountId);
//                String accountFieldName;
//                for(String fieldName : fieldSet){
//                    accountFieldName = fieldName;
//                    if(fieldName == 'website__c'){
//                        accountFieldName = 'Website';
//                    }
////                    if(fieldName == 'industry'){
////                        accountFieldName = 'sw_industry__c';   wierd part
////                    }
//                    System.debug('fieldName accoun --'+accountFieldName); // todo : fix Website -> website__c
//                    System.debug('contactChanged.get(fieldName)--'+contactChanged.get(fieldName));
//                    accountToChange.put(accountFieldName,contactChanged.get(fieldName));
//                }
//                accountToUpdateList.add(accountToChange);
//            }
//            System.debug('accountToUpdateList--'+accountToUpdateList);
//            update accountToUpdateList;
//        }
//    }

    private class NoTouchProcessException extends Exception{}

    public class  NoTouchObj {
        public String uid;
        public String email;
        public String cname;
        public String fName;
        public String lName;
        public String country;
        public String websiteDomain;
        public String industry;
        public String minEmployees;
        public String maxEmployees;
        public Date NT_Subscription_FirstCharge_Date;
    }


}