@isTest
private class FieldsToMergeTest {

    @TestSetup
    static void setup() {
        SFMC_Processed_by_Distribution__c processedByDistribution8 = setDistribution(80, 8, 'AI / PI');
        insert processedByDistribution8;
        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
        iss.Name='Default Value';
        iss.Value__c='Sales';
        insert iss;
    }


    private static SFMC_Processed_by_Distribution__c setDistribution(Decimal SFMCPercent, Decimal counter, String solution){
        return new SFMC_Processed_by_Distribution__c(
                Processed_by_SFMC__c = SFMCPercent,
                Initial_Date__c = date.today() - 1,
                Counter__c = counter,
                Solution__c = solution
        );
    }

    @isTest
    static void testFieldsToMerge() {

        // Create test data
        Lead lead1 = new Lead(
                LastName='Doe 1',
                Company='ABC Company 1',
                email='jumbo101@mumbo.com'
        );
        Lead lead2 = new Lead(
                LastName='Smith 2',
                Company='ABC Company 2',
                email='jumbo102@mumbo.com'
        );
        insert lead1;
        insert lead2;

        // Create input data for queueable

        // Enqueue the queueable
        FieldsToMerge queueable = new FieldsToMerge(new LeadCaptureService.leadCaptureWrapper());
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

    }

    @isTest
    static void testFieldsToMergeWithVersion3() {

        // Create test data
        Lead lead1 = new Lead(
                LastName='Doe 1',
                Company='ABC Company 1',
                email='jumbo101@mumbo.com'
        );
        Lead lead2 = new Lead(
                LastName='Smith 2',
                Company='ABC Company 2',
                email='jumbo102@mumbo.com'
        );
        insert new List<Lead>{lead2,lead1};

        // Create input data for queueable

        // Enqueue the queueable
        FieldsToMerge queueable = new FieldsToMerge(new Map<String,Object>());
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

    }
}