/**
 * @author Synebo Developer
 * @date 27/12/2021
 * Created for metrics recalculation in asynchronous context (via Queueable)
 */
public with sharing class ZuoraQuoteMetricManipulationQueueable implements Queueable, Database.AllowsCallouts {
  private String quoteId;
  private String actionName;
  private Decimal targetQuoteTotalPrice;
  private Decimal initialTerm;
  private String oneTimeRequestId;
  private String recurringRequestId;
  private Map<String, Decimal> requestMap;

  /**
   * @description Class constructor overload for 4 parameters
   * Used to call updateChargesByTargetTotalPriceMainLogic() method in an Queueable context
   * @param quoteId - String value with id of related Quote
   * @param targetQuoteTotalPrice - Decimal value of Target_Quote_Total_Price__c field from Quote
   * @param initialTerm - Decimal value of zqu__InitialTerm__c field from Quote
   * @param actionName - name of the action which is needed to run via Queueable
   */
  public ZuoraQuoteMetricManipulationQueueable(
    String quoteId,
    Decimal targetQuoteTotalPrice,
    Decimal initialTerm,
    String oneTimeRequestId,
    String recurringRequestId,
    Map<String, Decimal> requestMap,
    String actionName
  ) {
    this.quoteId = quoteId;
    this.targetQuoteTotalPrice = targetQuoteTotalPrice;
    this.initialTerm = initialTerm;
    this.oneTimeRequestId = oneTimeRequestId;
    this.recurringRequestId = recurringRequestId;
    this.requestMap = requestMap;
    this.actionName = actionName;
  }

  /**
   * @description Class constructor overload for 2 parameters
   * Used to made Zuora Callout to run a package metrics recalculatuion process
   * @param quoteId - String value with id of related Quote
   * @param actionName - name of the action which is needed to run via Queueable
   */
  public ZuoraQuoteMetricManipulationQueueable(
    String quoteId,
    String actionName
  ) {
    this.quoteId = quoteId;
    this.actionName = actionName;
  }

  /**
   * Implementation of required method from Queueable interface
   * Contains switch that run different parts of logic depends on the action name
   * @param context - QueueableContext context
   * @return void
   */
  public void execute(QueueableContext context) {
    switch on actionName {
      when 'updateChargesIfMetricsChanged' {
        ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPriceMainLogic(
          quoteId,
          targetQuoteTotalPrice,
          initialTerm,
          oneTimeRequestId,
          recurringRequestId,
          requestMap
        );
        if (!Test.isRunningTest()) {
          System.enqueueJob(
            new ZuoraQuoteMetricManipulationQueueable(
              quoteId,
              'recalculateSubtotal'
            )
          );
        }
      }
      when 'recalculateSubtotal' {
        zqu.zQuoteUtil.ZBillingResult previewResult;
        if (!Test.isRunningTest()) {
          previewResult = zqu.QuoteRecalculateController.JR_recalculate(
            quoteId
          );
        } else {
          previewResult = new zqu.zQuoteUtil.ZBillingResult();
          previewResult.message = 'The Quote metrics value is the latest, no need to preview';
        }
        if (
          (String.isNotBlank(previewResult.message) &&
          previewResult.message.contains(
            'The Quote metrics value is the latest, no need to preview'
          ))
        ) {
          zqu__Quote__c quote = [
            SELECT Id, zqu__SubscriptionType__c
            FROM zqu__Quote__c
            WHERE Id = :quoteId
            LIMIT 1
          ];
          Map<String, Object> fieldNameToValueMap = new Map<String, Object>();
          fieldNameToValueMap.put(
            'exceptionField',
            'Metrics have not been updated'
          );
          if (quote.zqu__SubscriptionType__c == 'New Subscription') {
            Quote_is_changed__e quoteIsChangedEvent = new Quote_is_changed__e();
            quoteIsChangedEvent.quoteId__c = quoteId;
            quoteIsChangedEvent.fieldsJson__c = JSON.serialize(
              fieldNameToValueMap
            );

            System.Eventbus.publish(quoteIsChangedEvent);
          } else if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
            Amend_quote_is_changed__e quoteIsChangedEvent = new Amend_quote_is_changed__e();
            quoteIsChangedEvent.quoteId__c = quoteId;
            quoteIsChangedEvent.fieldsJson__c = JSON.serialize(
              fieldNameToValueMap
            );
            System.Eventbus.publish(quoteIsChangedEvent);
          }
        }
        recalculateIsDoneUpdate(quoteId);
      }
    }
  }

  private static void recalculateIsDoneUpdate(String quoteId) {
    List<Calculation_in_progress__e> calculationInProgressEventList = new List<Calculation_in_progress__e>();
    Calculation_in_progress__e calculationInProgressEvent = new Calculation_in_progress__e();
    calculationInProgressEvent.QuoteId__c = quoteId;
    calculationInProgressEvent.Message__c = 'Finish';
    calculationInProgressEventList.add(calculationInProgressEvent);

    if (!calculationInProgressEventList.isEmpty()) {
      List<Database.SaveResult> results = EventBus.publish(
        calculationInProgressEventList
      );
      for (Database.SaveResult sr : results) {
        if (!sr.isSuccess()) {
          for (Database.Error err : sr.getErrors()) {
            System.debug(
              'Error returned: ' +
                err.getStatusCode() +
                ' - ' +
                err.getMessage()
            );
          }
        }
      }
    }

    zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
    quoteToUpdate.Id = quoteId;
    quoteToUpdate.Recalculate_Charge__c = false;

    update quoteToUpdate;
  }
}
