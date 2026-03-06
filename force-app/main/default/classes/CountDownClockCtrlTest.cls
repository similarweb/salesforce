@IsTest
public class CountDownClockCtrlTest {


    @IsTest
    static void testGetMQLStatusHoursMap() {
        // Call the method being tested
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Lead lead = new Lead(
                FirstName = 'Test',
                LastName = 'Lead',
                Company = 'Test Company',
                First_MQL_Date__c = Date.today(),
                SW_Fit_Score__c = 'B',
                First_Owner_Assigned_Timestamp__c = System.now(),
                Email = 'lead1@gmail.com'
        );
        insert lead;

        Map<String, Object> result = CountDownClockCtrl.getMQLInfoFromApex('lead',lead.id);

        // Verify the map is not null and contains the expected entries
        System.assertNotEquals(null, result, 'The result map should not be null');

    }
}