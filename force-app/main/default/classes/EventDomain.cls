public with sharing class EventDomain extends GenericDomain {

    public EventDomain(List<SObject> newRecords) {
        super(newRecords);
    }

    public override void onAfterInsert() {
        List<Event> eventForLeadToConvertList = new List<Event>();
        for (Event event_i : (List<Event>) newRecords) {
            Boolean isLead = event_i.WhoId.getSObjectType().getDescribe().getName() == 'Lead';
            Boolean isMql = !String.isBlank(event_i.Queue_Name_CP__c) ? event_i.Queue_Name_CP__c.startsWithIgnoreCase('mql -') : false;
            if (isLead && isMql) {
                eventForLeadToConvertList.add(event_i);
            }
        }
        if (!eventForLeadToConvertList.isEmpty()) {
            EventChillipaperLeadConverterHelper.convertParentLeads(eventForLeadToConvertList);
        }
    }

    public class Constructor implements GenericDomain.IConstructable {
        public GenericDomain constructDomainInstance(List<SObject> sObjectList) {
            return new EventDomain(sObjectList);
        }
    }
}