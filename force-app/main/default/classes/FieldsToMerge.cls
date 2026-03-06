public class FieldsToMerge implements Queueable {

    private Map<String,Object> leadCaptureWrpMap;
    private LeadCaptureService.leadCaptureWrapper leadCaptureWrp;

    public FieldsToMerge(Map<String,Object> leadCaptureWrpMap) {
        this.leadCaptureWrpMap = leadCaptureWrpMap;
    }

    public FieldsToMerge(LeadCaptureService.leadCaptureWrapper lcw) {
        this.leadCaptureWrp = lcw;
    }

    public void execute(QueueableContext context) {
        List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
        Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
        for(Feature_Flag_Setting__mdt flag : flags){
            flagsMap.put(flag.Process_Name__c,flag);
        }
        if(leadCaptureWrpMap != null){
            LeadCaptureService.leadCaptureResponseWrapper lcrw = LeadCaptureServiceHandler.handleTouchCall(leadCaptureWrpMap,flagsMap);
            LeadCaptureServiceHandler.recordLog(true, lcrw, new RestRequest(), leadCaptureWrpMap,true);
        }else{
            LeadCaptureService.leadCaptureResponseWrapper lcrw = LeadCaptureServiceHandler.handleTouchCallWithWrapper(leadCaptureWrp,flagsMap);
            LeadCaptureServiceHandler.recordLogWithWrapper(true, lcrw, new RestRequest(), leadCaptureWrp,true);
        }

    }
}