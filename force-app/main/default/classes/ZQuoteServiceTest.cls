@isTest
public class ZQuoteServiceTest {

    public static Boolean isRunning = false;
    public static ZQuoteService service;

    @testSetup
    public static void setup(){            
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
        upsert TestDataFactory.createZuoraQuoteApprovalSettings_CS();
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        List<String> countries =  TestDataFactory.getCountries();
        Account a = TestDataFactory.createAccount();
        a.billingcountryCode = 'UA';
        insert a;
        Contact c = TestDataFactory.createContact(a, 'test@testing.com');
        insert c;
        List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
        insert lcsc;
        Opportunity o = TestDataFactory.createOpportunity (a);
        insert o;
        zqu__Quote__c quote = TestDataFactory.createZQuote (o,c);
        insert quote;
    }
 
    @isTest
    public static void retreiveBaseProductContractValuesTest() {
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        List<PicklistValue> plList = service.retreiveBaseProductContractValues();
        System.assertEquals(1,plList.size());
        System.assertEquals('BPC_Label1',plList[0].Label);
        System.assertEquals('BPC_Value1',plList[0].Value);
    }

    @isTest
    public static void retreiveBaseProductPicklistValuesTest() {
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        List<PicklistValue> response = service.retreiveBaseProductPicklistValues();
        Test.stopTest();
        System.assertEquals(2,response.size());
        System.assertEquals('BPCO_Label1',response[0].Label);
        System.assertEquals('BPCO_Value1',response[0].Value);
        System.assertEquals('BPCO_Label2',response[1].Label);
        System.assertEquals('BPCO_Value2',response[1].Value);
    }

    @isTest
    public static void addBaseProductPicklistValuesTest() {
        ZQuoteService service = new ZQuoteService();
        String fullNameListRaw = 'Test2\nTest3';
        Test.startTest();
        isRunning = true;
        String response = service.addBaseProductPicklistValues(fullNameListRaw);
        Test.stopTest();
    }

    @isTest
    public static void deleteBaseProductPicklistValuesTest() {
        ZQuoteService service = new ZQuoteService();
        String fullNameToDelete = 'BPCO_Value1';
        Test.startTest();
        isRunning = true;
        String response = service.deleteBaseProductPicklistValues(fullNameToDelete);
        Test.stopTest();
        System.assertEquals(true,String.isBlank(response));
    }

    @isTest
    public static void editBaseProductPicklistValuesTest() {
        ZQuoteService service = new ZQuoteService();
        String newLabel = 'BPCO_LabelNew';
        String fullName = 'BPCO_Value1';
        Test.startTest();
        isRunning = true;
        String response = service.editBaseProductPicklistValues(fullName,newLabel);
        Test.stopTest();
        System.assertEquals(true,String.isBlank(response));
    }

    @isTest
    public static void retreiveWorldListPicklistValuesForDependentValueTest() {
        ZQuoteService service = new ZQuoteService();
        //String controllingFieldValue = Base_Product_Configuration__c.getInstance('Controlling field name').Value__c;
        Test.startTest();
        isRunning = true;
        List<PicklistValue> response = service.retreiveWorldListPicklistValuesForDependentValue('BPCO_Value1');
        Test.stopTest();
    }

    @isTest
    public static void addWorldListPicklistValueTest() {
        ZQuoteService service = new ZQuoteService();
        String fullNameListRaw = 'newTest1\nnewTest2';
        //String controllingFieldValue = Base_Product_Configuration__c.getInstance('Controlling field name').Value__c;
        Test.startTest();
        isRunning = true;
        String response = service.addWorldListPicklistValue(fullNameListRaw);
        Test.stopTest();
        System.assertEquals(true,String.isBlank(response));
    }

