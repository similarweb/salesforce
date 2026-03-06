public class OppTriggerHandler {
  public static map<id, Opportunity> OppMap = new Map<id, Opportunity>();
  public static map<id, Opportunity> OldMap = new Map<id, Opportunity>();

  public static map<id, Account> AccountMap = new Map<id, Account>();

  public static map<id, CampaignMember> Camp4Acc = new Map<id, CampaignMember>(); // map account id to campaign Member

  static public boolean CodeOff = false;

  public static void GenData(list<Opportunity> OppList) {
    list<id> AccIDList = new List<Id>();
    for (Opportunity o : OppList)
      if (o.accountid != null)
        AccIDList.add(o.accountid);

    if (AccIDList.size() > 0) {
      list<Account> TempAcList = new List<Account>();
      TempAcList = [
        SELECT
          id,
          (
            SELECT id, accountid
            FROM Contacts
          )
        FROM Account
        WHERE id = :AccIDList
      ];

      if (TempAcList.size() > 0) {
        list<id> tempCId = new List<id>();
        for (Account a : tempAcList) {
          AccountMap.put(a.id, a);
          if (a.Contacts.size() > 0)
            for (Contact c : a.Contacts)
              tempCId.add(c.id);

          if (tempCid.size() > 0) {
            list<CampaignMember> CMList = [
              SELECT id, campaignId, contactid, contact.Accountid, createddate
              FROM CampaignMember
              WHERE contactid = :tempCid
              ORDER BY createddate DESC
            ];

            if (CMList.size() > 0)
              for (CampaignMember cm : CMList) {
                if (
                  cm.contactid != null &&
                  cm.contact.accountid != null &&
                  Camp4Acc.ContainsKey(cm.contact.Accountid)
                ) {
                  CampaignMember ncm = Camp4Acc.get(cm.contact.accountid);
                  if (cm.createddate > ncm.createddate) {
                    Camp4Acc.put(cm.contact.accountid, cm);
                  }
                }
              }
          }
        }
      }
    }
  }

  public static void SetPrimaryCampaign(Opportunity o) {
    if (o.accountid != null && Camp4Acc.ContainsKey(o.accountid))
      o.campaignId = Camp4Acc.get(o.accountid).campaignid;
  }

  //******************** THIS IS THE MAIN BEFORE METHOD ********************
  public static void HandleBefore(
    list<Opportunity> OppList,
    map<id, Opportunity> OldTriggerMap,
    string event
  ) {
    GenData(OppList);
    if (event == 'Insert') {
      for (Opportunity o : OppList) {
        SetPrimaryCampaign(o);
      }
    }
  }
}
