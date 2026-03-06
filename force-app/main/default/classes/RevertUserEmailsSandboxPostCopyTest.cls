/**
 * @author Itzik Winograd
 * @date 10/2021
 * @description Test class for  RevertUserEmailsSandboxPostCopy
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
private class RevertUserEmailsSandboxPostCopyTest {
  /**
   * @author Itzik Winograd
   * @date 10/21
   * @description: Insert users and add them to the 'Sandbox Refresh Users' group
   * @Expected1: after the "refresh", these users will not have invalid on their emails
   * @Expected2: Cant be checked - after the "refresh", the profile that was used above will have IsSSOEnabled=false
   */
  @isTest
  static void test_post_copy() {
    Profile p = [SELECT id FROM Profile WHERE IsSSOEnabled = TRUE LIMIT 1];

    User user1;
    User user2;

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
    System.runAs(new User(id = UserInfo.getUserId())) {
      user1 = newUser(p.id, 'Alpha', 'User 1', 'user_1@salesforce.com.invalid');
      user2 = newUser(p.id, 'Beta', 'User 2', 'user_2@salesforce.com.invalid');
      insert new List<User>{ user1, user2 };

      Id sandboxGroupId = [
        SELECT Id
        FROM Group
        WHERE Name LIKE 'Sandbox Refresh Users'
        LIMIT 1
      ]
      .Id;
      GroupMember gm1 = new GroupMember(
        GroupId = sandboxGroupId,
        UserOrGroupId = user1.Id
      );
      GroupMember gm2 = new GroupMember(
        GroupId = sandboxGroupId,
        UserOrGroupId = user2.Id
      );
      insert new List<GroupMember>{ gm1, gm2 };
    }

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RevertUserEmailMock());
    Test.testSandboxPostCopyScript(
      new RevertUserEmailsSandboxPostCopy(), // apex class to run
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationName()
    );

    Test.stopTest();

    user1 = [SELECT id, email FROM User WHERE id = :user1.id];
    System.assertEquals('user_1@salesforce.com', user1.email);

    user2 = [SELECT id, email FROM User WHERE id = :user2.id];
    System.assertEquals('user_2@salesforce.com', user2.email);

    //IsSSOEnabled - cant be tested. we dont actually change existing profiles.
  }

  //create user
  private static User newUser(
    ID profileId,
    String firstName,
    String lastName,
    String email
  ) {
    Integer rand = Math.round(Math.random() * 1000);
    return new User(
      isActive = true,
      profileId = profileId,
      alias = firstName.substring(0, 1) + lastName.substring(1, 5),
      firstName = firstName,
      lastName = lastName,
      email = email,
      username = rand + email,
      emailEncodingKey = 'UTF-8',
      languageLocaleKey = 'en_US',
      localeSidKey = 'en_US',
      timeZoneSidKey = 'America/Chicago'
    );
  }

  private class RevertUserEmailMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(200);
      return res;
    }
  }
}
