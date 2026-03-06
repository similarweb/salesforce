@istest
public class ContactOwnerChangeBatchTest {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
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
    islvcl.Name = 'department__c';
    islvcl.Is_Valid__c = true;
    insert islvcl;

    Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
    islvcl2.Name = 'sw_industry__c';
    islvcl2.Is_Valid__c = true;
    insert islvcl2;

    InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
    islcvcl.Name = 'department__c';
    islcvcl.Is_Valid__c = true;
    insert islcvcl;

    InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
    islcvcl2.Name = 'sw_industry__c';
    islcvcl2.Is_Valid__c = true;
    insert islcvcl2;

    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["account","lead"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;
  }

  @istest
  static void testScheduler() {
    Test.startTest();
    System.schedule(
      'testtesttestContactOwnerChangeBatch',
      '0 42 16 * * ?',
      new ContactOwnerChangeBatch()
    );
    Test.stopTest();
  }

  @istest
  static void testChange() {
    RecordType accountRecordType = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'Default'
    ][0];
    Account acc = new Account(
      RecordType = accountRecordType,
      Name = 'Test',
      Business_Unit__c = 'Inside Sales'
    );
    insert acc;
    Contact cnt = new Contact(
      LastName = 'Contact',
      AccountId = acc.Id,
      Email = 'test@gmail.com'
    );
    insert cnt;
    List<Task> tasks = new List<Task>{
      new Task(
        Subject = 'Test Subj1',
        Priority = 'Normal',
        Status = 'Not Started',
        WhoId = cnt.Id
      ),
      new Task(
        Subject = 'Test Subj2',
        Priority = 'Normal',
        Status = 'Not Started',
        WhoId = cnt.Id
      ),
      new Task(
        Subject = 'Test Subj2',
        Priority = 'Normal',
        Status = 'Completed',
        WhoId = cnt.Id
      ),
      new Task(
        Subject = 'Test Subj with Contact us form',
        Priority = 'Normal',
        Status = 'Deferred',
        WhoId = cnt.Id
      ),
      new Task(
        Subject = 'Test Subj with Contact us form 2',
        Priority = 'Normal',
        Status = 'In Progress',
        WhoId = cnt.Id
      )
    };
    insert tasks;

    Id runningUser = UserInfo.getUserId();
    User u = [
      SELECT Id
      FROM User
      WHERE Id != :runningUser AND isActive = TRUE
      LIMIT 1
    ];
    cnt.OwnerId = u.Id;
    update cnt;

    Test.startTest();
    //System.schedule('test ' + datetime.now(), '0 10 20 * * ?', new ContactOwnerChangeBatch(new Set<Id>{cnt.Id}));
    Database.executeBatch(
      new ContactOwnerChangeBatch(
        new Map<Id, Id>{ cnt.Id => UserInfo.getUserId() }
      )
    );
    Test.stopTest();

    String successSubj = 'Test Subj with Contact us form 2';
    Task successTask = [
      SELECT Id, OwnerId, Subject
      FROM Task
      WHERE WhoId = :cnt.ID AND Status = 'In Progress'
      LIMIT 1
    ];
    System.assertEquals(u.Id, successTask.OwnerId);
    System.assertEquals(
      'Test Subj with Contact us form 2',
      successTask.Subject
    );
    System.assert(
      [
          SELECT Id, OwnerId, Subject
          FROM Task
          WHERE WhoId = :cnt.ID AND Status = 'Deferred'
          LIMIT 1
        ]
        .get(0)
        .OwnerId != u.Id
    );
    System.assert(
      [
          SELECT Id, OwnerId, Subject
          FROM Task
          WHERE WhoId = :cnt.ID AND Subject = 'Test Subj2'
          LIMIT 1
        ]
        .get(0)
        .OwnerId != u.Id
    );
  }
}
