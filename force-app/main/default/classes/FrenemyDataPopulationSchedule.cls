global class FrenemyDataPopulationSchedule implements Schedulable{
	private Set<Id> frenemyLeadSet;
        
        public FrenemyDataPopulationSchedule(Set<Id> frenemyLeadSet){
            this.frenemyLeadSet = frenemyLeadSet;
        }
        
        global void execute(SchedulableContext sc) {
            Pardot_Data_Manipulation_Setting__c ownerSetting = Pardot_Data_Manipulation_Setting__c.getInstance('FRENEMY_LEAD_OWNER_ID');
            if(ownerSetting != null){
                List<Lead> leadList = [SELECT Id,FirstName,LastName,Company,Website,Title,Department__c,Employees_Min__c,Employees_Max__c,Industry,Country,Email,Phone,Company_LDR_Compare__c,
                                       Country_LDR_Compare__c,First_Name_LDR_Compare__c,Last_Name_LDR_Compare__c,Website_LDR_Compare__c,Title_LDR_Compare__c,Employee_Min_LDR_Compare__c,Department_LDR_Compare__c,
                                       Email_address_domain_type__c,Last_Contact_Us_Form_Subject__c FROM Lead WHERE Id IN :frenemyLeadSet];
                System.debug('leadList q' + leadList);
                for(Lead lead_i : leadList){
                    lead_i.Unverified_Reason__c = 'Frenemies';
                    lead_i.OwnerId = ownerSetting.Value__c;
                    lead_i.Orchestration_Journey_Status__c = 'Excluded';
                    lead_i.Pardot_List_Assignment__c = 'Recycle Bin';
                    lead_i.Journey_Completed_Timestamp__c = System.now();
                }
                //PardotDataManipulationHandler.journeyDecisionFlow(leadList);
                update leadList;
            }
        }  
}