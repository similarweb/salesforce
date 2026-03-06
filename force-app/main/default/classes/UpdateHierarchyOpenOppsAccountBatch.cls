/**
 * Created by Alon.Shalev on 6/9/2024.
 */

global with sharing class UpdateHierarchyOpenOppsAccountBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
  private final Integer batchSize;
  private Map<Id, Integer> accountIdToNumberOfOpenOppsInHierarcyMap = new Map<Id, Integer>();

  global UpdateHierarchyOpenOppsAccountBatch(Integer batchSize) {
    this.batchSize = batchSize;
  }

  global UpdateHierarchyOpenOppsAccountBatch() {
  }

  global void execute(SchedulableContext param1) {
    UpdateHierarchyOpenOppsAccountBatch batch = new UpdateHierarchyOpenOppsAccountBatch();
    Database.executeBatch(batch, this.batchSize != null ? this.batchSize : 3);
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query =
      'SELECT Id,Parent_Company_Domain__c,Website_Domain__c ' +
      ' FROM Account ' +
      'WHERE Number_Of_Open_Opps_Changed_Today__c  = true';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> scope) {
    Map<String, Account> companyParentDomainToAccountMap = new Map<String, Account>();
    Map<String, Account> websiteDomainToAccountMap = new Map<String, Account>();
    Map<String, List<Account>> companyDomainToSimilarAccountMap = new Map<String, List<Account>>();
    Map<String, List<Account>> websiteDomainToSimilarAccountMap = new Map<String, List<Account>>();
    List<Account> accountToUpdateList = new List<Account>();
    for (Account acc : scope) {
      if (String.isNotBlank(acc.Parent_Company_Domain__c)) {
        companyParentDomainToAccountMap.put(acc.Parent_Company_Domain__c, acc);
      }
      if (
        !companyParentDomainToAccountMap.containsKey(acc.Website_Domain__c) &&
        String.isNotBlank(acc.Website_Domain__c)
      ) {
        websiteDomainToAccountMap.put(acc.Website_Domain__c, acc);
      }
    }

    List<Account> similarAccountByParentDomainList = [
      SELECT
        Id,
        Name,
        Website_Domain__c,
        Parent_Company_Domain__c,
        Hierarchy_Total_Open_Opps__c,
        (SELECT Id FROM Opportunities WHERE IsClosed = FALSE)
      FROM Account
      WHERE
        Parent_Company_Domain__c IN :companyParentDomainToAccountMap.keySet()
    ];
    List<Account> similarAccountByWebsiteDomainList = [
      SELECT
        Id,
        Name,
        Website_Domain__c,
        Parent_Company_Domain__c,
        (SELECT Id FROM Opportunities WHERE IsClosed = FALSE)
      FROM Account
      WHERE
        Website_Domain__c IN :websiteDomainToAccountMap.keySet()
        AND Parent_Company_Domain__c = NULL
    ];

    for (Account similarAccount : similarAccountByParentDomainList) {
      System.debug(
        'similarAccount--' + similarAccount.Hierarchy_Total_Open_Opps__c
      );
      System.debug(
        'size of opportunities in similarAccountByParentDomainList--' +
        similarAccount.Opportunities.size()
      );
      if (String.isNotBlank(similarAccount.Parent_Company_Domain__c)) {
        if (
          !companyDomainToSimilarAccountMap.containsKey(
            similarAccount.Parent_Company_Domain__c
          )
        ) {
          companyDomainToSimilarAccountMap.put(
            similarAccount.Parent_Company_Domain__c,
            new List<Account>()
          );
        }
        companyDomainToSimilarAccountMap.get(
            similarAccount.Parent_Company_Domain__c
          )
          .add(similarAccount);
      }
    }

    for (Account similarAccount : similarAccountByWebsiteDomainList) {
      System.debug(
        'size of opportunities in similarAccountByWebsiteDomainList--' +
        similarAccount.Opportunities.size()
      );
      if (String.isNotBlank(similarAccount.Website_Domain__c)) {
        if (
          !websiteDomainToSimilarAccountMap.containsKey(
            similarAccount.Website_Domain__c
          )
        ) {
          websiteDomainToSimilarAccountMap.put(
            similarAccount.Website_Domain__c,
            new List<Account>()
          );
        }
        websiteDomainToSimilarAccountMap.get(similarAccount.Website_Domain__c)
          .add(similarAccount);
      }
    }

    populateAccount(
      companyDomainToSimilarAccountMap,
      websiteDomainToSimilarAccountMap
    );
    //        populateAccount(websiteDomainToAccountMap, companyDomainToSimilarAccountMap, accountToUpdateList);
    System.debug('accountToUpdateList--' + accountToUpdateList);

    //        update accountToUpdateList;
  }

  private void populateAccount(
    Map<String, List<Account>> companyDomainToSimilarAccountMap,
    Map<String, List<Account>> websiteDomainToSimilarAccountMap
  ) {
    for (String domain : companyDomainToSimilarAccountMap.keySet()) {
      Integer numberOfOpenOpps = 0;
      Integer newNumberOfOppenOpps = getNumberOfOppenOpps(
        companyDomainToSimilarAccountMap,
        domain,
        numberOfOpenOpps
      );
      List<Account> allAccountsInHierarchy = companyDomainToSimilarAccountMap.get(
        domain
      );
      for (Account accountInThisHierarchy : allAccountsInHierarchy) {
        this.accountIdToNumberOfOpenOppsInHierarcyMap.put(
          accountInThisHierarchy.Id,
          newNumberOfOppenOpps
        );
      }
      //            System.debug('numberOfOpenOpps--' + numberOfOpenOpps);
      //            accToUpdate.Hierarchy_Total_Open_Opps__c = newNumberOfOppenOpps;
      //            accToUpdate.Number_Of_Open_Opps_Changed_Today__c = false;
      //            accountToUpdateList.add(accToUpdate);
    }
    for (String domain : websiteDomainToSimilarAccountMap.keySet()) {
      Integer numberOfOpenOpps = 0;
      Integer newNumberOfOppenOpps = getNumberOfOppenOpps(
        websiteDomainToSimilarAccountMap,
        domain,
        numberOfOpenOpps
      );
      List<Account> allAccountsInHierarchy = websiteDomainToSimilarAccountMap.get(
        domain
      );
      for (Account accountInThisHierarchy : allAccountsInHierarchy) {
        this.accountIdToNumberOfOpenOppsInHierarcyMap.put(
          accountInThisHierarchy.Id,
          newNumberOfOppenOpps
        );
      }
    }
  }

  private Integer getNumberOfOppenOpps(
    Map<String, List<Account>> companyDomainToSimilarAccountMap,
    String domain,
    Integer numberOfOpenOpps
  ) {
    if (companyDomainToSimilarAccountMap.containsKey(domain)) {
      for (
        Account similarAccount : companyDomainToSimilarAccountMap.get(domain)
      ) {
        numberOfOpenOpps += similarAccount.Opportunities.size();
      }
    }
    return numberOfOpenOpps;
  }

  public void finish(Database.BatchableContext param1) {
    Database.executeBatch(
      new UpdateHierarchyOpenOppsActionBatch(
        this.accountIdToNumberOfOpenOppsInHierarcyMap
      ),
      10
    );
  }
}
