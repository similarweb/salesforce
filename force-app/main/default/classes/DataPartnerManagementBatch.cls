/**
 * @author Zohar Sinay
 * @date 03/02/2022
 * @description Distribute leads to marketing cloud and pardot lead
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */

public with sharing class DataPartnerManagementBatch implements Database.Batchable<sObject>, Database.Stateful {
  private static final string dataPartnerRecordTypeId = Utility.getRecordTypeIdForObject(
    new Account().getSObjectType(),
    'Wolves'
  );
  private static final Integer thisMonth = Date.today().month();
  private static final Integer thisYear = Date.today().year();
  public static List<Log_Event__e> logList = new List<Log_Event__e>();
  public static Log_Event__e log = new Log_Event__e();
  private String accountId;

  public DataPartnerManagementBatch(String accountId) {
    this.accountId = accountId;
  }

  public DataPartnerManagementBatch() {
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    String activeStr = 'Active';
    Set<String> paymentMethodStringSet = new Set<String>{
      'Monthly',
      'Monthly - Fix Price',
      'Monthly - Flex Rate'
    };
    String query =
      'SELECT ID, Name, (SELECT Id, Name FROM Contracts WHERE Payment_Method__c IN:paymentMethodStringSet )' +
      'FROM Account ' +
      'WHERE RecordTypeId = :dataPartnerRecordTypeId AND Wolves_Status__c =:activeStr ';
    query += this.accountId != null ? 'AND Id = :accountId' : '';
    System.debug('query--' + query);

    return Database.getQueryLocator(query);
  }

  /**
   * @param bc
   * @param scope
   */
  public void execute(Database.BatchableContext bc, List<Account> scope) {
    List<Id> ContractIdList = new List<Id>();
    List<Source__c> sourceList = new List<Source__c>();
    List<Monthly_Partner_Request__c> MPRList = new List<Monthly_Partner_Request__c>();
    List<Monthly_Source_Request__c> MSRList = new List<Monthly_Source_Request__c>();
    List<Monthly_Data_Request__c> MDRList = new List<Monthly_Data_Request__c>();

    try {
      for (Account acc : scope) {
        for (Contract cont : acc.Contracts) {
          System.debug(cont.Id);
          ContractIdList.add(cont.Id);
          String MPRName = String.isBlank(cont.Name) ? acc.Name : cont.Name;
          MPRName += '/' + thisMonth + '/' + thisYear;
          MPRList.add(
            new Monthly_Partner_Request__c(
              Name = MPRName,
              Contracts__c = cont.Id
            )
          );
        }
      }
      sourceList = [
        SELECT
          Id,
          Name,
          Source_Number__c,
          Contract__c,
          Contract__r.Name,
          (
            SELECT
              Id,
              Name,
              Source__c,
              Source__r.Name,
              Request_Type__c,
              Source__r.Source_Number__c,
              Country__c,
              Country_Tier__c
            FROM Rates__r
            WHERE End_Date__c = NULL OR End_Date__c > :Date.today()
          )
        FROM Source__c
        WHERE Contract__c IN :ContractIdList AND Active__c = TRUE
      ];
      System.debug('sourceList--' + sourceList);
      Map<Id, List<Source__c>> sourceByContractIdMap = new Map<Id, List<Source__c>>();
      Map<Id, List<Rate__c>> rateBySourceIdMap = new Map<Id, List<Rate__c>>();
      for (Source__c so : sourceList) {
        if (!sourceByContractIdMap.containsKey(so.Contract__c)) {
          sourceByContractIdMap.put(so.Contract__c, new List<Source__c>{ so });
        } else {
          sourceByContractIdMap.get(so.Contract__c).add(so);
        }
      }
      System.debug('sourceByContractIdMap---' + sourceByContractIdMap);
      if (!MPRList.isEmpty()) {
        insert MPRList;
        for (Monthly_Partner_Request__c mpr : MPRList) {
          System.debug('mpr--' + mpr);
          System.debug('mpr.Contracts__c--' + mpr.Contracts__c);
          System.debug(
            'sourceByContractIdMap--' +
            sourceByContractIdMap.get(mpr.Contracts__c)
          );
          if (sourceByContractIdMap.containsKey(mpr.Contracts__c)) {
            for (Source__c so : sourceByContractIdMap.get(mpr.Contracts__c)) {
              MSRList.add(
                new Monthly_Source_Request__c(
                  Name = so.Name +
                    '/' +
                    so.Source_Number__c +
                    '/' +
                    String.valueOf(thisMonth) +
                    '/' +
                    String.valueOf(thisYear),
                  Monthly_Partner_Request__c = mpr.Id,
                  Source__c = so.Id
                )
              );
              for (Rate__c rat : so.Rates__r) {
                if (!rateBySourceIdMap.containsKey(rat.Source__c)) {
                  rateBySourceIdMap.put(
                    rat.Source__c,
                    new List<Rate__c>{ rat }
                  );
                } else {
                  rateBySourceIdMap.get(rat.Source__c).add(rat);
                }
              }
            }
          }
        }
        if (!MSRList.isEmpty()) {
          insert MSRList;
        }
        for (Monthly_Source_Request__c msr : MSRList) {
          System.debug('msr--' + msr);
          System.debug('msr.Source__c--' + msr.Source__c);
          System.debug(
            'rateBySourceIdMap--' + rateBySourceIdMap.get(msr.Source__c)
          );
          if (rateBySourceIdMap.containsKey(msr.Source__c)) {
            for (Rate__c rat : rateBySourceIdMap.get(msr.Source__c)) {
              MDRList.add(
                new Monthly_Data_Request__c(
                  Name = rat.Source__r.Name +
                    '/' +
                    rat.Source__r.Source_Number__c +
                    '/' +
                    rat.Request_Type__c +
                    '/' +
                    rat.Country_Tier__c +
                    '/' +
                    String.valueOf(thisMonth) +
                    '/' +
                    String.valueOf(thisYear),
                  Monthly_Source_Request__c = msr.Id,
                  Source__c = rat.Source__c,
                  Rate__c = rat.Id
                )
              );
            }
          }
        }
        if (!MDRList.isEmpty()) {
          insert MDRList;
        }
      }
    } catch (Exception ex) {
      System.debug('EXCEPTION: ' + ex.getMessage());
      System.debug('EXCEPTION Path: ' + ex.getStackTraceString());
    }
  }

  public void finish(Database.BatchableContext bc) {
  }
}
