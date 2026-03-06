public class EventChillipaperLeadConverterHelper {
    static Map<Id, Lead> leadMap;
    static Map<Id, List<Event>> leadToEventsMap;
    static Map<String, Map<Id, Account>> accountMap;
    static Map<String, Contact> contactMap;

    static {
        leadMap = new Map<Id, Lead>();
        leadToEventsMap = new Map<Id, List<Event>>();
        accountMap = new Map<String, Map<Id, Account>>();
        contactMap = new Map<String, Contact>();
    }

    public static void convertParentLeads(List<Event> eventList) {
        List<LeadDataUnit> leadDataUnitList = retrieveLeadData(eventList);
        leadDataUnitList = retrieveAccountAndContactData(leadDataUnitList);
        EventChillipaperLeadConverterQueueable leadConvertJob = new EventChillipaperLeadConverterQueueable(leadDataUnitList);
        System.enqueueJob(leadConvertJob);
    } 

    static List<LeadDataUnit> retrieveLeadData(List<Event> eventList) {
        List<LeadDataUnit> leadDataUnitList = new List<LeadDataUnit>();
        Set<Id> leadIdSet = new Set<Id>();
        for (Event event_i : eventList) {
            if (!leadMap.containsKey(event_i.WhoId)) {
                leadIdSet.add(event_i.WhoId);
            }
            if (leadToEventsMap.get(event_i.WhoId) == null) {
                leadToEventsMap.put(event_i.WhoId, new List<Event>());
            } 
            leadToEventsMap.get(event_i.WhoId).add(event_i);
        }
        if (!leadIdSet.isEmpty()) {
            leadMap = new Map<Id, Lead>([
                SELECT Id 
                    , Website
                    , Country
                    , Email
                FROM Lead 
                WHERE Id IN :leadIdSet
            ]);
        }
        for (Id id_i : leadMap.keySet()) {
            LeadDataUnit dataUnit = new LeadDataUnit();
            dataUnit.lead = leadMap.get(id_i);
            dataUnit.childEventList = leadToEventsMap.get(id_i);
            leadDataUnitList.add(dataUnit);
        }
        
        return leadDataUnitList;
    }

    static List<LeadDataUnit> retrieveAccountAndContactData(List<LeadDataUnit> leadDataUnitList) {
        Set<String> websiteSet = new Set<String>();
        Set<String> countrySet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        for (LeadDataUnit ldu_i : leadDataUnitList) {
            if (!accountMap.containsKey(ldu_i.getCountryAndWebsite())) {
                websiteSet.add(ldu_i.getWebsite());
                countrySet.add(ldu_i.getCountry());
            }
            if (!contactMap.containsKey(ldu_i.getEmail())) {
                emailSet.add(ldu_i.getEmail());
            }
        }
        if (!emailSet.isEmpty()) {
            for (Contact con_i : 
                [SELECT Id
                    , Email
                    , AccountId
                FROM Contact
                WHERE Email IN :emailSet]) {
                contactMap.put(con_i.Email, con_i);
            }
        }
        if (!websiteSet.isEmpty() && !countrySet.isEmpty()) {
            for (Account acc_i : 
                [SELECT Id
                    , Website
                    , BillingCountry
                FROM Account
                WHERE
                    BillingCountry IN :countrySet AND
                    Website IN :websiteSet]) {
                String countryAndWebsite_i = acc_i.BillingCountry + ' ' + acc_i.Website;
                if (accountMap.get(countryAndWebsite_i) == null) {
                    accountMap.put(countryAndWebsite_i, new Map<Id, Account>());
                }
                accountMap.get(countryAndWebsite_i).put(acc_i.Id, acc_i);
            }
        }
        
        for (LeadDataUnit ldu_i : leadDataUnitList) {
            ldu_i.targetContact = contactMap.get(ldu_i.getEmail());
            ldu_i.targetAccount = accountMap.get(ldu_i.getCountryAndWebsite())?.values()?.get(0);
            Boolean hasMultipleAccounts = accountMap.get(ldu_i.getCountryAndWebsite()) != null && accountMap.get(ldu_i.getCountryAndWebsite()).size() > 1;
            if (ldu_i.targetContact != null && hasMultipleAccounts) {
                Account relatedAccount = accountMap.get(ldu_i.getCountryAndWebsite()).get(ldu_i.targetContact.AccountId);
                if (relatedAccount != null) {
                    ldu_i.targetAccount = relatedAccount;
                }
            } 
        }

        return leadDataUnitList;
    }
}