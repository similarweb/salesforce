public without sharing class OppClosedLostFlowController {

    private static final List<String> detailedFields = new List<String>{'Account.Name', 'AccountId', 'Account.SW_Industry__c', 'Cycle__c', 'Cycle_Price__c', 
        					'Original_Renewal_Date__c', 'Type', 'IsClosed', 'Additional_Notes__c', 'Missing_coverage_or_feature__c', 'Missing_Data_or_Feature__c', 
        					'Deal_Lost_To_a_Competitor__c', 'Competitor_Product__c', 'Competition__c', 'Closed_Lost_Reason__c', 'Opp_Will_be_Relevant__c', 'Other_Competitors__c',
        					'Issues_with_Data_We_Show__c', 'Section_in_PRO_w_accuracy_issues__c', 'Country_that_had_issues__c', 'Closed_Lost_Reason_More_details__c',
        					'Primary_Solution__c','Secondary_Solution__c','Secondary_Use_Case__c','Primary_Use_Case__c'};
        
    private static final Map<String, Boolean> detailedFieldsMap = new Map<String, Boolean>{};
        
    private static final Map<String, Schema.SObjectType> globalDescr = Schema.getGlobalDescribe();
    
    @AuraEnabled
    public static Response getOpportunityDetails(String oppId){
        try {
            Map<String, Object> result = new Map<String,Object>();
        
            String query = 'SELECT Id,' + string.join(detailedFields, ',') + ' FROM Opportunity WHERE Id=\'' + oppId + '\'';
            Opportunity opp = Database.query(query); 
            
            result.put('opportunity', opp);
            result.put('solutionFit', getContactSolutionFit(opp.AccountId));
    		return new Response(true, result);
        } catch (Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    		return new Response(false, e.getMessage(), e.getStackTraceString());
        }
    }
    
    private static Set<String> getContactSolutionFit(String accountId){
        Set<String> existingDeparts = new Set<String>();
        
        for (Contact cnt : [select id, Department__c from Contact where AccountId = :accountId]) {
            if (!String.isEmpty(cnt.Department__c ) ) {
                existingDeparts.add(cnt.Department__c);
            }
        }
        System.debug('existing departs ' + existingDeparts);
        return existingDeparts;
    }
    
    @AuraEnabled
    public static Response getPicklistFieldsDetails(String fieldDescString) {
        try{
            System.debug('fieldDesc ' + fieldDescString);
            
            Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>> (); //key - obj Name => {key - pickl field Name => list of values}
        
            List<Object>  fieldDesc = (List<Object>) JSON.deserializeUntyped(fieldDescString);
            for (Object obj : fieldDesc){
                List<Object> fields;
                List<Object> tempFieldValuesList;
                Map<String, Object> objMap = (Map<String, Object>)obj;
                for (String sobjNameKey : objMap.keySet()) {
                    fields = (List<Object>)objMap.get(sobjNameKey);
                    if (!result.containsKey(sobjNameKey)){
                        result.put(sobjNameKey, new Map<String, Object>());
                    }
                    for (Integer i = 0; i < fields.size(); i++){
                        String field = (String)fields[i];
                        if (sobjNameKey == 'Opportunity' && field == 'Closed_Lost_Reason__c') {
                            tempFieldValuesList = getClosedLostReasons();
                        } else {
                            tempFieldValuesList =  getFieldsPicklistValues(sobjNameKey, field);
                        }
                        result.get(sobjNameKey).put(field, tempFieldValuesList);
                    }
                    
                }
            }
            return new Response(true, result);
        } catch (Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    		return new Response(false, e.getMessage(), e.getStackTraceString());
        }
    }
    
    
    public static List<ClosedLostReasonSetting> getClosedLostReasons(){
        List<ClosedLostReasonSetting> reasons = new List<ClosedLostReasonSetting>();
        
        List<OppClosedLostReasonSettings__c> settings = OppClosedLostReasonSettings__c.getAll().values();
        for (OppClosedLostReasonSettings__c sett : settings){
            reasons.add(new ClosedLostReasonSetting(sett));
        }
        reasons.sort();
        
        return reasons;
    }
    
    public static List<PicklistEntry> getFieldsPicklistValues(String sobjectType, String fieldName){
        List<PicklistEntry> result = new List<PicklistEntry>();
        
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap();
        
        List<PicklistEntry> tempEntries;
            if (fieldsMap.containsKey(fieldName) ) {
                Schema.DescribeFieldResult dfr = fieldsMap.get(fieldName).getDescribe();
                if (dfr.getType() == DisplayType.Picklist || dfr.getType() == DisplayType.MultiPicklist ) {
                    for (Schema.PicklistEntry ple : dfr.getPicklistValues()){
                        if (ple.isActive()){
                            result.add(new PicklistEntry(ple.getLabel(), ple.getValue()));
                        }
                    }
                }
            }
        
        return result;
    }
    
    @AuraEnabled 
    public static Response submitOpportunity(String jsonOpp){
        System.debug(jsonOpp); 
        try{
            Opportunity opp = (Opportunity) JSON.deserialize(jsonOpp, Opportunity.class);
            opp.StageName = 'Closed Lost';
            opp.SYS_CloseFlow__c=true;
          	System.debug('opp ' + opp);  
        	System.debug('opp Id' + opp.Id);  
            if (!String.isempty(opp.Opp_Will_be_Relevant__c)){
                opp.Relevant_Task_Creation_Date__c = getTaskCreationDate(opp.Opp_Will_be_Relevant__c);
            }
        
            update opp;
            updateRelatedRequests(opp.Id);
            Flow.Interview flow = Flow.Interview.createInterview('Close_as_False', new Map<String, Object>{'varOpportunityID' => opp.Id});
        	flow.start();        	
        	return new Response(true, opp);
        } catch (Exception e){
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            return new Response(false, e.getMessage(), e.getStackTraceString());
        }
        
    }

    private static void updateRelatedRequests(String opportunityId){
        if(String.isNotBlank(opportunityId)){

            Set<String> requestTypeSet = new Set<String>{
                'Basic Onboarding Package',
                'Standard Onboarding Package',
                'Premium Onboarding Package'
            };

            List<Request__c> requestToUpdateList = [
                SELECT
                    Id
                FROM Request__c
                WHERE RecordType.DeveloperName = 'Solution_Implementation'
                AND Opportunity__c =: opportunityId
                AND Request_Type__c IN: requestTypeSet
                AND Status__c != 'Cancelled'
                AND Status__c != 'Completed'
            ];

            for(Request__c requestObj: requestToUpdateList){
                requestObj.Cancellation_Reason_PickList__c = 'Closed Lost Opportunity';
                requestObj.Status__c = 'Cancelled';
            }

            if(!requestToUpdateList.isEmpty()){
                update requestToUpdateList;
            }
        }
    }
    
    
    public static Response closeOpportunity(String opport){
        Opportunity closedOpp;
        String relevanceValue;
        
        return new Response();
    }
    
    private static Date getTaskCreationDate(String relevance){
        Date newDate = null;
        Pattern p = pattern.compile('([0-9]+).+');
        matcher m = p.matcher(relevance);
        if (m.matches() && m.groupCount() > 0){
            Integer closeDays = Integer.valueOf(m.group(1));
            newDate = Date.today().addDays(closeDays);
        }
        return newDate;
    }
    
    public class ClosedLostReasonSetting implements Comparable{
        @AuraEnabled
        public String index {get;set;}
        @AuraEnabled
        public String groupName {get;set;}
        @AuraEnabled
        public String reasonName {get;set;}
        @AuraEnabled
        public List<String> oppTypes {get;set;}
        
        public ClosedLostReasonSetting(String numb, String groupName, String reasonName, List<String> oppTypes){
            this.index = numb;
            this.groupName 	= groupName;
            this.reasonName = reasonName;
            this.oppTypes = oppTypes;
        }
        
        public ClosedLostReasonSetting(OppClosedLostReasonSettings__c setting){
            this.index = setting.Order_Index__c;
            this.groupName 	= setting.Group_Name__c ;
            this.reasonName = setting.Description__c;
            this.oppTypes = !String.isEmpty(setting.Opportunity_Types__c)  ? setting.Opportunity_Types__c.split(',') : new List<String>();
            if (!this.oppTypes.isEmpty()){
                for (Integer i = 0; i < oppTypes.size(); i++){
                    String t = oppTypes.remove(i);
                    t = t.trim();
                    oppTypes.add(t);
                }
            }
        }
        
        public Integer compareTo(Object second){
            ClosedLostReasonSetting that = (ClosedLostReasonSetting)second;
            Integer thisGroupIndex = Integer.valueOf(this.index.substringBefore('.'));
            Integer thisRecordIndex = Integer.valueOf(this.index.substringAfter('.'));
            
            Integer thatGroupIndex = Integer.valueOf(that.index.substringBefore('.'));
            Integer thatRecordIndex = Integer.valueOf(that.index.substringAfter('.'));
            if (thisGroupIndex == thatGroupIndex)
                return thisRecordIndex > thatRecordIndex ? 1 : thisRecordIndex == thatRecordIndex ? 0 : -1;
            else if (thisGroupIndex < thatGroupIndex)
                return -1;
            else
                return 1;
        }
    }
    
    public class PicklistEntry {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        
        public PicklistEntry(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}