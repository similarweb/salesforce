/**
 * @author Itzik Winograd
 * @date 31/01/2021
 * @description Publish a platform Event for  Closed-Won Opps
 * Created to alert the gong on the chrome addon for accounts
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 22/07/2021
 * description - Added AlertForClosedWonOPpps.firstRun static boolean to prevent 2 runs.
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 13/10/2021
 * description - in filterClosedWonOpps, added opp.Type in 'New Sale', 'Renewal', 'Upsell'
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 09/11/2021
 * description - Added logs. That can be turend off via custom metadata GeneralConfig "Alert_for_closedwon_opps_create_Logs".
 *               Use Alert_for_closedwon_opps_Opp_Types metadat for the valid opportuinty.Type valeus;
 * --------------------------------------------------------------------------------------
 */
public class AlertForClosedWonOPpps {
  public static Boolean firstRun = true;
  public static Set<Id> oppIdsSet = new Set<Id>();

  public Boolean createLogs = GeneralUtil.retrieveConfigurationMetadata(
        'Alert_for_closedwon_opps_create_Logs'
      )[0]
      .Text_Value__c == 'true'
    ? true
    : false;
  public string logText = '[start] class AlertForClosedWonOPpps';

  /**
   * @author Itzik Winograd
   * @date 31/01/2021
   * @description Main method
   * @param List<Opportunity> newList - list of the new/uipdated opps
   * @param Map<Id,Opportunity> oldMap - Map Id,OldOpportunity record
   * @return none.
   */
  public void alertOnClosedWonOppMain(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    //filter new closed won opps
    logText += '\n[info] number of opps in trigger: ' + newList.size();
    logText += '\n[info] is firstRun? ' + AlertForClosedWonOPpps.firstRun;
    List<Opportunity> filteredOpps = new List<Opportunity>();
    //if(AlertForClosedWonOPpps.firstRun){
    filteredOpps = filterClosedWonOpps(newList, oldMap);
    if (!filteredOpps.isEmpty()) {
      logText +=
        '\n[info] number of opps that passed filtering and sent for publishing: ' +
        filteredOpps.size();
      System.enqueueJob(new GetUsersPhotosAndPublish(filteredOpps));
      AlertForClosedWonOPpps.firstRun = false;
    } else {
      logText += '\n[info] no opps passed filtering, nothing to publish.';
    }
    if (createLogs) {
      EventBus.publish(
        LogEventUtils.createLogEventRecord(
          filteredOpps,
          'AlertForClosedWonOPpps',
          'alertOnClosedWonOppMain',
          logText,
          '',
          'Info',
          null,
          null
        )
      );
      //}
    }
  }

  /**
   * @author Itzik Winograd
   * @date 31/01/2021
   * @description: Filter recrods - only closed won and not Feature update
   * @param List<Opportunity> newList - list of the new/uipdated opps
   * @param Map<Id,Opportunity> oldMap - Map Id,OldOpportunity record
   * @return List<Opportunity> - only opps that are newly colesd won.
   * =================================================================================================
   * @date 2021-11-08
   * @author Itzik Winograd
   * @description: minimized the opp.isWon condition - remove duplicate checks
   */
  public List<Opportunity> filterClosedWonOpps(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    List<Opportunity> filteredOpps = new List<Opportunity>();
    String validTypes = GeneralUtil.retrieveConfigurationMetadata(
        'Alert_for_closedwon_opps_Opp_Types'
      )[0]
      .Text_Value__c;
    for (Opportunity opp : newList) {
      logText +=
        '\n[info] opp.Id: ' +
        opp.Id +
        ', StageName: ' +
        opp.StageName +
        ', isWon: ' +
        opp.isWon;
      if (
        opp.isWon &&
        !oppIdsSet.contains(opp.Id) &&
        validTypes.contains(';' + opp.Type + ';') &&
        (oldMap == null || !oldMap.get(opp.id).IsWon)
      ) {
        filteredOpps.add(opp);
        oppIdsSet.add(opp.Id);
      }
    }
    //System.debug('### filteredOpps: ' + filteredOpps);
    return filteredOpps;
  }

  /* Queuable class for performing callouts */
  private class GetUsersPhotosAndPublish implements Queueable, Database.AllowsCallouts {
    private List<Opportunity> filteredOpps;
    public Boolean createLogs = GeneralUtil.retrieveConfigurationMetadata(
          'Alert_for_closedwon_opps_create_Logs'
        )[0]
        .Text_Value__c == 'true'
      ? true
      : false;
    private string logText = '[start] class GetUsersPhotosAndPublish';

    public GetUsersPhotosAndPublish(List<Opportunity> filteredOpps) {
      this.filteredOpps = filteredOpps;
    }

