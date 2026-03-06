/**
 * Created by Alon.Shalev on 2/18/2024.
 */

@isTest
public with sharing class LeadConvertInvocableTest {

    @isTest
    static void testLeadConversion() {
        TestDataFactory.createInferredSolutionSettings_CS();
        // Setup: Create a test lead
        Lead testLead = new Lead(
                LastName = 'Test',
                Company = 'TestCompany',
                Status = 'Open - Not Contacted',
                Email = 'test@gmail.com'
        );
        insert testLead;

        // Prepare the input for the invocable method
        List<LeadConvertInvocable.LeadConvertInput> inputs = new List<LeadConvertInvocable.LeadConvertInput>();
        LeadConvertInvocable.LeadConvertInput input = new LeadConvertInvocable.LeadConvertInput();
        input.LeadId = testLead.Id;
        inputs.add(input);
        // Execute the invocable method
        Test.startTest();
        List<LeadConvertInvocable.LeadConvertOutput> outputs = LeadConvertInvocable.convertLead(inputs);
        Test.stopTest();
    }

}