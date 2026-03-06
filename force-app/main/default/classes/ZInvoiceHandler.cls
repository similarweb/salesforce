public without sharing class ZInvoiceHandler {
  public static map<id, Zuora__ZInvoice__c> oldmap = new Map<id, Zuora__ZInvoice__c>();
  public static map<id, Account> AccMap = new Map<id, Account>();

  public static void GenData(list<Zuora__ZInvoice__c> zilist, string event) {
    list<id> tempidlist = new List<id>();
    if (zilist.size() > 0)
      for (Zuora__ZInvoice__c zi : zilist) {
        if (zi.Zuora__Account__c != null)
          tempidlist.add(zi.Zuora__Account__c);
      }
    if (tempidlist.size() > 0) {
      list<Account> tempalist = [
        SELECT id, ownerid, owner.isactive
        FROM Account
        WHERE id = :tempidlist
      ];
      AccMap.putall(tempalist);
    }
  }

  public static void CalcOwner(list<Zuora__ZInvoice__c> zilist, string event) {
    if (event == 'Insert')
      for (Zuora__ZInvoice__c zi : zilist) {
        if (
          zi.Zuora__Account__c != null &&
          AccMap.ContainsKey(zi.Zuora__Account__c) &&
          AccMap.get(zi.Zuora__Account__c).owner.isactive
        ) {
          zi.ownerid = accmap.get(zi.Zuora__Account__c).ownerid;
        }
      }
  }

  public static void HandleBEFORE(
    list<Zuora__ZInvoice__c> zilist,
    map<id, Zuora__ZInvoice__c> OldTriggerMap,
    string event
  ) {
    if (OldTriggerMap != null)
      oldmap = oldtriggermap;
    GenData(zilist, event);
    CalcOwner(zilist, event);
  }
}