    public void execute(QueueableContext context) {
      //create a list of Alert_for_ClosedWon_Opportunity__e alerts
      List<Alert_for_ClosedWon_Opportunity__e> closedWonAlerts = createAlerts(
        filteredOpps
      );
      logText += '\n[info] closedWonAlerts size: ' + closedWonAlerts.size();
      //publish the events
      publishClosedWonAlerts(closedWonAlerts);
      if (createLogs) {
        EventBus.publish(
          LogEventUtils.createLogEventRecord(
            new List<Id>{},
            'GetUsersPhotosAndPublish',
            'execute',
            logText,
            JSON.serializePretty(createLogs),
            'Info',
            null,
            null
          )
        );
      }
    }

    /**
     * @author Itzik Winograd
     * @date 31/01/2021
     * @description: Creates a list of the Alert_for_ClosedWon_Opportunity__e pltaform events
     * @param List<Opportunity> filteredOpps - list of opportunities that are closed won
     * @return List<Alert_for_ClosedWon_Opportunity__e> - list of platform events
     */
    public List<Alert_for_ClosedWon_Opportunity__e> createAlerts(
      List<Opportunity> filteredOpps
    ) {
      List<Alert_for_ClosedWon_Opportunity__e> closedWonAlerts = new List<Alert_for_ClosedWon_Opportunity__e>();
      //Get the field mapping from the custom metadata with the given process name
      List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
        'ClosedWonAlertGong'
      );
      //Generate fieldMappingData unit
      FieldMappingUtil.FieldMappingData fmd = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(
        fieldsMappingList
      );
      //Get the opportunities with all related data
      String query = fmd.getRecordsFromSObject(
        'Opportunity',
        'Id, Owner.FullPhotoUrl'
      );
      query += ' WHERE Id IN  :filteredOpps';
      List<Opportunity> fullOppsList = Database.query(query);
      for (Opportunity opp : fullOppsList) {
        closedWonAlerts.add(createSingleAlert(opp, fmd));
      }
      return closedWonAlerts;
    }

    /**
     * @author Itzik Winograd
     * @date 31/01/2021
     * @description: Create a single Alert_for_ClosedWon_Opportunity__e alert
     * @param Opportunity Opp - an Opportunity
     * @param FieldMappingUtil.FieldMappingData fmd - Field Mapping data unit
     * @return List<Alert_for_ClosedWon_Opportunity__e> - list of platform events
     */
    public Alert_for_ClosedWon_Opportunity__e createSingleAlert(
      Opportunity opp,
      FieldMappingUtil.FieldMappingData fmd
    ) {
      Alert_for_ClosedWon_Opportunity__e alert = new Alert_for_ClosedWon_Opportunity__e();
      //Assign values from the sObject to the FMD
      fmd.populateValuesFromSObject(opp);
      Object obj;
      for (String destinationField : fmd.fieldMappingDataUnitMap.keySet()) {
        obj = fmd.fieldMappingDataUnitMap.get(destinationField).getValue();
        alert.put(destinationField, obj);
        //System.debug('### destinationField: ' + destinationField + ', value: ' + obj);
      }
      alert.OwnerPicture__c = getCurrentUserPhoto(opp.Owner.FullPhotoUrl);
      alert.OwnerName__c = opp.Owner.Name;
      alert.OwnerDivision__c = opp.Owner.Division;
      //System.debug('### destinationField: OwnerPicture__c, value: ' + alert.OwnerPicture__c);
      logText += '\n[info] for oppId: ' + opp.Id + ', added alert: ' + alert;
      return alert;
    }

    /**
     * @author Itzik Winograd
     * @date 02/02/2021
     * @description: take the current user profile pictre and convert it to base 64.
     * @param String fullPhotoUrl - the fullPhotoUrl queried with the opp
     * @return base 64 stGring of the photo
     */
    public String getCurrentUserPhoto(String fullPhotoUrl) {
      //"Navigate" to the page with the image
      PageReference ref = new PageReference(fullPhotoUrl);
      //Get the content of that page (the image) as a blob
      Blob b = Test.isRunningTest()
        ? Blob.valueof('TEST DATA')
        : ref.getContent();
      //Convert it to base64 and return
      return (String) EncodingUtil.base64Encode(b);
    }

    /**
     * @author Itzik Winograd
     * @date 02/02/2021
     * @description: Publish the alerets
     * @param List<Alert_for_ClosedWon_Opportunity__e>  closedWonAlerts - list of platform events to publis
     * @return none
     */
    public void publishClosedWonAlerts(
      List<Alert_for_ClosedWon_Opportunity__e> closedWonAlerts
    ) {
      // Call method to publish events.
      List<Database.SaveResult> results = EventBus.publish(closedWonAlerts);
      // Inspect publishing result for each event
      for (Integer i = 0; i < results.size(); i++) {
        Database.SaveResult sr = results[i];
        if (sr.isSuccess()) {
          System.debug('Successfully published event.');
          logText += '\n[info] successfully published: ' + sr;
        } else {
          for (Database.Error err : sr.getErrors()) {
            System.debug(
              'Error returned: ' +
                err.getStatusCode() +
                ' - ' +
                err.getMessage()
            );
            logText +=
              '\n[Error] publish error: ' +
              err.getStatusCode() +
              ' - ' +
              err.getMessage();
          }
        }
      }
    }
  }
}
