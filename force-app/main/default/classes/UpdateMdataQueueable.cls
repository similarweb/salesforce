public with sharing class UpdateMdataQueueable implements Queueable, Database.AllowsCallouts {
  List<MetadataService.Metadata> metadataList;
  MetadataServiceFacade service;
  String mode;
  String type;
  List<String> metadataNameList;

  public UpdateMdataQueueable(
    MetadataServiceFacade service,
    List<MetadataService.Metadata> metadataList,
    String mode
  ) {
    this.metadataList = metadataList;
    this.mode = mode;
    this.service = service;
  }

  public UpdateMdataQueueable(
    MetadataServiceFacade service,
    String type,
    List<String> metadataNameList
  ) {
    this.type = type;
    this.metadataNameList = metadataNameList;
    this.mode = 'DELETE';
    this.service = service;
  }

  public void execute(QueueableContext context) {
    String errors = '';
    if (mode == 'UPDATE') {
      List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.updateMetadata(
        metadataList,
        true
      );
      errors = service.obtainErrors(lstResults);
    } else if (mode == 'UPSERT') {
      List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.upsertMetadata(
        metadataList,
        true
      );
      errors = service.obtainErrors(lstResults);
    } else if (mode == 'DELETE') {
      List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.deleteMetadata(
        type,
        metadataNameList,
        true
      );
      errors = service.obtainErrors(lstResults);
    }
    /*
        if (String.isNotBlank(errors)) {
            System.debug('errors: ' + errors);
            if (mode == 'UPDATE' || mode == 'UPSERT') {
                System.enqueueJob(new UpdateMdataQueueable(service,metadataList,mode));
            } else if(mode == 'DELETE'){
                System.enqueueJob(new UpdateMdataQueueable(service,type,metadataNameList));
            }            
        } 
        */
  }
}
