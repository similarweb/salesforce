/**
 * @author Itzik Winograd
 * @date 22/08/2021
 * @description This class provides service to create a query from the Custom_Query__mdt.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public without sharing class CustomQueriesUtils {
  /**
   * @author Itzik Winograd
   * @date 09/27/2021
   * @description Builds a query from the custom metadata Custom_Query__mdt.
   * @param String the process name to query the metadata by.
   * @return String fullQuery - the query that was built from all the custom metadata parts.
   */
  public static String getCustomQuery(String processName) {
    String fullQuery = '';
    for (Custom_Query__mdt customQueryPart : [
      SELECT DeveloperName, Order_By__c, Query__c
      FROM Custom_Query__mdt
      WHERE Process_Name__c = :processName
      ORDER BY Order_By__c ASC
    ]) {
      fullQuery += customQueryPart.Query__c + ' ';
    }
    System.debug(
      '### the fullQuery in the Custom_Query__mdt for the process ' +
        processName +
        ' is: ' +
        fullQuery
    );
    return fullQuery;
  }
}
