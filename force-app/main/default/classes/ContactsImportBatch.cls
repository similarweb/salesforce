public with sharing class ContactsImportBatch implements Database.Batchable<sObject>, Database.Stateful {
  public List<Contact> contacts;
  public Map<String, String> emailToDraftId;
  public List<String> draftIdsToDelete;
  public Map<String, String> draftIdsThatFaileToError;
  public List<Contact> importedContacts;

  public ContactsImportBatch(
    List<Contact> contactsToIpmort,
    Map<String, String> emailToDraftId
  ) {
    this.contacts = contactsToIpmort;
    this.emailToDraftId = emailToDraftId;
    this.draftIdsToDelete = new List<String>();
    this.draftIdsThatFaileToError = new Map<String, String>();
    this.importedContacts = new List<Contact>();
  }

  public List<Contact> start(Database.BatchableContext bc) {
    return this.contacts;
  }
  public void execute(Database.BatchableContext bc, List<Contact> contacts) {
    Database.UpsertResult[] results = Database.upsert(contacts, false);
    for (Integer index = 0, size = results.size(); index < size; index++) {
      if (results[index].isSuccess()) {
        this.draftIdsToDelete.add(
          this.emailToDraftId.get(contacts[index].Email)
        );
        this.importedContacts.add(contacts[index]);
      } else {
        this.draftIdsThatFaileToError.put(
          this.emailToDraftId.get(contacts[index].Email),
          (results[index].getErrors())[0].getMessage()
        );
      }
    }
  }
  public void finish(Database.BatchableContext bc) {
    Map<Id, ContactDraft__c> drafts = new Map<Id, ContactDraft__c>(
      [
        SELECT Id, UploadStatus__c
        FROM ContactDraft__c
        WHERE Id IN :emailToDraftId.values()
        FOR UPDATE
      ]
    );
    String emailMessafe = '';
    if (!this.draftIdsToDelete.isEmpty()) {
      List<ContactDraft__c> draftsToDelete = new List<ContactDraft__c>();
      for (String id_i : this.draftIdsToDelete) {
        draftsToDelete.add(drafts.get(id_i));
      }
      if (!draftsToDelete.isEmpty()) {
        Database.DeleteResult[] results = Database.delete(
          draftsToDelete,
          false
        );
        for (Integer index = 0, size = results.size(); index < size; index++) {
          if (results[index].isSuccess()) {
          } else {
            this.draftIdsThatFaileToError.put(
              draftsToDelete[index].Id,
              (results[index].getErrors())[0].getMessage()
            );
          }
        }
      }

      if (!importedContacts.isEmpty()) {
        Set<Id> accountIds = new Set<Id>();
        System.debug(importedContacts);
        for (Contact cont_i : importedContacts) {
          System.debug(cont_i);
          accountIds.add(cont_i.AccountId);
        }
        System.debug(accountIds);
        Map<Id, Account> idToAccount = new Map<Id, Account>(
          [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );
        System.debug(idToAccount);
        emailMessafe +=
          '<html><head></head><body><p>' +
          importedContacts.size() +
          ' contact' +
          (importedContacts.size() > 1 ? 's' : '') +
          ' loaded successfully </p>' +
          '<table cellspacing="0" cellpadding="0" border="1" style="table-layout:fixed;font-size:10pt;font-family:arial,sans,sans-serif;width:0px;border-collapse:collapse;border:none">' +
          ' <colgroup><col width="150"><col width="150"><col width="150"><col width="150"></colgroup>' +
          '<tbody> ' +
          ' <tr style="height:21px">' +
          '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">Name</td>' +
          '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">Email</td>' +
          '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">Account Name</td>' +
          '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">Contact ID</td>' +
          '</tr>';
        for (Contact cont_i : importedContacts) {
          System.debug(idToAccount.get(cont_i.AccountId));
          System.debug((idToAccount.get(cont_i.AccountId)).Name);
          emailMessafe +=
            '<tr style="height:21px">' +
            '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">' +
            cont_i.FirstName +
            ' ' +
            cont_i.LastName +
            '</td>' +
            '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">' +
            cont_i.Email +
            '</td>' +
            '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">' +
            (idToAccount.get(cont_i.AccountId)).Name +
            '</td>' +
            '<td style="overflow:hidden;padding:2px 3px;vertical-align:bottom;border:1px solid rgb(204,204,204)">' +
            cont_i.Id +
            '</td>' +
            '</tr>';
        }
        emailMessafe += '</tbody></table></body></html>';
      }
    }
    if (!this.draftIdsThatFaileToError.isEmpty()) {
      List<ContactDraft__c> failedContactsDraft = new List<ContactDraft__c>();
      for (String contactDraftId_i : this.draftIdsThatFaileToError.keySet()) {
        ContactDraft__c contactDraftToUpdate = drafts.get(contactDraftId_i);
        contactDraftToUpdate.UploadStatus__c = this.draftIdsThatFaileToError.get(
          contactDraftId_i
        );
        failedContactsDraft.add(contactDraftToUpdate);
      }
      if (!failedContactsDraft.isEmpty()) {
        String begining = '';
        if (String.isBlank(emailMessafe)) {
          begining = 'All contacts were ';
        } else {
          begining =
            failedContactsDraft.size() +
            ' ' +
            (failedContactsDraft.size() > 1 ? 'contacts were' : 'contact was');
        }
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        // emailMessafe += '\n\n' + begining + ' not imported. Please, return to the Contact Import Table tab to see the error messages!';
        emailMessafe +=
          '\n\n Please note that not all contacts were imported. Please, return to the Contact Import Table (LINK ' +
          baseUrl +
          '/lightning/n/Import_Contacts) to check the error messages.';
        Database.update(failedContactsDraft, false);
      }
    }

    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = new List<String>{ UserInfo.getUserEmail() };
    // message.toAddresses = new String[] { 'timofei.nikulcha@synebo.io'};
    message.optOutPolicy = 'FILTER';
    message.subject = 'Contact import process is finished!';
    // message.plainTextBody = emailMessafe;
    message.setHtmlBody(emailMessafe);
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);

    if (results[0].success) {
      System.debug('The email was sent successfully.');
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
}
