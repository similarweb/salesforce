@isTest
public class UpdateRtMdataQueueableTest {
  public static Boolean isRunning = false;

  @isTest
  public static void test() {
    isRunning = true;
    String baseProductPicklistName = 'testName';
    MetadataServiceFacade service = (MetadataServiceFacade) MockUtil.obtainMockProvider(
      MetadataServiceFacade.class
    );
    MetadataService.PicklistValue pv = new MetadataService.PicklistValue();
    pv.fullName = 'TestPicklistValueFullName';
    pv.default_x = false;

    MetadataService.RecordTypePicklistValue rtpv = new MetadataService.RecordTypePicklistValue();
    rtpv.picklist = baseProductPicklistName;
    rtpv.values = new List<MetadataService.PicklistValue>{ pv };

    MetadataService.RecordType rt = new MetadataService.RecordType();
    rt.fullName = 'TestRecordType';
    rt.picklistValues = new List<MetadataService.RecordTypePicklistValue>{
      rtpv
    };
    List<MetadataService.RecordType> recordTypes = new List<MetadataService.RecordType>{
      rt
    };

    Test.startTest();
    System.enqueueJob(
      new UpdateRtMdataQueueable(service, recordTypes, baseProductPicklistName)
    );
    Test.stopTest();
  }
}