    @isTest
    public static void addDependencyWorldListPicklistValueTest() {
        ZQuoteService service = new ZQuoteService();
        List <String> fullNameList = new List <String> {'newTest1','newTest2'};
        String fullNameListRaw = JSON.serialize(fullNameList);
        String controllingFieldValue = Base_Product_Configuration__c.getInstance('Controlling field name').Value__c;
        Test.startTest();
        isRunning = true;
        String response = service.addDependencyWorldListPicklistValue(controllingFieldValue,fullNameListRaw);
        Test.stopTest();
        System.assertEquals(true,String.isBlank(response));
    }   

    @isTest
    public static void deleteWorldListPicklistValueTest() {
        ZQuoteService service = new ZQuoteService();
        String fullNameToDelete = 'BPC_Value1';
        Test.startTest();
        isRunning = true;
        String response = service.deleteWorldListPicklistValue(fullNameToDelete);
        Test.stopTest();
        System.assertEquals(true,String.isBlank(response));
    }

    @isTest
    public static void editWorldListPicklistValuesTest() {
        ZQuoteService service = new ZQuoteService();
        String newLabel = 'BPC_LabelNew';
        String fullName = 'BPC_Value1';
        Test.startTest();
        isRunning = true;
        String response = service.editWorldListPicklistValues(fullName,newLabel);
        Test.stopTest();
        System.assertEquals(true,String.isBlank(response));
    } 
    
    @isTest
    public static void retrieveDefaultAddonsForBaseProductTest(){
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        List<String> response = service.retrieveDefaultAddonsForBaseProduct('Marketing Solution - Premium');
        Test.stopTest();
        System.assertEquals(1,response.size());
        System.assertEquals('Marketing Premium 5K Monthly API Hits',response[0]);
    }

    @isTest
    public static void retrieveDynamicAddonsForBaseProductTest(){
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        List<String> response = service.retrieveDynamicAddonsForBaseProduct('Marketing Solution - Premium');
        Test.stopTest();
        System.assertEquals(1,response.size());
        System.assertEquals(true,response.contains('Marketing - 5 Months of Historical Data'));
    }

    @isTest
    public static void retrieveDefaultNumberOfUsersForBaseProductTest(){
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        Integer response = service.retrieveDefaultNumberOfUsersForBaseProduct('Marketing Solution - Premium');
        Integer emptyResponse = service.retrieveDefaultNumberOfUsersForBaseProduct('Empty');
        Test.stopTest();
        System.assertEquals(2,response);
        System.assertEquals(null,emptyResponse);
    }

    @isTest
    public static void setDefaultAddonsForBaseProductTest(){
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.setDefaultAddonsForBaseProduct('Addon1\nAddon2','Marketing Solution - Premium');
        Test.stopTest();
        List<Base_Product_Default_Addon__c> bpdaList = [SELECT ID, Addon__c FROM Base_Product_Default_Addon__c WHERE Controlling__c='Marketing Solution - Premium'];
        List<String> addonList = new List<String>();
        for (Base_Product_Default_Addon__c bpda_i : bpdaList) {
            addonList.add(bpda_i.Addon__c);
        }
        System.assertEquals(2,addonList.size());
        System.assertEquals(true,addonList.contains('Addon1'));
        System.assertEquals(true,addonList.contains('Addon2'));
    }

    @isTest
    public static void setDynamicAddonsForBaseProductTest(){
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.setDynamicAddonsForBaseProduct('Last Addon1 Months of Historical Data\nLast Addon2 Months of Historical Data','Marketing Solution - Premium');
        Test.stopTest();
        List<Base_Product_Dynamic_Addon__c> bpdaList = [SELECT ID
                                                             , Addon__c
                                                             , Postfix__c 
                                                        FROM Base_Product_Dynamic_Addon__c
                                                        WHERE Controlling__c='Marketing Solution - Premium'
        ];
        List<String> addonList = new List<String>();
        for (Base_Product_Dynamic_Addon__c bpda_i : bpdaList) {
            addonList.add(bpda_i.Addon__c);
        }
        System.assertEquals(2,addonList.size());
        System.assertEquals(true,addonList.contains('Last Addon2 Months of Historical Data'));
        System.assertEquals('Months of Historical Data',bpdaList[addonList.indexOf('Last Addon2 Months of Historical Data')].Postfix__c);
        System.assertEquals(true,addonList.contains('Last Addon2 Months of Historical Data'));
        System.assertEquals('Months of Historical Data',bpdaList[addonList.indexOf('Last Addon2 Months of Historical Data')].Postfix__c);
    }

