public class QuoteContactFieldsUpdate {
  public static void checkAndUpdateSoldToBillTo(List<Id> quotesId) {
    List<zqu__Quote__c> quotes = [
      SELECT
        Id,
        zqu__BillToContact__c,
        zqu__SoldToContact__c,
        zqu__Certificate_ID__c,
        zqu__BillToContact__r.Bill_To__c,
        zqu__SoldToContact__r.Sold_To__c,
        zqu__SoldToContact__r.Country_Code__c
      FROM zqu__Quote__c
      WHERE Id IN :quotesId
    ];

    addCountryCodeToCertificateId(quotes);

    List<Contact> contactsToUpdate = new List<Contact>();

    for (zqu__Quote__c quote : quotes) {
      if (
        quote.zqu__BillToContact__c != null &&
        quote.zqu__SoldToContact__c != null
      ) {
        if (quote.zqu__BillToContact__c == quote.zqu__SoldToContact__c) {
          Contact cont = new Contact();
          cont.Sold_To__c = false;
          cont.Bill_To__c = false;
          cont.Id = quote.zqu__SoldToContact__c;

          Boolean needUpdate = false;

          if (quote.zqu__SoldToContact__r.Sold_To__c == false) {
            cont.Sold_To__c = true;
            needUpdate = true;
          }

          if (quote.zqu__BillToContact__r.Bill_To__c == false) {
            cont.Bill_To__c = true;
            needUpdate = true;
          }
          if (needUpdate) {
            contactsToUpdate.add(cont);
          }
        } else {
          Contact contSoldTo = new Contact();
          contSoldTo.Sold_To__c = false;
          contSoldTo.Bill_To__c = false;
          Contact contBillTo = new Contact();
          contBillTo.Sold_To__c = false;
          contBillTo.Bill_To__c = false;

          if (quote.zqu__SoldToContact__r.Sold_To__c == false) {
            contSoldTo.Id = quote.zqu__SoldToContact__c;
            contSoldTo.Sold_To__c = true;
            contactsToUpdate.add(contSoldTo);
          }

          if (quote.zqu__BillToContact__r.Bill_To__c == false) {
            contBillTo.Id = quote.zqu__BillToContact__c;
            contBillTo.Bill_To__c = true;
            contactsToUpdate.add(contBillTo);
          }
        }
      } else if (quote.zqu__BillToContact__c != null) {
        Contact cont = new Contact();
        cont.Bill_To__c = false;
        cont.Id = quote.zqu__BillToContact__c;

        if (quote.zqu__BillToContact__r.Bill_To__c == false) {
          cont.Bill_To__c = true;
          contactsToUpdate.add(cont);
        }
      } else if (quote.zqu__SoldToContact__c != null) {
        Contact cont = new Contact();
        cont.Sold_To__c = false;
        cont.Id = quote.zqu__SoldToContact__c;

        if (quote.zqu__SoldToContact__r.Sold_To__c == false) {
          cont.Sold_To__c = true;
          contactsToUpdate.add(cont);
        }
      }
    }

    if (!contactsToUpdate.isEmpty()) {
      update contactsToUpdate;
    }
  }

  public static void addCountryCodeToCertificateId(List<zqu__Quote__c> quotes) {
    List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();

    for (zqu__Quote__c quote : quotes) {
      if (quote.zqu__SoldToContact__r.Country_Code__c != null) {
        quote.zqu__Certificate_ID__c =
          quote.zqu__SoldToContact__r.Country_Code__c +
          quote.zqu__Certificate_ID__c;
        quotesToUpdate.add(quote);
      }
    }

    if (!quotesToUpdate.isEmpty()) {
      update quotesToUpdate;
    }
  }

  public static void addCountryCodeToCertificateId(List<Id> quotesId) {
    List<zqu__Quote__c> quotes = [
      SELECT
        Id,
        zqu__Certificate_ID__c,
        zqu__SoldToContact__c,
        zqu__SoldToContact__r.Country_Code__c
      FROM zqu__Quote__c
      WHERE Id IN :quotesId
    ];

    for (zqu__Quote__c quote : quotes) {
      quote.zqu__Certificate_ID__c =
        quote.zqu__SoldToContact__r.Country_Code__c +
        quote.zqu__Certificate_ID__c;
    }

    update quotes;
  }
}
