@istest
public class UserTriggerHandlerTest {
  @istest
  public static void test() {
    Account acc = new Account(
      Name = 'Account_for_user',
      Business_unit__c = 'Inside Sales'
    ); //account whose opps will be visible
    Account acc2 = new Account(
      Name = 'Account_for_user_2',
      Business_unit__c = 'Inside Sales'
    );
    insert new List<Account>{ acc, acc2 };

    Contact cnt = new Contact(
      LastName = 'Contact_for_user',
      Email = 'partner@user.com',
      AccountId = acc.Id
    );
    Contact cnt2 = new Contact(
      LastName = 'Contact_for_user',
      Email = 'partner@user.com',
      AccountId = acc2.Id
    );
    insert new List<Contact>{ cnt, cnt2 };

    List<Opportunity> opps = new List<opportunity>{
      new Opportunity(
        AccountId = acc.Id,
        Name = 'Acc1_Opportunity_1',
        Type = 'New Sell',
        Cycle__c = 'Annually',
        CloseDate = DAte.today(),
        Cycle_Price__c = 123,
        StageName = 'Prospect'
      ),
      new Opportunity(
        AccountId = acc.Id,
        Name = 'Acc1_Opportunity_2',
        Type = 'New Sell',
        Cycle__c = 'Annually',
        CloseDate = DAte.today(),
        Cycle_Price__c = 123,
        StageName = 'Prospect'
      ),
      new Opportunity(
        AccountId = acc2.Id,
        Name = 'Acc2_Opportunity_1',
        Type = 'New Sell',
        Cycle__c = 'Annually',
        CloseDate = DAte.today(),
        Cycle_Price__c = 123,
        StageName = 'Prospect'
      )
    };
    insert opps;

    User communityUser = createUser(cnt);
    insert communityUser;

    List<OpportunityShare> sharings = new List<OpportunityShare>{
      new OpportunityShare(
        OpportunityId = opps[0].Id,
        UserOrGroupId = communityUser.Id,
        OpportunityAccessLevel = 'Read'
      ),
      new OpportunityShare(
        OpportunityId = opps[1].Id,
        UserOrGroupId = communityUser.Id,
        OpportunityAccessLevel = 'Read'
      )
    };
    //Test.startTest();
    UserTriggerHandler.manageNewUserSharings(
      new List<Id>(),
      JSON.serialize(sharings)
    );
    //Test.stopTest();

    /*System.runAs(communityUser) {
            List<Opportunity> userOpps = [select id, name, AccountId from opportunity order by name];
            System.assertEquals(2, userOpps.size());
        }*/
  }

  private static User createUser(Contact cnt) {
    Profile profileItem = [
      SELECT Id
      FROM Profile
      WHERE Name = :Label.Community_User_Profile_Name
    ];
    User u = new User(
      Alias = 'standt',
      Email = 'standarduser@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profileItem.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'adminuser1@testorg.com',
      ContactId = cnt.Id
    );
    return u;
  }
}