    @isTest
    public static void setDefaultNumberOfUsersForBaseProducTest(){
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.setDefaultNumberOfUsersForBaseProduct(7,'Marketing Solution - Premium');
        service.setDefaultNumberOfUsersForBaseProduct(12,'NewMarketing Solution - Premium');
        Test.stopTest();
        Base_Product_Num_of_Users__c existingBpda = Base_Product_Num_of_Users__c.getInstance(Utility.hashCode('Marketing Solution - Premium'));
        Base_Product_Num_of_Users__c newBpda = Base_Product_Num_of_Users__c.getInstance(Utility.hashCode('NewMarketing Solution - Premium'));
        System.assertEquals(7,existingBpda.Number_of_User__c);
        System.assertEquals(12,newBpda.Number_of_User__c);
    }

    @isTest
    public static void generatePreviewContractWithoutValidationTest(){
        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.setMock(HttpCalloutMock.class, MockUtil.obtainHttpMock(ZuoraContractGenerationHelper.class));
        Test.startTest();
        service.generatePreviewContract(quote.Id, false);
        Test.stopTest();
    }

    @isTest
    public static void generatePreviewContractWithValidationTest(){
        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu__ApprovalStatus__c = 'Approved';
        quote.zqu_Quote_Status__c = 'Terms Approved';
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.setMock(HttpCalloutMock.class, MockUtil.obtainHttpMock(ZuoraContractGenerationHelper.class));
        Test.setMock(WebServiceMock.class, MockUtil.obtainWebServiceMock(CheckVatViesService.class));
        Test.startTest();
        service.generatePreviewContract(quote.Id, true);
        Test.stopTest();
    }

    @isTest
    public static void generatePreviewContractWithValidationEmptyContactTest(){
        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu__ApprovalStatus__c = 'Approved';
        quote.zqu_Quote_Status__c = 'Terms Approved';
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.setMock(HttpCalloutMock.class, MockUtil.obtainHttpMock(ZuoraContractGenerationHelper.class));
        Test.setMock(WebServiceMock.class, MockUtil.obtainWebServiceMock(CheckVatViesService.class));
        Test.startTest();
        service.generatePreviewContract(quote.Id, true);
        Test.stopTest();
    }

    @isTest
    public static void obtainAndSaveContractPreviewTest(){
        List<String> countries =  TestDataFactory.getCountries();

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.setMock(HttpCalloutMock.class, MockUtil.obtainHttpMock(ZuoraContractGenerationHelper.class));
        Test.startTest();
        service.obtainAndSaveContract(quote.Id, 'testFileUrl', 'preview', '',false);
        Test.stopTest();
    }

    @isTest
    public static void obtainAndSaveContractSavingTest(){

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.setMock(HttpCalloutMock.class, MockUtil.obtainHttpMock(ZuoraContractGenerationHelper.class));
        Test.startTest();
        service.obtainAndSaveContract(quote.Id, 'testFileUrl', 'saving', '', false);
        Test.stopTest();
    }

    @isTest
    public static void submitQuoteForApprovalRejectedTest(){

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu__Previewed_SubTotal__c = 3000;
        quote.Total_Discount__c = 50;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.submitQuoteForApproval(quote.Id, 'test submit comment','');
        Test.stopTest();
    }

    @isTest
    public static void submitQuoteForApprovalDiscountTest(){

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu__Previewed_SubTotal__c = 6000;
        quote.Total_List_Price__c = 7000;
        quote.zqu__PaymentTerm__c = null;
        quote.Irregular_Frequency__c = false;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.submitQuoteForApproval(quote.Id, 'test submit comment','');
        Test.stopTest();
    }

