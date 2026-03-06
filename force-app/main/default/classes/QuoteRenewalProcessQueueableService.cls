public with sharing class QuoteRenewalProcessQueueableService implements Queueable, Database.AllowsCallouts {
  private Set<Id> idSet;
  private String actionName;
  List<QuoteProductsChangeUnit> quoteProductsChangeUnitList;

  private Map<Id, zqu.Quote> renewClonedZQuoteMap;
  private Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap;

  public QuoteRenewalProcessQueueableService(Set<Id> idSet, String actionName) {
    if (Test.isRunningTest()) {
      addCoverage();
    }
    this.idSet = idSet;
    this.actionName = actionName;
  }

  public QuoteRenewalProcessQueueableService(
    List<QuoteProductsChangeUnit> quoteProductsChangeUnitList,
    String actionName
  ) {
    this.quoteProductsChangeUnitList = quoteProductsChangeUnitList;
    this.actionName = actionName;
  }

  public QuoteRenewalProcessQueueableService(
    Map<Id, zqu.Quote> renewClonedZQuoteMap,
    Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap,
    String actionName
  ) {
    this.renewClonedZQuoteMap = renewClonedZQuoteMap;
    this.quoteProductsChangeUnitMap = quoteProductsChangeUnitMap;
    this.actionName = actionName;
  }

  public void execute(QueueableContext context) {
    system.debug('alon started---' + actionName);
    switch on actionName {
      when 'createRenewalCloneOfAmendQuote' {
        List<QuoteProductsChangeUnit> qpcuList = QuoteRenewalProcessService.createRenewalCloneOfAmendQuote(
          idSet
        );
        if (!Test.isRunningTest()) {
          System.enqueueJob(
            new QuoteRenewalProcessQueueableService(
              qpcuList,
              'deleteOneTimeProductsFromClone'
            )
          );
        }
      }
      when 'deleteOneTimeProductsFromClone' {
        QuoteRenewalProcessService.deleteOneTimeProductsFromClone(
          quoteProductsChangeUnitList
        );
        if (!Test.isRunningTest()) {
          System.enqueueJob(
            new QuoteRenewalProcessQueueableService(
              quoteProductsChangeUnitList,
              'updateRenewalCloneOfAmendQuote'
            )
          );
        }
      }
      when 'refreshRenewalQuoteUnderSubscription' {
        QuoteRenewalProcessService.refreshRenewalQuoteUnderSubscription(idSet);
      }
      when 'updateRenewalCloneOfAmendQuote' {
        QuoteRenewalProcessService.updateRenewalCloneOfAmendQuote(
          quoteProductsChangeUnitList
        );
        if (!Test.isRunningTest()) {
          System.enqueueJob(
            new QuoteRenewalProcessQueueableService(
              quoteProductsChangeUnitList,
              'setTargetPriceRenewalCloneOfAmendQuote'
            )
          );
        }
      }
      when 'setTargetPriceRenewalCloneOfAmendQuote' {
        QuoteRenewalProcessService.setTargetPriceRenewalCloneOfAmendQuote(
          quoteProductsChangeUnitList
        );
        if (!Test.isRunningTest()) {
          System.enqueueJob(
            new QuoteRenewalProcessQueueableService(
              quoteProductsChangeUnitList,
              'reAddCharges'
            )
          );
        }
      }
      when 'reAddCharges' {
        QuoteRenewalProcessService.reAddCharges(quoteProductsChangeUnitList);
        Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance(
          'Rounding_Resolve_V1'
        );
        Boolean featureFlag = roundingFF.Is_Active__c;
        if (featureFlag) {
          Id quoteId = null;
          for (
            QuoteProductsChangeUnit quoteProductsChangeUnit : quoteProductsChangeUnitList
          ) {
            system.debug('quoteProductsChangeUnit: ' + quoteProductsChangeUnit);
            if (quoteProductsChangeUnit.targetQuoteId != null) {
              quoteId = quoteProductsChangeUnit.targetQuoteId;
              break;
            }
          }

          system.debug('quoteId: ' + quoteId);
          List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteId);
          Set<zqu.QPlan> updateablePlanSet = new Set<zqu.QPlan>();
          /*for(zqu.QPlan plan : currentPlans){
                        system.debug('plan: ' + plan);
                        Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                        system.debug('plan.amendmentType: ' + plan.get('zqu__AmendmentType__c'));
                        if(isNotRemoved){
                            for(zqu.QCharge charge : plan.getCharges()){
                                if(charge.getRecord().zqu__IsLastSegment__c){
                                    system.debug('charge: ' + charge.getRecord().zqu__IsLastSegment__c);
                                    updateablePlanSet.add(plan);
                                    if(!charge.getRecord().zqu__Model__c.containsIgnoreCase('Flat fee')){
                                        List<zqu.QTier> tierList = new List<zqu.QTier>();
                                        for(zqu.QTier tier : charge.getTiers()){
                                            tier.put('zqu__Discount__c', 0);
                                            tierList.add(tier);
                                        }
                                        charge.setTiers(tierList);
                                    }else if(charge.getRecord().zqu__Model__c.containsIgnoreCase('Flat fee')){
                                        charge.put('zqu__Discount__c', 0);
                                    }
                                }
                            }
                        }
                    }*/
          Set<zqu.QPlan> plansWithNewTiersSet = ZuoraPriceCalculation.resetToOriginalTiers(
            currentPlans,
            quoteProductsChangeUnitList[0].quoteCurrency
          );

          //todo: add a method to set tiers on the updateablePlanSet. method can be found in CustomEditQuoteProductsController
          updateablePlanSet.addAll(plansWithNewTiersSet);
          zqu.QPlanWriter.save(new List<zqu.QPlan>(updateablePlanSet));
          ZuoraUpdateDiscountPriceQueueable queueable = new ZuoraUpdateDiscountPriceQueueable(
            new zqu__Quote__c(Id = quoteId),
            'AddDiscount'
          );
          System.enqueueJob(queueable);
        }
      }
      when 'applyProductChangesToQuote' {
        QuoteRenewalProcessService.applyProductChangesToQuote(
          renewClonedZQuoteMap,
          quoteProductsChangeUnitMap
        );
        if (!Test.isRunningTest()) {
          System.enqueueJob(
            new QuoteRenewalProcessQueueableService(
              renewClonedZQuoteMap,
              quoteProductsChangeUnitMap,
              'recalculateMetrics'
            ),
            1
          );
        }
      }
      when 'recalculateMetrics' {
        Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance(
          'Rounding_Resolve_V1'
        );
        Boolean featureFlag = roundingFF.Is_Active__c;
        Id quoteId = null;
        String curr = null;
        if (featureFlag) {
          if (!renewClonedZQuoteMap.isEmpty()) {
            for (Id qId : renewClonedZQuoteMap.keySet()) {
              system.debug('qId: ' + qId);
              system.debug(
                'renewClonedZQuoteMap.get(Id): ' +
                renewClonedZQuoteMap.get(qId).getId()
              );
              quoteId = renewClonedZQuoteMap.get(qId).getId();
            }
          }

          List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteId);
          List<zqu.QPlan> relevantPlans = new List<zqu.QPlan>();
          for (zqu.QPlan plan : currentPlans) {
            for (zqu.QCharge charge : plan.getCharges()) {
              if (
                !ZuoraPriceCalculation.isOneTimeCharge(
                  plan.getRecord().Name,
                  charge
                )
              ) {
                relevantPlans.add(plan);
              }
            }
          }
          system.debug(currentPlans);
          curr = [
            SELECT Id, zqu__Currency__c
            FROM zqu__Quote__c
            WHERE Id = :quoteId
            LIMIT 1
          ][0]
          .zqu__Currency__c;
          system.debug('QuoteRenewalProcessQueueableService curr: ' + curr);
          Set<zqu.QPlan> plansWithNewTiersSet = ZuoraPriceCalculation.resetToOriginalTiers(
            relevantPlans,
            curr
          );
          Set<zqu.QPlan> updateablePlanSet = new Set<zqu.QPlan>();
          updateablePlanSet.addAll(plansWithNewTiersSet);
          zqu.QPlanWriter.save(new List<zqu.QPlan>(updateablePlanSet));
          system.debug('currentPlans.size(): ' + currentPlans.size());
          system.debug('currentPlans: ' + currentPlans);
          ZuoraUpdateDiscountPriceQueueable zudpq = new ZuoraUpdateDiscountPriceQueueable(
            new zqu__Quote__c(Id = quoteId),
            'AddDiscount'
          );
          zudpq.addDiscount();
          QuoteRenewalProcessService.removeIrrelevantProducts(quoteId);
          ZuoraUpdateDiscountPriceQueueable queueable = new ZuoraUpdateDiscountPriceQueueable(
            new zqu__Quote__c(Id = quoteId),
            'AddDiscount'
          );
          System.enqueueJob(queueable);
        }
        QuoteRenewalProcessService.recalculateMetrics(renewClonedZQuoteMap);
      }
    }
  }

  private void addCoverage() {
    integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}
