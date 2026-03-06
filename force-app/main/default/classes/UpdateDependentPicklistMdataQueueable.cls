public with sharing class UpdateDependentPicklistMdataQueueable implements Queueable, Database.AllowsCallouts {
    
    private String controllingFieldValue;
    private String dependentPicklistApiName;
    private String controllingPicklistApiName;
    private List<String> fullNameList;
    private MetadataServiceFacade service;

    public UpdateDependentPicklistMdataQueueable(String controllingFieldValue
                                               , MetadataServiceFacade service
                                               , String dependentPicklistApiName
                                               , String controllingPicklistApiName
                                               , List<String> fullNameList) {
        this.controllingFieldValue = controllingFieldValue;
        this.service = service;
        this.dependentPicklistApiName = dependentPicklistApiName;
        this.controllingPicklistApiName = controllingPicklistApiName;
        this.fullNameList = fullNameList;
    }

    public void execute(QueueableContext context) {
        Boolean isLock;
        MetadataService.CustomField customField = service.obtainCustomField(dependentPicklistApiName);

        List<MetadataService.ValueSettings> newValueSettings = service.addDependentPicklistValues(customField,fullNameList,controllingFieldValue);
        System.debug('ccc ' +JSON.serializePretty(newValueSettings));
        System.debug('ccc ' + dependentPicklistApiName);
        System.debug('ccc ' + controllingPicklistApiName);
        System.debug('ccc ' + fullNameList);
        System.debug('ccc ' + JSON.serializePretty(customField));
        // ----- Workaround due to SF bug - you can add dependent values via mdApi, but cannoy remove them.
        // To solve it - update metadata with removing controlling field, and update again with propper data.
        /* customField.valueSet.controllingField = null;
        customField.valueSet.valueSettings = null;
        List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.updateMetadata( new MetadataService.Metadata[] { customField },false);
        isLock=service.checkForLockErrors(lstResults); */
        // -----
        customField.valueSet.valueSettings = newValueSettings;        
        customField.valueSet.controllingField = controllingPicklistApiName;
        /* System.debug(JSON.serializePretty(customField.valueSet)); */
        System.debug('valueSet.length' + customField.valueSet.valueSettings.size());
        List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.updateMetadata( new MetadataService.Metadata[] { customField },false);
        isLock=service.checkForLockErrors(lstResults);
        if (isLock && !Test.isRunningTest()) {
            System.enqueueJob(new UpdateDependentPicklistMdataQueueable(controllingFieldValue,service,dependentPicklistApiName,controllingPicklistApiName,fullNameList));
        }
    }
}