    @isTest
    public static void submitQuoteForApprovalAllTest(){

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu__Previewed_SubTotal__c = 60000;
        quote.Total_List_Price__c = 70000;
        quote.payment_frequency1__c = 'Annual';
        quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
        quote.Irregular_Frequency__c = false;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.submitQuoteForApproval(quote.Id, 'test submit comment','');
        Test.stopTest();
    }

    @isTest
    public static void submitQuoteForApprovalLastWithCommentTest(){

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu__Previewed_SubTotal__c = 60000;
        quote.Total_List_Price__c = 70000;
        quote.payment_frequency1__c = 'Quarterly';
        quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
        quote.Irregular_Frequency__c = false;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.submitQuoteForApproval(quote.Id, 'test submit comment','');
        Test.stopTest();
    }

    @isTest
    public static void submitQuoteForApprovalLastWithoutCommentTest(){

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu__Previewed_SubTotal__c = 60000;
        quote.Total_List_Price__c = 70000;
        quote.payment_frequency1__c = 'Quarterly';
        quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
        quote.Irregular_Frequency__c = false;
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.submitQuoteForApproval(quote.Id, null,'');
        Test.stopTest();
    }



    @isTest
    public static void recallQuoteTermsApprovedReadOnlyTest(){
        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu_Quote_Status__c = 'Terms Approved';
        quote.zqu__SubscriptionType__c = 'New Subscription';
        quote.RecordTypeId =Utility.getRecordTypeIdForObject(quote.getSObjectType(), 'ReadOnly');
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.recallQuote(quote.Id);
        Test.stopTest();
    }

    @isTest
    public static void recallQuoteTermsApprovedTest(){
        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu_Quote_Status__c = 'Terms Approved';
        update quote;
        ZQuoteService service = new ZQuoteService();

        Test.startTest();
        service.recallQuote(quote.Id);
        Test.stopTest();
    }

    @isTest
    public static void recallQuoteAmendSubscriptionTest(){
        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu_Quote_Status__c = 'Terms Approved';
        quote.zqu__SubscriptionType__c = 'Amend Subscription';
        quote.RecordTypeId =Utility.getRecordTypeIdForObject(quote.getSObjectType(), 'ReadOnly');
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        service.recallQuote(quote.Id);
        Test.stopTest();
    }

    @isTest
    public static void recallQuoteContractSignedManuallyTest(){
        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu_Quote_Status__c = 'Contract Signed Manually';
        update quote;
        ZQuoteService service = new ZQuoteService();
        String errorMessage;

        Test.startTest();
        try{
            service.recallQuote(quote.Id);
        }
        catch(Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Status \'Contract Signed Manually\' cannot be recalled', errorMessage);
    }

    @isTest
    static void validateSubscriptionTest(){

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        quote.Is_from_existing_Billing_Account__c = false;
        quote.zqu_Quote_Status__c = 'Contract Signed Manually';
        update quote;
        Test.startTest();
        ZQuoteService.validateSubscription(quote.id);
        Test.stopTest();
    }

