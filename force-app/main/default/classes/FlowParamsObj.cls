/**
 * Created by Alon.Shalev on 3/11/2024.
 */
public with sharing class FlowParamsObj {
  @AuraEnabled
  public String previousOwnerName;
  @AuraEnabled
  public String currentOwnerEmail;
  @AuraEnabled
  public String currentOwnerName;
  @AuraEnabled
  public String typeOfRecord;
  @AuraEnabled
  public Case caseItem;
  @AuraEnabled
  public FeedComment feedComment;
  @AuraEnabled
  public String picklistvalue;

  public FlowParamsObj() {
  }
}
