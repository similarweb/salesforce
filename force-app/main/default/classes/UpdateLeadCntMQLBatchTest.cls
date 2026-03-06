@istest
public class UpdateLeadCntMQLBatchTest {
  @istest
  public static void test() {
    Account acc = new Account(Name = 'Test acc');
    insert acc;
    Account acc2 = new Account(Name = 'SimilarWEB');
    insert acc2;

    Contact cnt1 = new Contact(
      AccountId = acc.Id,
      LastName = 'Test',
      Status__c = 'Unqualified',
      HasOptedOutOfEmail = false
    ); //should not pass in processing as status not valid
    Contact cnt2 = new Contact(
      AccountId = acc2.Id,
      LastName = 'Test2',
      Status__c = 'Qualified',
      HasOptedOutOfEmail = false
    ); //should not pass in processing as account name not valid
    Contact cnt3 = new Contact(
      AccountId = acc.Id,
      LastName = 'Test3',
      Status__c = 'Qualified',
      HasOptedOutOfEmail = false
    ); //should pass
    Contact cnt4 = new Contact(
      AccountId = acc.Id,
      LastName = 'Test3',
      Status__c = 'Qualified',
      HasOptedOutOfEmail = false,
      MQL__c = true
    );

    Lead ld1 = new Lead(
      Company = 'Similarweb',
      LastName = 'Lead1',
      Status = 'Unqualified',
      HasOptedOutOfEmail = false
    );
    Lead ld2 = new Lead(
      Company = 'Test',
      LastName = 'Lead2',
      Status = 'Unqualified',
      HasOptedOutOfEmail = false
    );
    Lead ld3 = new Lead(
      Company = 'Test',
      LastName = 'Lead3',
      Status = 'Qualified',
      HasOptedOutOfEmail = false
    ); //should pass
    Lead ld4 = new Lead(
      Company = 'Test',
      LastName = 'Lead4',
      Status = 'Qualified',
      HasOptedOutOfEmail = false,
      MQL__c = true
    );

    insert new List<Sobject>{ cnt1, cnt2, cnt3, cnt4, ld1, ld2, ld3, ld4 };

    Campaign cmp = new Campaign(Name = 'Test CMP', Department__c = 'Marketing');
    insert cmp;

    List<CampaignMember> members = new List<CampaignMember>{
      new CampaignMember(
        ContactId = cnt1.Id,
        Rating__c = 4,
        CampaignId = cmp.Id
      ),
      new CampaignMember(
        ContactId = cnt2.Id,
        Rating__c = 5,
        CampaignId = cmp.Id
      ),
      //new CampaignMember(ContactId=cnt3.Id, Rating__c = 2, CampaignId = cmp.Id), 		//should not pass as ratng low
      new CampaignMember(
        ContactId = cnt3.Id,
        Rating__c = 4,
        CampaignId = cmp.Id
      ), //should pass
      new CampaignMember(
        ContactId = cnt4.Id,
        Rating__c = 4,
        CampaignId = cmp.Id
      ),
      new CampaignMember(LeadId = ld1.Id, Rating__c = 4, CampaignId = cmp.Id),
      new CampaignMember(LeadId = ld2.Id, Rating__c = 4, CampaignId = cmp.Id),
      //new CampaignMember(LeadId=ld3.Id, Rating__c = 1, CampaignId = cmp.Id),
      new CampaignMember(LeadId = ld3.Id, Rating__c = 5, CampaignId = cmp.Id), //should pass
      new CampaignMember(LeadId = ld4.Id, Rating__c = 5, CampaignId = cmp.Id)
    };
    insert members;

    Test.startTest();
    String query =
      'select id, ContactId, Contact.MQL__c, LeadId, Lead.MQL__c, Rating__c, Contact.Status__c, Lead.Status, CompanyOrAccount, ' +
      'Contact.HasOptedOutOfEmail, Contact.Account.Name, Lead.HasOptedOutOfEmail, Lead.Company from CampaignMember ' +
      'where (Rating__c = 4 or Rating__c = 5) and ((Contact.MQL__c = false and Contact.Status__c !=  \'Unqualified\' and Contact.HasOptedOutOfEmail = false )' +
      ' or ( Lead.MQL__c = false and Lead.Status != \'Unqualified\' and Lead.HasOptedOutOfEmail = false))  and CompanyOrAccount != \'SimilarWeb\'';
    System.debug('s ' + Database.query(query));
    Database.executeBatch(new UpdateLeadCntMQLBatch());
    Test.stopTest();

    List<Contact> updatedCnt = [
      SELECT id, MQL__c, LastName
      FROM Contact
      WHERE MQL__c = TRUE
      ORDER BY lastname
    ];
    System.assertEquals(2, updatedCnt.size());
    System.assertEquals(updatedCnt[0].Lastname, 'Test3');
  }
}
