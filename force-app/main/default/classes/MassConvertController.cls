public with sharing class MassConvertController {
    
    public ApexPages.StandardSetController con;

    public MassConvertController(ApexPages.StandardSetController con)
    {
        this.con = con;
    }
    
    public PageReference ConvertLeads()
    {  
         list< MassLeadConvert__c > resIds = (List< MassLeadConvert__c >) con.getSelected();
         list< MassLeadConvert__c > recselected = [select id,accountid__c, leadid__c, contactid__c,Success__c, error__c 
                                                    from MassLeadConvert__c where id=:resIds];
         
         map <id, MassLeadConvert__c> datamap = new map <id,MassLeadConvert__c>();
         
         if (recselected.size()>0)
         {
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            list <Database.LeadConvert> conversions = new list <Database.LeadConvert>();
            
            for (MassLeadConvert__c mlc : recselected) if (mlc.leadid__c!=null && mlc.accountid__c !=null)
            {
                Database.LeadConvert lc = new database.LeadConvert();
                
                lc.setLeadId(mlc.leadid__c);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setDoNotCreateOpportunity(true);
                lc.setAccountId(mlc.accountid__c);
                if (mlc.contactid__c!=null) lc.setContactID (mlc.contactid__c);
                conversions.add (lc);
                datamap.put (mlc.LeadID__c,mlc);
                
            }
            List<Database.LeadConvertResult> results = Database.convertLead(conversions);
            list <MassLeadConvert__c> MLC4Update = new list <MassLeadConvert__c>();
            
            for (Database.LeadConvertResult res : results)
            {
                system.debug('TESTING: res is '+res);
                MassLeadConvert__c mlc = datamap.get (res.getLeadId());
                if (res.isSuccess() )mlc.Success__c = true;
                if (!res.isSuccess()) mlc.error__c = string.valueof(res.geterrors());
                MLC4Update.add (mlc);   
            }
            if (MLC4Update.size()>0) update MLC4Update;
         }
         
         return null;   
    }

}