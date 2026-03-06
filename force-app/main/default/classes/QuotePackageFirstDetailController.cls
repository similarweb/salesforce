/*
    Controller for the "CustomQuoteDetailFirstSectionPage" component. 
    Needed to notify the component if metrics calculation is in progress. 
    (In cases when a component is refreshed)
    Created Date: 13-04-2022
    Created by: Developer Synebo
*/
public with sharing class QuotePackageFirstDetailController {
  public String calculationInProgress { get; set; }

  public QuotePackageFirstDetailController(
    ApexPages.StandardController standardController
  ) {
    Id currentQuoteId = (Id) standardController.getRecord().get('Id');

    zqu__Quote__c currentQuote = [
      SELECT Id, Recalculate_Charge__c
      FROM zqu__Quote__c
      WHERE Id = :currentQuoteId
      LIMIT 1
    ];
    if (currentQuote.Recalculate_Charge__c) {
      calculationInProgress = 'true';
    } else {
      calculationInProgress = 'false';
    }
  }
}
