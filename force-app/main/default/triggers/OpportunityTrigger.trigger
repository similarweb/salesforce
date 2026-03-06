trigger OpportunityTrigger on Opportunity (before insert, after insert, 
                            before update, after update, 
                            before delete, after delete, 
                            after undelete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    if(Trigger.isBefore){
        if (Trigger.isInsert){
            OpportunityTriggerHandler.enrichContactDataByPolygraph(Trigger.new, null);
            System.debug('sqw100 ' + Limits.getQueries()); 
             //OpportunityTriggerHandler.setSimilarWebForecast((List<Opportunity>)Trigger.new, null);
            //OpportunityTriggerHandler.setForecast((List<Opportunity>)Trigger.new, null);
            //OpportunityTriggerHandler.updateForecastBySimilarWeb((List<Opportunity>)Trigger.new, null);
            OpportunityTriggerHandler.setForecastCategoryName((List<Opportunity>)Trigger.new, null);
            System.debug('sqw101 ' + Limits.getQueries()); 
        }
    	if (Trigger.isUpdate){
            OpportunityTriggerHandler.enrichContactDataByPolygraph(Trigger.new, Trigger.oldMap);
            System.debug('sqw110 ' + Limits.getQueries()); 
            //OpportunityTriggerHandler.setForecast((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
            //OpportunityTriggerHandler.updateForecastBySimilarWeb((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
            //OpportunityTriggerHandler.setSimilarWebForecast((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
        	OpportunityTriggerHandler.clearClosedLostValues((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
            OpportunityTriggerHandler.changeCloseDateToToday((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
            OpportunityTriggerHandler.setForecastCategoryName((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
            System.debug('sqw111 ' + Limits.getQueries()); 
		}
    }                            
                                
	if (Trigger.isAfter) {
        AlertForClosedWonOPpps alerts = new AlertForClosedWonOPpps();
        if (Trigger.isInsert){
            System.debug('sqw201 ' + Limits.getQueries()); 
            OpportunityTriggerHandler.manageOpportunityForCommunityUsers((List<Opportunity>)Trigger.new, null);
            System.debug('sqw202 ' + Limits.getQueries()); 
            alerts.alertOnClosedWonOppMain(Trigger.new, null);
        }     
        if (Trigger.isUpdate) {			      
            System.debug('sqw210 ' + Limits.getQueries());       
            //OpportunityTriggerHandler.changeSysCloseFlow((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
            OpportunityTriggerHandler.manageOpportunityForCommunityUsers((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
            System.debug('sqw211 ' + Limits.getQueries());  
            alerts.alertOnClosedWonOppMain(Trigger.new, Trigger.oldMap);
            handler.handleRenewalOppFromFutureUpsell(Trigger.new , Trigger.oldMap);//MIS-5698
        }
    }
}