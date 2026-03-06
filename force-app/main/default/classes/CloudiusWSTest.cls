@istest
public class CloudiusWSTest {
  @testSetup
  static void setup() {
    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["lead"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;
  }

  @istest
  public static void test() {
    Account acc = new Account(
      Name = 'Account_for_user',
      Business_unit__c = 'Inside Sales'
    );
    insert acc;

    Opportunity newOpp = new Opportunity(
      AccountId = acc.Id,
      Name = 'Acc1_Opportunity_2',
      Type = 'New Sell',
      Cycle__c = 'Annually',
      CloseDate = DAte.today(),
      Cycle_Price__c = 123,
      StageName = 'Closed Lost',
      Closed_Lost_Reason__c = 'test reason 1',
      Closed_Lost_Reason_More_details__c = 'more details',
      Closed_Lost_Reason_2__c = 'whatever',
      Opp_will_be_relevant__c = '90 days',
      Use_Cases__c = 'Marketing: SEO / Content'
    );
    insert newOpp;
    CloudiusWS.CheckBillingAccount(newOpp.Id);
    CloudiusWS.CheckBillingAccountBasic(newOpp.Id, true);
    CloudiusWS.CheckBillingAccountBasic(newOpp.Id, false);
  }
}
