/**
 * @author Zohar Sinay
 * @date 27/02/2022
 * @description A class to create Data Partners for a specific contract
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */

public with sharing class DataPartnersSpecificContractAController {
  private static final Integer thisMonth = Date.today().addDays(-30).month();
  private static final Integer thisYear = Date.today().addDays(-30).year();

  /**
   * @author Zohar Sinay
   * @date 27/02/2022
   * @Description Create data partners for a specific contract
   * @param contractId The Id of the contract to create the data for
   */
  @AuraEnabled
  public static void createNewDataPartnersForContract(id contractId) {
    Monthly_Partner_Request__c MPR = new Monthly_Partner_Request__c();
    Set<Id> ratesIdSet = new Set<Id>();
    Set<Id> sourceIdSet = new Set<Id>();
    List<Id> ratesToCreateList = new List<Id>();
    Map<Id, Rate__c> rateByIdMap = new Map<Id, Rate__c>();
    List<Monthly_Data_Request__c> MDRToInsertList = new List<Monthly_Data_Request__c>();
    Map<Id, Monthly_Source_Request__c> MSRBySource = new Map<Id, Monthly_Source_Request__c>();
    Map<Id, Monthly_Source_Request__c> MSRBySourceId = new Map<Id, Monthly_Source_Request__c>();
    Map<Id, Monthly_Data_Request__c> MDRByRateId = new Map<Id, Monthly_Data_Request__c>();

    Contract cont = [
      SELECT Id, Name, Account.Name
      FROM Contract
      WHERE Id = :contractId
      LIMIT 1
    ];
    String MPRName = createMPRName(cont);

    List<Monthly_Partner_Request__c> MPRList = [
      SELECT Id
      FROM Monthly_Partner_Request__c
      WHERE Name = :MPRName AND Contracts__c = :cont.Id
      LIMIT 1
    ];

    if (!MPRList.isEmpty()) {
      MPR = MPRList[0];
    } else {
      MPR.Name = MPRName;
      MPR.Contracts__c = cont.Id;
      insert MPR;
    }

    Map<Id, Source__c> sourceByIdMap = new Map<Id, Source__c>(
      [
        SELECT
          Id,
          Name,
          Source_Number__c,
          Contract__r.Payment_Method__c,
          Contract__r.Id,
          (
            SELECT
              Id,
              Country__c,
              Request_Type__c,
              Source__r.Name,
              Source__r.Source_Number__c,
              Source__c
            FROM Rates__r
            WHERE
              End_Date__c = NULL
              OR End_Date__c >= :date.today().addDays(-17)
          )
        FROM Source__c
        WHERE Contract__c = :contractId AND Active__c = TRUE
      ]
    );

    for (Source__c source : sourceByIdMap.values()) {
      sourceIdSet.add(source.Id);
      for (Rate__c rate : source.Rates__r) {
        rateByIdMap.put(rate.Id, rate);
        ratesIdSet.add(rate.Id);
      }
    }

    for (Monthly_Source_Request__c MSR : [
      SELECT
        Id,
        Source__c,
        Monthly_Partner_Request__c,
        (
          SELECT Id, Rate__c, Source__c
          FROM Monthly_Data_Requests__r
          WHERE Rate__c IN :ratesIdSet
        )
      FROM Monthly_Source_Request__c
      WHERE Source__c IN :sourceIdSet AND CreatedDate = THIS_MONTH
    ]) {
      MSRBySourceId.put(MSR.Source__c, MSR);
      for (Monthly_Data_Request__c MDR : MSR.Monthly_Data_Requests__r) {
        MDRByRateId.put(MDR.Rate__c, MDR);
      }
    }

    for (Source__c source : sourceByIdMap.values()) {
      if (!MSRBySourceId.containsKey(source.Id)) {
        MSRBySource.put(
          source.Id,
          createNewMonthlySourceRequests(source, MPR.Id)
        );
      }
    }

    if (!MSRBySource.isEmpty()) {
      insert MSRBySource.values();
    }

    for (Rate__c rate : rateByIdMap.values()) {
      if (!MDRByRateId.containsKey(rate.Id)) {
        Id MSRId = MSRBySource.isEmpty()
          ? MSRBySourceId.get(rate.Source__c).Id
          : MSRBySource.get(rate.Source__c).Id;
        MDRToInsertList.add(createNewMonthlyDataRequests(rate, MSRId));
      }
    }

    if (!MDRToInsertList.isEmpty()) {
      insert MDRToInsertList;
    }
  }

  /**
   * @author Zohar Sinay
   * @date 27/02/2022
   * @Description Create the Monthly Source Request according to the source and Monthly Partner Request
   * @param Source__c The source based on which's data the Monthly source request is build
   * @param Id The Id of the Montly Partner Request that needs to be associated
   * @return Monthly_Source_Request__c with all data assigned
   */
  public static Monthly_Source_Request__c createNewMonthlySourceRequests(
    Source__c source,
    Id MPRId
  ) {
    return new Monthly_Source_Request__c(
      Name = source.Name +
        '/' +
        source.Source_Number__c +
        '/' +
        String.valueOf(thisMonth) +
        '/' +
        String.valueOf(thisYear),
      Monthly_Partner_Request__c = MPRId,
      Source__c = source.Id
    );
  }

  /**
   * @author Zohar Sinay
   * @date 27/02/2022
   * @Description Create the Monthly Data Request according to the Rate and Monthly Source Request
   * @param Rate__c The rate based on which's data the monthtly data request is being populated
   * @param Id logEvent -Monthly Source Request Id related to this Monthly Data Request
   * @return Monthly_Data_Request__c with all data assigned
   */
  public static Monthly_Data_Request__c createNewMonthlyDataRequests(
    Rate__c rate,
    Id MSRId
  ) {
    return new Monthly_Data_Request__c(
      Name = rate.Source__r.Name +
        '/' +
        rate.Source__r.Source_Number__c +
        '/' +
        rate.Request_Type__c +
        '/' +
        rate.Country__c +
        '/' +
        String.valueOf(Date.today().addDays(-30).month()) +
        '/' +
        String.valueOf(Date.today().addDays(-30).year()),
      Monthly_Source_Request__c = MSRId,
      Source__c = rate.Source__c,
      Rate__c = rate.Id
    );
  }

  /**
   * @author Zohar Sinay
   * @date 27/02/2022
   * @Description Create the monthly partner request name
   * @param Account Account based on which the name of the Partner request is determined
   * @return String with all data assigned
   */
  public static String createMPRName(Contract cont) {
    String MPRName = String.isBlank(cont.Name) ? cont.Account.Name : cont.Name;
    MPRName += '/' + thisMonth + '/' + thisYear;
    return MPRName;
  }
}
