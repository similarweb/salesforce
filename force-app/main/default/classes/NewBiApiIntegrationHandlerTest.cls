@isTest
public class NewBiApiIntegrationHandlerTest {
//    @testSetup
//    static void setup(){
//        User u = [SELECT Id FROM User WHERE Id !=:UserInfo.getUserId() LIMIT 1];
//
//        Pardot_Data_Manipulation_Setting__c pdms1 = new Pardot_Data_Manipulation_Setting__c();
//		pdms1.Name = 'JUNK_LEAD_OWNER_ID';
//		pdms1.Value__c = u.Id;
//		insert pdms1;
//
//        Pardot_Data_Manipulation_Setting__c pdms11 = new Pardot_Data_Manipulation_Setting__c();
//		pdms11.Name = 'LDR_LEAD_OWNER_ID';
//		pdms11.Value__c = u.Id;
//		insert pdms11;
//
//        Pardot_Data_Manipulation_Setting__c pdms111 = new Pardot_Data_Manipulation_Setting__c();
//		pdms111.Name = 'FRENEMY_LEAD_OWNER_ID';
//		pdms111.Value__c = u.Id;
//		insert pdms111;
//
//        Pardot_Data_Manipulation_Setting__c pdms2 = new Pardot_Data_Manipulation_Setting__c();
//		pdms2.Name = 'FRENEMY_FLOW_MINUTES';
//		pdms2.Value__c = '2';
//		insert pdms2;
//
//        Polygraph_Interaction_Setting__c pis = new Polygraph_Interaction_Setting__c();
//		pis.Name = 'Token_Password';
//		pis.Value__c = '00000000000000000000000000000000';
//		insert pis;
//
//        Polygraph_Interaction_Setting__c pis2 = new Polygraph_Interaction_Setting__c();
//		pis2.Name = 'UserKey';
//		pis2.Value__c = 'test';
//		insert pis2;
//
//        Polygraph_Interaction_Setting__c pis3 = new Polygraph_Interaction_Setting__c();
//		pis3.Name = 'Endpoint';
//		pis3.Value__c = 'https://polygraph-test.similarweb.io/api/test';
//		insert pis3;
//
//        List<LDR_Criteria_Settings__c> lcsList = new List<LDR_Criteria_Settings__c>();
//        List<String> cr = new List<String>{'Company_LDR_Compare__c=False','Country_LDR_Compare__c=FALSE','Email domain type = Private','Is null (Company)','Is null (Country)','Is null (Email)','Is null (Employee Min)','Is null (FirstName)','Is null (Industry)','Is null (Phone)','Is null (Title)','Is null (Website)',
//'LeadSource != NULL','LeadSource not contains Outbound','LeadSource!= Deal Registration','Not(Country=Japan)'};
//        for(String str : cr){
//            LDR_Criteria_Settings__c lcs = new LDR_Criteria_Settings__c();
//            lcs.Name=str;
//            lcs.Enabled__c=true;
//            lcsList.add(lcs) ;
//        }
//        insert lcsList;
//
//        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
//        iss.Name='Default Value';
//        iss.Value__c='Sales';
//        insert iss;
//
//        InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
//        ismTest.SW_Industry__c = 'AdTech and AdNetwork';
//        ismTest.Department__c = 'BI / Analytics';
//        ismTest.Inferred_Solution__c = 'Research';
//        ismTest.Name = 'test';
//        insert ismTest;
//
//        InferralSolutionMapContact__c ismCTest = new InferralSolutionMapContact__c();
//        ismCTest.SW_Industry__c = 'AdTech and AdNetwork';
//        ismTest.Department__c = 'BI / Analytics';
//        ismCTest.Inferred_Solution__c = 'Research';
//        ismCTest.Name = 'test';
//        insert ismCTest;
//
//        Inferral_Solution_Valid_Criteria_List__c islvcl = new Inferral_Solution_Valid_Criteria_List__c();
//        islvcl.Name='department__c';
//        islvcl.Is_Valid__c=true;
//        insert islvcl;
//
//        Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
//        islvcl2.Name='sw_industry__c';
//        islvcl2.Is_Valid__c=true;
//        insert islvcl2;
//
//        InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
//        islcvcl.Name='department__c';
//        islcvcl.Is_Valid__c=true;
//        insert islcvcl;
//
//        InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
//        islcvcl2.Name='sw_industry__c';
//        islcvcl2.Is_Valid__c=true;
//        insert islcvcl2;
//
////        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
////        currentSettings.API_Key__c='test';
////        currentSettings.Create_Date_TimeFrame__c='test';
////        currentSettings.Enriched_Entities__c='["account","lead"]';
////        currentSettings.Invisible_Fields__c='test';
////        currentSettings.Refresh_Data_Interval__c=0;
////        currentSettings.Sync_on_create_and_update__c=true;
////        insert currentSettings;
//
//        //Added 2021-01-05
//		Map<Id, String> myMap = new Map<Id, String>();
//        myMap.put((Id)'000000000000005', 'someTest');
//        NewBiApiInteractionHandler.buildChangedFieldMessage(myMap);
//
//        //Added 2021-02-15
//        Test.setMock(HttpCalloutMock.class, new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator());
//
//        List<Account> accList = new List<Account>();
//        Account acc = AccountUtils.getAccounts(1)[0];
//        accList.add(acc);
//        insert accList;
//        Map<Id, Account> oldAccMap = new Map<Id, Account>();
//        oldAccMap.put(accList[0].Id, accList[0]);
//        NewBiApiInteractionHandler nbih = new NewBiApiInteractionHandler('Account');
////        nbih.fitscoreOnDfoxChange(accList,oldAccMap);
//    }
//
//    @isTest
//    static void testLead(){
//        Test.startTest();
//        NewBiApiInteractionHandler.doChainJob = false;
//        Test.setMock(HttpCalloutMock.class, new NewBiApiMockImp());
//        //country=null&title=null&department__c=null&employees_min__c=0&label_sw_industry__c=null&swid__r_website_category__c=nul
//        Lead lead = new Lead(LastName='Test Last Name', Company='Test comp', Email='test@gmail.com', country='Japan',title='Test', department__c='Human Resources', sw_industry__c='TestInd');
//
//        insert lead;
//        //Lead l = [SELECT swid__r.website_category__c FROM Lead];
////        SimilarWeb_Website_Data__c swwd = new SimilarWeb_Website_Data__c();
////        swwd.Name = 'Test';
////        swwd.Domain__c = 'test.com';
////        swwd.website_category__c = 'Test22';
////        insert swwd;
//
//        //l.swid__c = swwd.Id;
//        //update l;
//
//        //swid__c swid = new swid__c();
//        //System.debug('!!!'+l);
//        NewBiApiInteractionHandler.fitscoreOnDfoxChangeSynchronius(new List<sObject>{lead},'Lead');
//        NewBiApiInteractionHandler.fitscoreOnDfoxChangeFuture(new Set<Id>{lead.Id},'Lead');
//        NewBiApiInteractionHandler.buildFailedLogObject('test','test','test','test',true);
//        Test.stopTest();
//    }
//
//    @isTest
//    static void testLeadRetry(){
//        Test.startTest();
//        String entityType = 'Lead';
//        NewBiApiInteractionHandler.doChainJob = false;
//        Test.setMock(HttpCalloutMock.class, new PolyghraphMockImp());
//        Lead lead = new Lead(LastName='Test 1', Company='Test comp', Email='test@gmail.com',Polygraph_Update_Timestamp__c=DateTime.now().addDays(-1));
//        Lead lead2 = new Lead(LastName='Test 2', Company='Test comp', Email='test1@gmail.com',Polygraph_Update_Timestamp__c=DateTime.now());
//        List<Lead> leadList = new List<Lead>{lead};
//
//        Map<Integer,List<sObject>> chunckedMap = new Map<Integer,List<sObject>>();
//        Map<Id,String> idToChangedFieldMap = new Map<Id,String>();
//
//        for(Integer i=0;i<leadList.size();i++){
//            sObject obj_i = leadList[i];
//            sObject oldObj_i = lead2;
//            System.debug(obj_i.get('Polygraph_Update_Timestamp__c'));
//            String changedField= new NewBiApiInteractionHandler('Lead').fieldChangeCheck(obj_i,oldObj_i);
//            // if( ((obj_i.get('dfox__Last_Synced_Date__c') !=oldObj_i.get('dfox__Last_Synced_Date__c')) // !System.isFuture() && !System.isBatch()
//            //      || ( ((entityType=='Lead' && obj_i.get('Polygraph_Update_Timestamp__c')!= null)
//            //            || obj_i.get('dfox__Last_Synced_Date__c')!= null) && String.isNotBlank(changedField))) )
//            // {
//            //     Integer index = i/100;
//            //     System.debug('index'+ index);
//            //     if(!chunckedMap.containsKey(index)){
//            //         chunckedMap.put(index,new List<sObject>());
//            //     }
//            //     chunckedMap.get(index).add(obj_i);
//            //     if( obj_i.get('dfox__Last_Synced_Date__c') !=oldObj_i.get('dfox__Last_Synced_Date__c') ){
//            //         idToChangedFieldMap.put(obj_i.Id, 'dfox__Last_Synced_Date__c changed from ' + oldObj_i.get('dfox__Last_Synced_Date__c') + ' to ' + obj_i.get('dfox__Last_Synced_Date__c'));
//            //     } else if(String.isNotBlank(changedField)) {
//            //         idToChangedFieldMap.put(obj_i.Id, changedField);
//            //     }
//            // }
//        }
//        System.debug('chunckedMap.isEmpty() - ' + chunckedMap.isEmpty());
//         Map<Integer,Set<Id>> recordsToRetryIdMap = new Map<Integer,Set<Id>>();
//        if(!chunckedMap.isEmpty()){
//            System.enqueueJob(new NewBiApiInteractionHandler.BiApiInteractionRetryJob(chunckedMap,entityType,idToChangedFieldMap));
//        }
//        Test.stopTest();
//    }
//
//    @isTest
//    static void testContact(){
//        Test.startTest();
//        NewBiApiInteractionHandler.doChainJob = false;
//        Test.setMock(HttpCalloutMock.class, new NewBiApiMockImp());
//        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Default'][0];
//        Account acc = new Account(RecordType = accountRecordType, Name = 'Test', Business_Unit__c = 'Inside Sales');
//        insert acc;
//        Contact cnt = new Contact(LastName='Contact', FirstName = 'Test', Email = 'test@11mail.com', AccountId = acc.Id);
//        insert cnt;
//        cnt.Email = 'test@test.com';
//        update cnt;
//        //NewBiApiInteractionHandler.fitscoreOnDfoxChangeSynchronius(new List<sObject>{cnt},'Contact');
//        //NewBiApiInteractionHandler.fitscoreOnDfoxChangeFuture(new Set<Id>{cnt.Id},'Contact');
//        Test.stopTest();
//    }
//
//    @isTest
//    static void testgetParamsListByEntityType(){
//        NewBiApiInteractionHandler.getParamsListByEntityType('Lead');
//        NewBiApiInteractionHandler.getParamsListByEntityType('Contact');
//        NewBiApiInteractionHandler.getParamsListByEntityType('Account');
//    }
//
}