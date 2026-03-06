public with sharing class UpdateRtMdataQueueable implements Queueable, Database.AllowsCallouts {
  private MetadataServiceFacade service;
  private List<MetadataService.RecordType> recordTypes;
  private String baseProductPicklistName;

  public UpdateRtMdataQueueable(
    MetadataServiceFacade service,
    List<MetadataService.RecordType> recordTypes,
    String baseProductPicklistName
  ) {
    this.service = service;
    this.recordTypes = recordTypes;
    this.baseProductPicklistName = baseProductPicklistName;
  }

  public void execute(QueueableContext context) {
    if (recordTypes.isEmpty()) {
      throw new RtListIsEmptyException();
    }
    MetadataService.RecordType rt = recordTypes[0];
    System.debug(JSON.serializePretty(rt.picklistValues));
    List<MetadataServiceFacade.MetadataDmlResultWrapper> svResults = service.updateMetadata(
      new List<MetadataService.Metadata>{ rt },
      false
    );
    // String errors= service.obtainErrors(svResults);
    Boolean isLock = service.checkForLockErrors(svResults);
    if (!isLock) {
      recordTypes.remove(0);
    }
    if (!recordTypes.isEmpty()) {
      System.enqueueJob(
        new UpdateRtMdataQueueable(
          service,
          recordTypes,
          baseProductPicklistName
        )
      );
    }
  }

  public class RtListIsEmptyException extends Exception {
  }
}
