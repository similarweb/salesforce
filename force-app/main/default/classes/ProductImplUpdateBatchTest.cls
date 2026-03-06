@istest
public class ProductImplUpdateBatchTest {
  @istest
  public static void test() {
    Account acc1 = new Account(Name = 'Test1', Business_Unit__c = 'Enterprise');
    Account acc2 = new Account(Name = 'Test2', Business_Unit__c = 'Enterprise');
    Account acc3 = new Account(Name = 'Test3', Business_Unit__c = 'Enterprise');
    insert new List<Account>{ acc1, acc2, acc3 };

    Product_Implementation__c impl1 = new Product_Implementation__c(
      Account__c = acc1.ID
    );
    Product_Implementation__c impl21 = new Product_Implementation__c(
      Account__c = acc2.ID
    );
    //Product_Implementation__c impl22 = new Product_Implementation__c(Account__c = acc2.ID);
    insert new List<Product_Implementation__c>{ impl1, impl21 }; //, impl22

    Contact cnt1 = new Contact(LastName = 'Test Contact1', AccountID = acc1.Id);
    Contact cnt2 = new Contact(LastName = 'Test Contact2', AccountID = acc2.Id);
    insert new List<Contact>{ cnt1, cnt2 };
    System.assertEquals(null, cnt1.ProductImplementation__c);

    ProductImplUpdateBatch batch = new ProductImplUpdateBatch();
    Test.startTest();
    cnt1.AccountId = acc2.Id;
    cnt2.AccountId = acc3.Id;
    update new List<Contact>{ cnt1, cnt2 };

    Database.executeBatch(batch);
    Test.stopTest();

    batch.processContacts(new List<Id>{ cnt1.Id, cnt2.Id });

    Contact cntUpdated = [
      SELECT id, ProductImplementation__c
      FROM Contact
      WHERE Id = :cnt1.Id
    ];
    System.assertEquals(impl21.Id, cntUpdated.ProductImplementation__c);
  }

  @istest
  public static void testSchedule() {
    Test.startTest();
    System.schedule(
      'Test product impl update',
      '20 30 8 10 2 ?',
      new ProductImplUpdateBatch()
    );
    Test.stopTest();
  }
}
