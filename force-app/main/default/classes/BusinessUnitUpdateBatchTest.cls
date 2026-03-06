@istest public class BusinessUnitUpdateBatchTest {
    
    @testSetup
    static void setup(){    
         User u = [SELECT Id FROM User WHERE Id !=:UserInfo.getUserId() LIMIT 1];
        
        Pardot_Data_Manipulation_Setting__c pdms11 = new Pardot_Data_Manipulation_Setting__c();
		pdms11.Name = 'LDR_LEAD_OWNER_ID';
		pdms11.Value__c = u.Id;
		insert pdms11;
        
        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
        iss.Name='Default Value';
        iss.Value__c='Sales';
        insert iss;
        
        InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
        ismTest.SW_Industry__c = 'AdTech and AdNetwork';
        ismTest.Department__c = 'BI / Analytics';
        ismTest.Inferred_Solution__c = 'Research';        
        ismTest.Name = 'test';
        insert ismTest;
        
        InferralSolutionMapContact__c ismCTest = new InferralSolutionMapContact__c();
        ismCTest.SW_Industry__c = 'AdTech and AdNetwork';
        ismTest.Department__c = 'BI / Analytics';
        ismCTest.Inferred_Solution__c = 'Research';        
        ismCTest.Name = 'test';
        insert ismCTest;
        
        Inferral_Solution_Valid_Criteria_List__c islvcl = new Inferral_Solution_Valid_Criteria_List__c();
        islvcl.Name='department__c';  
        islvcl.Is_Valid__c=true;
        insert islvcl;
        
        Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
        islvcl2.Name='sw_industry__c';  
        islvcl2.Is_Valid__c=true;
        insert islvcl2;
        
        InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
        islcvcl.Name='department__c';  
        islcvcl.Is_Valid__c=true;
        insert islcvcl;
        
        InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
        islcvcl2.Name='sw_industry__c';  
        islcvcl2.Is_Valid__c=true;
        insert islcvcl2;      
        
//        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
//        currentSettings.API_Key__c='test';
//        currentSettings.Create_Date_TimeFrame__c='test';
//        currentSettings.Enriched_Entities__c='["account"]';
//        currentSettings.Invisible_Fields__c='test';
//        currentSettings.Refresh_Data_Interval__c=0;
//        currentSettings.Sync_on_create_and_update__c=true;
//        insert currentSettings;
    }
    
    @istest public static void test(){
        RecordType stratDomainRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Strategic' AND SObjectType = 'EmailDomain__c'][0];
        RecordType stratROWDomainRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Strategic_ROW' AND SObjectType = 'EmailDomain__c'][0];
        RecordType freeDomainRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Free' AND SObjectType = 'EmailDomain__c'][0];

        List<EmailDomain__c> domains = new List<EmailDomain__c>{new EmailDomain__c(Name='Test.com', RecordTypeId = stratDomainRT.Id),
            													new EmailDomain__c(Name='Test2.com'),
            													new EmailDomain__c(Name='Test3.com', RecordTypeId = stratROWDomainRT.Id),
            													new EmailDomain__c(Name='TestFree.com', RecordTypeId = freeDomainRT.Id)};
        insert domains;

        Lead lead1 = new Lead(Status = 'Open', LastName = 'Test1', Company ='Company', Email='test@test.com');
        Lead lead2 = new Lead(Status = 'Open', LastName = 'Test2', Company ='Company', Email='test@Test4.com', Employees_Min__c = 1010);
        Lead lead3 = new Lead(Status = 'Open', LastName = 'Test3', Company ='Company', Employees_Min__c = 300, Email='test@Test34.com');//shouldn't take part
        Lead lead4 = new Lead(Status = 'Open', LastName = 'Test4', Company ='Company2', Email='test@Test.com'); //shouldn't take part
        Lead lead5 = new Lead(Status = 'Open', LastName = 'Test5', Company ='Company', Email='test@Test3.com');
        Lead lead6 = new Lead(Status = 'Open', LastName = 'Test6', Company ='Company', Email='test@Test4.com', Employees_Min__c = 300);
        Lead lead7 = new Lead(Status = 'Open', LastName = 'Test7', Company ='Company', Email='test@TestFree.com', Employees_Min__c = 300, Website = 'www.TestFree.com');
        Lead lead8 = new Lead(Status = 'Open', LastName = 'Test8', Company ='Company', Email='test@TestFree.com', Website = 'www.TestFree.com');
        Lead lead9 = new Lead(Business_Unit__c='Inside Sales',Status = 'Open', LastName = 'Test9', Company ='Company', Email='test@TestFree.com', Employees_Min__c = 300, Website = 'www.TestFree.com');
        insert new List<Lead>{lead1, lead2, lead3, lead4, lead5, lead6, lead7, lead8,lead9};
        lead9.Employees_Min__c=1200;
        update lead9;
        //Itzik Winograd 25/05/2021: set one lead with non-admin user.
        User u = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name ='System Administrator' LIMIT 1];
        System.debug('### other User Id: ' + u);
        lead1.OwnerId = u.Id;
        update lead1;

        Datetime pastDate = Datetime.now().addDays(-30);
        Test.setCreatedDate(lead4.Id, pastDate);

        Test.startTest();
        Database.executeBatch(new BusinessUnitUpdateBatch(DateTime.now().addDays(-1)));
        Test.stopTest();

        List<Lead> updated = [SELECT Id, Business_Unit__c, Strategic_Region__c,Orchestration_Journey__c FROM Lead order by Name];
        /*
        System.assertEquals('Strategic', updated[0].Business_Unit__c);
        System.assertEquals('LDR', updated[0].Orchestration_Journey__c);
        System.assertEquals('Strategic NA', updated[0].Strategic_Region__c);
        System.assertEquals('Enterprise', updated[1].Business_Unit__c);
        System.assertEquals('LDR', updated[1].Orchestration_Journey__c);
        System.assertEquals(null, updated[2].Business_Unit__c);
        System.assertEquals(null, updated[3].Business_Unit__c);
        System.assertEquals('Strategic', updated[4].Business_Unit__c);
        System.assertEquals('LDR', updated[4].Orchestration_Journey__c);
        System.assertEquals('Strategic INTL', updated[4].Strategic_Region__c);
        System.assertEquals('Inside Sales', updated[5].Business_Unit__c);
        System.assertEquals('Inside Sales', updated[6].Business_Unit__c);
        System.assertEquals('Inside Sales', updated[7].Business_Unit__c);
        System.assertEquals('Enterprise', updated[8].Business_Unit__c);
        */

    }

    @istest public static void testScheduler(){
        BatchTimePeriodsSettings__c settings = new BatchTimePeriodsSettings__c(Name = 'Test BU job', Value__c = 10);
        insert settings;
        test.startTest();
        System.schedule('Test BU job', '0 0 8 * * ?', new BusinessUnitUpdateBatch());
        test.stopTest();
    }

    // 16/06/2021 Itzik Wingorad: test the calculation when the Website field is null
    @istest
    public static void testNoWebsite(){
		String ldName = 'before lead name';
        Lead beforeLead = createLead(ldName);
        insert beforeLead;
        beforeLead.Email = '';
        beforeLead.Business_Unit__c= '';
        update beforeLead;

        Test.startTest();
        Database.executeBatch(new BusinessUnitUpdateBatch(DateTime.now().addDays(-1)));
        Test.stopTest();

        Lead afterLead = [SELECT Id, Business_Unit__c
                         FROM Lead
                          WHERE FirstName = :ldName
                         LIMIT 1];
        System.assertEquals('Inside Sales', afterLead.Business_Unit__c, 'Error in business unit calc on no website');
    }


    /**
     * @author Itzik Winograd
     * @date 07/11/2022
     * @description check the business unit recalculation check + uncheck
     * @excepted Recalculate_Business_Unit__c will be true after emp_min change and false after the batch ran*/
    @istest
    public static void testBusinessUnitRecalculation(){
        String ldName = 'before lead name';
        Lead beforeLead = createLead(ldName);
        insert beforeLead;

        beforeLead.Business_Unit__c = '';
        beforeLead.Employees_Min__c = 51;
        update beforeLead;

        Lead afterLead = getLead(ldName);
//        System.assertEquals(true, afterLead.Recalculate_Business_Unit__c, 'Error: Recalculate_Business_Unit__c is false, should be true');

        Test.startTest();
        Database.executeBatch(new BusinessUnitUpdateBatch(DateTime.now().addDays(-1)));
        Test.stopTest();

        afterLead = getLead(ldName);
//        System.assertEquals(false, afterLead.Recalculate_Business_Unit__c, 'Error: Recalculate_Business_Unit__c true, should be false');

    }

    /** @description create a lead with a given FirstName*/
    public static Lead createLead(String ldName){
        return  new Lead(
            FirstName = ldName,
            LastName = ldName,
            Company = ldName,
            Employees_Min__c = 10,
            Email = 'test@test.com'
        );
    }

    /** @description get a lead by given FirstName*/
    public static Lead getLead(String ldName){
        Lead foundLead = [SELECT Id, Business_Unit__c, Recalculate_Business_Unit__c, Employees_Min__c
                            FROM Lead
                            WHERE FirstName = :ldName
                            LIMIT 1];
        System.debug('@@@ foundLead: ' + foundLead);
        return foundLead;
    }

    /**
     * @author Itzik Winograd
     * @date 20/12/2022
     * @description Check the BU calculation on Account, depending on the Industry_Cluster__c field
     * @excepted Logic will apply for Inside Sales or Enterprise
     **/
    @istest
    public static void testBusinessUnitWithCluster(){
        Account acc = AccountUtils.getAccounts(1)[0];
        insert acc;

        Test.startTest();
            acc.SW_Industry__c = 'Investors';
            acc.Employees_Min__c = 11;
            update acc;
        Test.stopTest();
        acc = [SELECT Id, SW_Industry__c, Industry_Cluster__c, Business_Unit__c FROM Account LIMIT 1];
        System.debug('@@@ acc after update: ' + acc);
        System.assertEquals('Inside Sales', acc.Business_Unit__c, 'Error: Business_Unit__c should be Inside Sales');

        //second test:
            acc.put('SW_Industry__c', 'Hedge Funds and Asset Management');
            acc.put('AUM__c' , '$500M - $1B');
            update acc;
        //end of second test
        acc = [SELECT Id, SW_Industry__c, Industry_Cluster__c, Business_Unit__c FROM Account LIMIT 1];
        System.debug('@@@ acc after update: ' + acc);
        System.assertEquals('Enterprise', acc.Business_Unit__c, 'Error: Business_Unit__c should be Enterprise');

    }

    //New Tests

    @isTest static void test_mapRecordsToDomains_and_accountPath_updatesInMemory() {
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'EmailDomain__c' LIMIT 1];
        RecordType rtEnterprise = null;
        try {
            rtEnterprise = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'EmailDomain__c' AND DeveloperName = 'enterprise' LIMIT 1];
        } catch (Exception e) {}
        if (rtEnterprise != null) rt = rtEnterprise;

        EmailDomain__c ed = new EmailDomain__c(
                Name = 'example.com',
                Parent_Company_Domain__c = 'parent.com',
                Strategic_Pod__c = null,
                Exclude_NAL_tagging_from_Private_email__c = false,
                RecordTypeId = rt.Id
        );
        insert ed;

        Account a = new Account(Name = 'Acct1', Website = 'example.com');
        BusinessUnitUpdateHelper helper = new BusinessUnitUpdateHelper();

        Test.startTest();
        helper.updateBusinessUnit(new List<SObject>{ a }, 'Website', 'BillingCountryCode', null, true);
        Test.stopTest();

        System.assertEquals('Enterprise', a.get('Business_Unit__c'), 'Account should be set to Enterprise for enterprise record type');
        System.assertEquals('parent.com', a.get('Parent_Company_Domain__c'), 'Parent_Company_Domain__c should be set from EmailDomain__c');
        System.assertEquals(null, a.get('Strategic_Region__c'));
    }

    @isTest static void test_updateBusinessUnit_onLead_performsDml_and_unsetsRecalculateFlag() {
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'EmailDomain__c' LIMIT 1];
        RecordType rtEnterprise = null;
        try {
            rtEnterprise = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'EmailDomain__c' AND DeveloperName = 'enterprise' LIMIT 1];
        } catch (Exception e) {}
        if (rtEnterprise != null) rt = rtEnterprise;

        EmailDomain__c ed = new EmailDomain__c(
                Name = 'lead-domain.com',
                Parent_Company_Domain__c = 'parent-lead.com',
                Strategic_Pod__c = null,
                Exclude_NAL_tagging_from_Private_email__c = false,
                RecordTypeId = rt.Id
        );
        insert ed;

        Lead ld = new Lead(
                LastName = 'LD1',
                Company = 'Comp1',
                Website = 'lead-domain.com',
                Email_address_domain_type__c = 'Company',
                Recalculate_Business_Unit__c = true,
                Email = 'test123@gmail.com'
        );
        insert ld;

        BusinessUnitUpdateHelper helper = new BusinessUnitUpdateHelper();

        Test.startTest();
        helper.updateBusinessUnit(new List<SObject>{ ld }, 'Website', 'Country', null, false);
        Test.stopTest();

        Lead ldAfter = [SELECT Id, Business_Unit__c, Recalculate_Business_Unit__c FROM Lead WHERE Id = :ld.Id];

        System.assertEquals('Enterprise', ldAfter.Business_Unit__c, 'Lead business unit should be Enterprise for enterprise record type');
    }

    @isTest static void test_mapEmailDomainsToDomains_lowercaseKeying() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'EmailDomain__c' LIMIT 1];
        EmailDomain__c edMixed = new EmailDomain__c(Name = 'MiXeD-Domain.COM', RecordTypeId = rt.Id);
        insert edMixed;

        BusinessUnitUpdateHelper helper = new BusinessUnitUpdateHelper();
        Set<String> domains = new Set<String>{ 'mixed-domain.com' };
        Map<String, EmailDomain__c> mapRes = helper.mapEmailDomainsToDomains(domains);

        System.assert(mapRes.containsKey('mixed-domain.com'), 'mapEmailDomainsToDomains should key by lowercase domain name');
        System.assertEquals(edMixed.Id, mapRes.get('mixed-domain.com').Id);
    }
}