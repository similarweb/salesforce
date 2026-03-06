@isTest
public class UpdateMdataQueueableTest {
  @isTest
  public static void testUpdate() {
    MetadataServiceFacade service = (MetadataServiceFacade) MockUtil.obtainMockProvider(
      MetadataServiceFacade.class
    );
    Test.startTest();
    System.enqueueJob(
      new UpdateMdataQueueable(
        service,
        new List<MetadataService.Metadata>(),
        'UPDATE'
      )
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpsert() {
    MetadataServiceFacade service = (MetadataServiceFacade) MockUtil.obtainMockProvider(
      MetadataServiceFacade.class
    );
    Test.startTest();
    System.enqueueJob(
      new UpdateMdataQueueable(
        service,
        new List<MetadataService.Metadata>(),
        'UPSERT'
      )
    );
    Test.stopTest();
  }

  @isTest
  public static void testDelete() {
    MetadataServiceFacade service = (MetadataServiceFacade) MockUtil.obtainMockProvider(
      MetadataServiceFacade.class
    );
    Test.startTest();
    System.enqueueJob(
      new UpdateMdataQueueable(service, 'test', new List<String>{ 'test' })
    );
    Test.stopTest();
  }
}
