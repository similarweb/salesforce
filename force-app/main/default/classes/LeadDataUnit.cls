public class LeadDataUnit {
    public Lead lead;
    public Account targetAccount { get; set; } 
    public Contact targetContact { get; set; }
    public Id resultAccountId { get; set; }
    public Id resultContactId { get; set; }
    public List<Event> childEventList { get; set; }
    public Boolean isConvertedSuccessfully = false;
    public Database.Error[] convertationErrors { get; set; }

    public String getLeadId() {
        return lead.Id;
    }

    public void setLeadOwnerId() {
        lead.OwnerId = childEventList[0].OwnerId;
    }

    public String getWebsite() {
        return lead.Website;
    }

    public String getCountry() {
        return lead.Country;
    }

    public String getCountryAndWebsite() {
        return getCountry() + ' ' + getWebsite();
    }

    public String getEmail() {
        return lead.Email;
    }

    public void addEvent(Event e) {
        childEventList.add(e);
    }

    public Database.LeadConvert createLeadConvertion() {
        LeadStatus convertStatus = GeneralUtil.CONVERT_LEAD_STATUS;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(getLeadId());
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(true);
        lc.setSendNotificationEmail(false);
        if (targetAccount != null) {
            lc.setAccountId(targetAccount.Id);
        }
        if (targetContact != null) {
            lc.setContactId(targetContact.Id);
        }
        return lc;
    }
}