    public static MetadataService.IReadResult mockReadMetadataServiceCallout(String type_x,String[] fullNames) {
        MetadataService.IReadResult readResult;
        if (type_x == 'CustomField') {
            MetadataService.CustomValue customValue1 = new MetadataService.CustomValue();
            MetadataService.CustomValue customValue2 = new MetadataService.CustomValue();
            if (fullNames.contains('zqu__Quote__c.'+Base_Product_Configuration__c.getInstance('Controlling field name').Value__c)) {
                customValue1.label = 'BPCO_Label1';
                customValue1.fullName = 'BPCO_Value1';
                customValue2.label = 'BPCO_Label2';
                customValue2.fullName = 'BPCO_Value2';
            } else if (fullNames.contains('zqu__Quote__c.'+Base_Product_Configuration__c.getInstance('Controlled field name').Value__c)) {
                customValue1.label = 'BPC_Label1';
                customValue1.fullName = 'BPC_Value1';
                customValue2.label = 'BPC_Label2';
                customValue2.fullName = 'BPC_Value2';
            }

            List<MetadataService.CustomValue> value = new List<MetadataService.CustomValue>();
            value.add(customValue1);
            value.add(customValue2);

            MetadataService.ValueSetValuesDefinition valueSetDefinition = new MetadataService.ValueSetValuesDefinition();
            valueSetDefinition.value = value;

            MetadataService.ValueSet valueSet = new MetadataService.ValueSet();
            valueSet.valueSetDefinition = valueSetDefinition;
            if (fullNames.contains('zqu__Quote__c.'+Base_Product_Configuration__c.getInstance('Controlled field name').Value__c)) {
                String controllingFieldValue = Base_Product_Configuration__c.getInstance('Controlling field name').Value__c;

                MetadataService.ValueSettings mdPicklistDependency1 = new MetadataService.ValueSettings();
                mdPicklistDependency1.valueName ='Value1';
                mdPicklistDependency1.controllingFieldValue = new String[] {controllingFieldValue};

                MetadataService.ValueSettings mdPicklistDependency2 = new MetadataService.ValueSettings();
                mdPicklistDependency2.valueName ='Value2';
                mdPicklistDependency2.controllingFieldValue = new String[] {controllingFieldValue};

                valueSet.valueSettings = new List <MetadataService.ValueSettings> {mdPicklistDependency1,mdPicklistDependency2};
            }

            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.valueSet = valueSet;

            List<MetadataService.CustomField> records = new List<MetadataService.CustomField>();
            records.add(customField);

            MetadataService.ReadCustomFieldResult readCfResult = new MetadataService.ReadCustomFieldResult();
            readCfResult.records = records;
            readResult = readCfResult;
        } else if(type_x == 'CustomObject') {
            MetadataService.PicklistValue pv = new MetadataService.PicklistValue();           
            pv.fullName = 'TestPicklistValueFullName';
            pv.default_x = false;

            MetadataService.RecordTypePicklistValue  rtpv = new MetadataService.RecordTypePicklistValue ();
            rtpv.picklist = Base_Product_Configuration__c.getInstance('Controlling field name').Value__c;
            rtpv.values = new List<MetadataService.PicklistValue> {pv};
            
            MetadataService.RecordType rt = new MetadataService.RecordType();
            rt.fullName = 'TestRecordType';
            rt.picklistValues = new List <MetadataService.RecordTypePicklistValue> {rtpv};

            MetadataService.CustomObject customObject = new MetadataService.CustomObject();
            customObject.recordTypes = new List <MetadataService.RecordType>{rt};

            List<MetadataService.CustomObject> records = new List<MetadataService.CustomObject>();
            records.add(customObject);

            MetadataService.ReadCustomObjectResult readCoResult = new MetadataService.ReadCustomObjectResult();
            readCoResult.records = records;
            readResult = readCoResult;
        }
        return readResult;
    }

    public static MetadataService.UpsertResult[] mockUpsertMetadataServiceCallout() {
        MetadataService.UpsertResult upsertResult = new MetadataService.UpsertResult();
        upsertResult.success = true;
        return new List<MetadataService.UpsertResult> {upsertResult};
    }

    public static MetadataService.SaveResult[] mockUpdateMetadataServiceCallout() {
        MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
        saveResult.success = true;
        return new List<MetadataService.SaveResult> {saveResult};
    }

    public static MetadataService.DeleteResult[] mockDeleteMetadataServiceCallout() {
        MetadataService.DeleteResult deleteResult = new MetadataService.DeleteResult();
        deleteResult.success = true;
        return new List<MetadataService.DeleteResult> {deleteResult};
    }
   
}