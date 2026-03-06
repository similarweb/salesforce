public class JourneyController {
    @AuraEnabled
    public static String obtainJorneySettingList(){
        //Map<String,JourneySetting__c> journeySettings = JourneySetting__c.getAll();
        //Set<String> journeySettingsNameSet = journeySettings.keySet();
        /*Set<String> journeySettingsNameSet = new Set<String>();
        journeySettingsNameSet.add('Standard');
        journeySettingsNameSet.add('Fast Track');
        journeySettingsNameSet.add('LDR');       
        journeySettingsNameSet.add('Freemail');*/
        
        List<String> journeySettingsNameList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Orchestration_Journey__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            journeySettingsNameList.add(pickListVal.getLabel());
        }     
        
        return JSON.serialize(journeySettingsNameList);
    }
    
	@AuraEnabled
    public static String obtainLeadList(String journeyName,String stepName, Boolean isReport){
        System.debug('isReport ' + isReport);
       	String stepQuery =  JourneyHelper.getStepQuery(journeyName,stepName);
        System.debug('stepQuery ' + stepQuery);
        DetailedFunnelTable detailedFunnelTable = JourneyHelper.generateStepInfo(journeyName, stepName, stepQuery,isReport);
        ResponseWrapper responseWrapper = new ResponseWrapper(true,detailedFunnelTable);        
        return JSON.serialize(responseWrapper);
    }
    
    @AuraEnabled
    public static String obtainPathAtributes(string journeyName){ 
        String query = JourneyHelper.getQuery(journeyName);
        System.debug('query ' + query);
        Map<String,List<Lead>> stepToLeadMap = JourneyHelper.getRecordsPerStep(journeyName,query);
        Map<String,List<Lead>> recordsDone = JourneyHelper.getRecordsDone(journeyName,query);
        Map<String,Long> calculatedSLA = JourneyHelper.calculateSLA(recordsDone);
        Path path = JourneyHelper.generateGenericPath(stepToLeadMap,journeyName,calculatedSLA);     
        System.debug('path ' + path.steps);
        ResponseWrapper responseWrapper = new ResponseWrapper(true,path);                 
        return JSON.serialize(responseWrapper);
    }
    
    @AuraEnabled
    public static String obtainLeadListByParam(String searchParam, String fieldParam){ 
        //String query = 'SELECT Id,Name,Email FROM Lead WHERE ' +fieldParam +  '= :searchParam';
        //List<Lead> leadList = Database.query(query);
        System.debug('searchParam ' + searchParam);
        List<Lead> leadList = JourneyHelper.generateLeadInfo(searchParam,fieldParam);
        Map<String,List<Lead>> leadToStepMapp = JourneyHelper.createLeadToStepMapping(leadList);
        Path path = JourneyHelper.generateGenericPath(leadToStepMapp,leadList);
        
        ResponseWrapper responseWrapper = new ResponseWrapper(true,path);
        return JSON.serialize(responseWrapper);
    }
    
    @AuraEnabled
    public static String obtainJourneyPathSettings(String journeyName){ 
       	List<Journey_Path_Setting__c> journeySettings = JourneyHelper.getJourneyPathSettings(journeyName);
        ResponseWrapper responseWrapper = new ResponseWrapper(true,journeySettings);
        return JSON.serialize(responseWrapper);
    }
    
    @AuraEnabled
    public static void updateJourneyPathSettings(List<Journey_Path_Setting__c> journeySettings){        
        update journeySettings;        
    }
    
    
    public class Step{
		public String stepName{get;set;}
        public Integer leadCount{get;set;}
        public String SLA{get;set;}
        public String averageProcessTime{get;set;}
        public Boolean done{get;set;}

		public Step(String stepName, Integer leadCount, String SLA, String averageProcessTime, Boolean done){
			this.stepName = stepName;
            this.leadCount = leadCount;
            this.SLA = SLA;
            this.averageProcessTime = averageProcessTime;
            this.done = done;
		}
	}
    
    public class DetailedFunnelTable{
		public String journeyName{get;set;}
        public String step{get;set;}
        public Integer queue{get;set;}
        public DateTime averageTimeOnStep{get;set;}
        public List<Lead> leads{get;set;}

		public DetailedFunnelTable(String journeyName, String step, Integer queue, DateTime averageTimeOnStep, List<Lead> leads){
			this.journeyName = journeyName;
            this.step = step;
            this.queue = queue;
            this.averageTimeOnStep = averageTimeOnStep;
            this.leads = leads;
		}
	}
    
    public class Path{
		public String journeyName{get;set;}
        public Integer recordsInTheJourney{get;set;}
        public String averageJourneyTimeLastThreeHours{get;set;}
        public Integer recordBrichingSLA{get;set;}
        public List<Step> steps{get;set;}
        public Integer completedRecordsInTheJourney{get;set;}

		public Path(String journeyName, Integer recordsInTheJourney, String averageJourneyTimeLastThreeHours, Integer recordBrichingSLA, List<Step> steps,Integer completedRecordsInTheJourney){
			this.journeyName = journeyName;
            this.recordsInTheJourney = recordsInTheJourney;
            this.averageJourneyTimeLastThreeHours = averageJourneyTimeLastThreeHours;
            this.recordBrichingSLA = recordBrichingSLA;
            this.steps = steps;
            this.completedRecordsInTheJourney = completedRecordsInTheJourney;
		}
	}
    
    public class ResponseWrapper{
        public Boolean success;
        public Object data;
        
        public ResponseWrapper(Boolean success, Object data){
            this.success = success;
            this.data = data;
        }
    }
}