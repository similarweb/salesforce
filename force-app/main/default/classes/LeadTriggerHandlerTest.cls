@istest public class LeadTriggerHandlerTest {
    @testSetup
    static void setup(){
        User u = [SELECT Id FROM User WHERE Id !=:UserInfo.getUserId() LIMIT 1];

        Pardot_Data_Manipulation_Setting__c pdms1 = new Pardot_Data_Manipulation_Setting__c();
        pdms1.Name = 'JUNK_LEAD_OWNER_ID';
        pdms1.Value__c = u.Id;
        insert pdms1;

        Polygraph_Interaction_Setting__c pis = new Polygraph_Interaction_Setting__c();
        pis.Name = 'Token_Password';
        pis.Value__c = '00000000000000000000000000000000';
        insert pis;

        List<LDR_Criteria_Settings__c> lcsList = new List<LDR_Criteria_Settings__c>();
        List<String> cr = new List<String>{'Company_LDR_Compare__c=False','Country_LDR_Compare__c=FALSE','Email domain type = Private','Is null (Company)','Is null (Country)','Is null (Email)','Is null (Employee Min)','Is null (FirstName)','Is null (SW Industry)','Is null (Employee Max)','Is null (Phone)','Is null (Title)','Is null (Website)',
                                           'LeadSource != NULL','LeadSource not contains Outbound','LeadSource!= Deal Registration','Not(Country=Japan)','Country=Netherlands','Country=Luxembourg','Country=Norway','Country=Sweden','Country=Denmark','Country=Finland','Country=Iceland'};
        for(String str : cr){
            LDR_Criteria_Settings__c lcs = new LDR_Criteria_Settings__c();
            lcs.Name=str;
            lcs.Enabled__c=true;
            lcsList.add(lcs) ;
        }
        insert lcsList;

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

        InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
        islcvcl.Name='department__c';
        islcvcl.Is_Valid__c=true;
        insert islcvcl;

        SFMC_Processed_by_Distribution__c processedByDistribution = setDistribution(0, 0, 'Sales');
        insert processedByDistribution;
    }

    @istest static void polyghraphInteractionTest(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        Datetime leadDatetime = Datetime.newInstance(2055,10,10,5,0,0);
        List<Lead> leads = new List<Lead>{new Lead(LastName='Test 1', Company='Test comp',Form_Submission_Date_and_Time__c = leadDatetime,Web_Form_Name__c = '64k8mn', Email='test@gmail.com'),new Lead(LastName='Test 2', Company='Test comp 2', Email='test@gmail.com')};
        Test.startTest();
        insert leads;
        Test.stopTest();
    }


    @istest static void test(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        List<Lead> leads = new List<Lead>{new Lead(LastName='Test 1', Company='Test comp', Email='test@gmail.com'),new Lead(LastName='Test 2', Company='Test comp 2', Email='test@gmail.com')};
        insert leads;

        List<Task> tasks = new List<Task>{new Task(Subject='Test Subj1', Priority='Normal', Status='Not Started', WhoId=leads[0].Id),
                                          new Task(Subject='Test Subj2', Priority='Normal', Status='Not Started', WhoId=leads[1].Id),
                                          new Task(Subject='Test Subj2', Priority='Normal', Status='Completed', WhoId=leads[1].Id),
                                          new Task(Subject='Test Subj with Contact us form', Priority='Normal', Status='Deferred', WhoId=leads[1].Id),
                                          new Task(Subject='Test Subj with Contact us form 2', Priority='Normal', Status='In Progress', WhoId=leads[1].Id)};
        insert tasks;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduserForSimilarWeb@testorg.com');
        insert u;
        Test.startTest();
        leads[1].OwnerId = u.Id;

        update leads[1];
        Test.stopTest();

        Task successTask = [select Id, OwnerId, Subject from Task where WhoId=:leads[1].ID and Status='In Progress' limit 1];
        //System.assertEquals(u.Id, successTask.OwnerId);
        System.assertEquals('Test Subj with Contact us form 2',successTask.Subject);
        System.assert([select Id, OwnerId, Subject from Task where WhoId=:leads[1].ID AND Status='Deferred' LIMIT 1].get(0).OwnerId != u.Id);
        System.assert([select Id, OwnerId, Subject from Task where WhoId=:leads[1].ID AND Subject='Test Subj2' LIMIT 1].get(0).OwnerId != u.Id);
    }

    @istest static void unsubscribeTest(){
        Datetime leadDatetime = Datetime.newInstance(2055,10,10,5,0,0);
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        List<RecordType> panelAcquisitionRTList = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Wolves' LIMIT 1];
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',HasOptedOutOfEmail=false,RecordTypeId=panelAcquisitionRTList[0].Id, Email='test@gmail.com');
        Lead lead2 = new Lead(LastName='Test 2', Company='Test comp',HasOptedOutOfEmail=false, Email='test@gmail.com');
        insert lead1;
        insert lead2;
        Test.startTest();
        lead1.HasOptedOutOfEmail=true;
        lead1.Form_Submission_Date_and_Time__c = leadDatetime;
        lead1.Web_Form_Name__c = '64k8mn';
        update lead1;
        lead2.HasOptedOutOfEmail=true;
        lead2.RecordTypeId=panelAcquisitionRTList[0].Id;
        update lead2;
        Test.stopTest();
    }
    @istest static void outboundLeadsFlowTest(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        List<RecordType> panelAcquisitionRTList = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Wolves' LIMIT 1];
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',Original_Lead_Source__c='SDR Outbound', Email='test@gmail.com');
        Lead lead2 = new Lead(LastName='Test 2', Company='Test comp', Email='test@gmail.com');
        insert lead1;
        insert lead2;
        Test.startTest();
        lead2.Original_Lead_Source__c='SDR Outbound';
        update lead2;
        Test.stopTest();
    }

    @istest static void frenemiesFlowTest(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        Frenemy__c fr = new Frenemy__c(Name='test.com');
        insert fr;
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',Email_address_domain_type__c='Company', Email='test@gmail.com');
        Lead lead2 = new Lead(LastName='Test 2', Company='Test comp',Email_address_domain_type__c='Private', Email='test@gmail.com');
        insert lead1;
        insert lead2;
        Test.startTest();
        lead1.Email='test@test.com';
        update lead1;
        lead2.Website='www.test.com';
        lead2.Department__c ='Test Department for groudon';
        update lead2;
        Test.stopTest();
    }
    @istest static void similarWebEmployeesTest(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',Email_address_domain_type__c='Company',Email='test@gmail.com');
        Lead lead2 = new Lead(LastName='Test 2', Company='Test comp',Email_address_domain_type__c='Private', Email='test@gmail.com');
        insert lead1;
        insert lead2;
        Test.startTest();
        lead2.Website='www.similarweb.com';
        update lead2;
        Test.stopTest();
    }
    /*@istest static void blackListTest(){
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',Email_address_domain_type__c='Junk');
        Lead lead2 = new Lead(LastName='Test 2', Company='Test comp');
        insert lead1;
        insert lead2;
        Test.startTest();
        lead2.Email_address_domain_type__c='Junk';
        update lead2;
        Test.stopTest();
    }*/
    @istest static void journeyDecisionTest(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        Lead lead1 = new Lead(OwnerId='0050O000007jDGG',LastName='Test 1', Company='Test comp',LeadSource='MIR', Email='test@gmail.com');

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @istest static void setEmployeeMinTimestampTest(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',LeadSource='MIR',Employees_Min__c=300, Email='test@gmail.com');
        Test.startTest();
        insert lead1;
        lead1.Employees_Min__c=400;
        update lead1;
        Test.stopTest();
    }

    @istest static void checkIfCountryAuthorizedTest(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',LeadSource='MIR',Employees_Min__c=300,Country_Code__c='IR', Email='test@gmail.com');
        Test.startTest();
        insert lead1;
        lead1.Employees_Min__c=400;
        update lead1;
        Test.stopTest();
    }
    @isTest
    static void funnelMonitorTest(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
        Lead lead1 = new Lead(LastName='Test 1', Company='Test comp',LeadSource='MIR',Employees_Min__c=300,Country_Code__c='IR', Email='test@gmail.com',New_Behavioral_Rate__c=1,SW_Fit_Score__c='A',Business_Unit__c='A',OwnerID=FunelMonitorHandler.JOURNEY_OLD_OWNER_ID);
        Test.startTest();
        insert lead1;
        lead1.New_Behavioral_Rate__c=2;
        lead1.SW_Fit_Score__c='B';
        lead1.Business_Unit__c='B';
        lead1.OwnerId=UserInfo.getUserId();
        lead1.LeadSource='MIMIMIR';
        update lead1;
        lead1.Polygraph_Company_Employees_Range__c='1-10';
        Test.stopTest();
    }
    @isTest
    static void createDistributionedLeads0(){
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Sales'
        );


        List<Lead> leadList = new List<Lead>();
        for (Integer i = 0; i < 15; i++) {
            leadList.add(new Lead(
                    LastName='Test ' + i,
                    Company='Test comp' + i,
                    email='jumbo' + i + '@mumbo.com',
                    Inferred_Solution__c='Sales'
            ));
        }

        Test.startTest();
        insert lead1;
        insert leadList;
        Test.stopTest();

    }

    @isTest
    static void createDistributionedLeads1() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Investors'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads2() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Marketing (MI)'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads3() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Research'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads4() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Marketing'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads5() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Sales (SI)'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads6() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Agency (MI)'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads7() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Investors (II)'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads8() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='Publishers & Media'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    @isTest
    static void createDistributionedLeads9() {
        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());

        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='AI / PI'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();
    }

    /**
     * @author Itzik Winograd
     * @description MIS-3230: Dont call polygraph, just update the timestamps fields.
     * @expected    Polygraph timestamps are not null.
     * @date 2022-11-08
     * */
    @isTest
    public static void setPolygraphTimeStampsTest(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='AI / PI'
        );
        Test.startTest();
        insert lead1;
        Test.stopTest();

        Lead ld = [SELECT Id, Polygraph_Update_Timestamp__c, Sent_to_Polygraph__c
        FROM Lead
        WHERE Id = :lead1.Id];
        System.assert(ld.Polygraph_Update_Timestamp__c != null && ld.Sent_to_Polygraph__c!= null, 'Polygraph timestamps are not set.');
    }


    private static SFMC_Processed_by_Distribution__c setDistribution(Decimal SFMCPercent, Decimal counter, String solution){
        return new SFMC_Processed_by_Distribution__c(
                Processed_by_SFMC__c = SFMCPercent,
                Initial_Date__c = date.today() - 1,
                Counter__c = counter,
                Solution__c = solution
        );
    }

    /**
     * @author Zohar Sinay
     * @description MIS-3816: NA, No_Company fix
     * @expected   Delete lead will trigger merge
     * @date 2023-10-4
     * */
    @isTest
    public static void leadMergeTest(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='AI / PI'
        );
        Test.startTest();
        insert lead1;
        delete lead1;
        Test.stopTest();
        //System.assert(ld.Polygraph_Update_Timestamp__c != null && ld.Sent_to_Polygraph__c!= null, 'Polygraph timestamps are not set.');
    }

    @isTest
    public static void setSlaTimestampTest(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        Lead lead1 = new Lead(
                LastName='Test 1',
                Company='Test comp',
                email='jumbo101@mumbo.com',
                Inferred_Solution__c='AI / PI'
        );
        insert lead1;
        Test.startTest();
        lead1.Last_Owner_Assigned_Date__c = Datetime.now();
        lead1.First_MQL_Date__c = Datetime.now().addHours(-1);
        update lead1;

        Test.stopTest();
        //System.assert(ld.Polygraph_Update_Timestamp__c != null && ld.Sent_to_Polygraph__c!= null, 'Polygraph timestamps are not set.');
    }
}