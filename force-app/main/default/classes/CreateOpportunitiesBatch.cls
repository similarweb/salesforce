/**
* @author Itzik Winograd
* @date 19/09/2021
* @description MIS-1028, Create Upsell and Renewal opps 
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
public class CreateOpportunitiesBatch implements Database.Batchable<sObject> {

    private String oppType;
    //private final String CREATE_OPPS_NAME_RENEWAL = 'CreateOpps_Renewal';
    //private final String CREATE_OPPS_NAME_UPSELL = 'CreateOpps_Upsell';
    private List<Log_Event__e> logEventsList = new List<Log_Event__e>();
    private Map<String,Decimal> exchangeRateMap = GeneralUtil.getNetsuiteDailyExchangeRateMap();

    /**
    * @author Itzik Winograd
    * @date 19/09/2021
    * @description Constructor. set the type of the opportunities to create.
    * @param String oppType - the type of the opp to create: Upsell/Renewal.  
    */
    public CreateOpportunitiesBatch(String oppType) {
        this.oppType = oppType;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        //create query, according on the oppType 
        String query = getQuery(oppType);
        System.debug('### CreateOpportunitiesBatch received type: ' + oppType);

        return Database.getQueryLocator(query);
    }

    /**
    * @author Itzik Winograd
    * @date 19/09/2021
    * @description: Execute method of the batch. According to the type of the batch,
    *               run the method to create the neccessary opps.
    * @param Database.BatchableContext BC.
    * @param List<SObject> scope.
    */
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        System.debug('### CreateOpportunitiesBatch scope: ' + scope);
        //Check the batch-opp type
        List<Opportunity> oppsList = new List<Opportunity>();
        oppsList = createOpps(scope);
        System.debug('### CreateOpportunitiesBatch oppsList: ' + oppsList);
        if(!oppsList.isEmpty()){
            insertOpps(oppsList);
        } else { //no opps were created - but opp should have been created.
            logEventsList.add(LogEventUtils.createLogEventRecord(scope, 'CreateOpportunitiesBatch', 'execute',
                    '', 'The accounts above should create opps, but no opps were created.', 'Error',null,null));
        }

        if(!logEventsList.isEmpty()){
            Eventbus.publish(logEventsList);
        }

    }

    /**
    * @author Itzik Winograd
    * @date 10/10/2021
    * @description Batch finish method. If the current process is "CreateOpps_Renewal" and it's not a test - run another batch of "CreateOpps_Upsell".
    * @param String Database.BatchableContext jobIdParam
    * @return None.
    */
    public void finish(Database.BatchableContext jobIdParam) {
        if (oppType == 'CreateOpps_Renewal' && !Test.isRunningTest()){
            Id batchInstanceId = Database.executeBatch(new CreateOpportunitiesBatch('CreateOpps_Upsell'), 5);
        }
    }

    /**
    * @author Itzik Winograd
    * @date 22/09/2021
    * @description Get the query from the CustomQueriesUtils according to the oppType
    * @param String processName - the processName in the CMT.
    * @return String the query.
    */
    public static String getQuery (String processName) {
        return CustomQueriesUtils.getCustomQuery(processName);
    }

    /**
    * @author Itzik Winograd
    * @date 27/09/2021
    * @description Create opps according to each type mapping. Use custom metadata from the FieldMapping.
    * @param List<Account> the accounts to create opps for.
    * @return List<Opportunity> list of new opps to insert.
    */
    public List<Opportunity> createOpps (List<Account> accountsList){
        List<Opportunity> oppsList = new List<Opportunity>();
        FieldMappingNewUtils fmnu = getFieldMappingNewUtils();
        Opportunity opp;
        for(Account acc: accountsList){
            if(acc.Zuora__Subscriptions__r.isEmpty()){
                System.debug('No subscriptions');
                continue;
            }

			Zuora__Subscription__c firstSubscription = acc.Zuora__Subscriptions__r?.get(0);
			Decimal term = getTerm(firstSubscription.Zuora__InitialTerm__c);

			if (term < 12) {
				System.debug('Term is less than 12: ' + term);
				continue;
			}

            opp = new Opportunity();
            opp = (Opportunity)fmnu.setValuesFromSourceToDestination(acc, opp); //set values to the opp from the "FieldMapping" custom metadata
            //Close date
            Date closeDate = firstSubscription.Zuora__NextRenewalDate__c;
            opp.closeDate = closeDate;
            //Cycle Price
            Integer cyclePriceSubscriptions = getCyclePriceOfSubscriptions(acc.Zuora__Subscriptions__r);
            opp.Cycle_Price_Local__c = cyclePriceSubscriptions;
            //Currency
            opp.Currency__c = firstSubscription.Zuora__CustomerAccount__r.Zuora__Currency__c;
            opp.Exchange_Rate__c = getExchngeRateForCurrency(opp.Currency__c);

            //Set different values for each oppType
            if(oppType == 'CreateOpps_Renewal'){
                opp = setRenewalOppValues(opp);
            } else if(oppType == 'CreateOpps_Upsell'){
                opp = setUpsellOppValues(opp);
            }

            oppsList.add(opp);
        }
        return oppsList;
    }

    private Integer getCyclePriceOfSubscriptions(List<Zuora__Subscription__c> subscriptions){
        Date startDate = subscriptions[0].Zuora__TermStartDate__c;
        Date nextRenewalDate = subscriptions[0].Zuora__NextRenewalDate__c;
        Integer currentMrrCalculated = (subscriptions[0].Zuora__MRR__c * 12).round().intValue();
        System.debug('currentMrrCalculated--'+currentMrrCalculated);
        if(subscriptions.size() > 1){
            System.debug(' more then 1');
            for(Integer index = 1;subscriptions.size() > index; index++){
                if(subscriptions[index].Zuora__TermStartDate__c == startDate && subscriptions[index].Zuora__NextRenewalDate__c == nextRenewalDate){
                    currentMrrCalculated += (subscriptions[index].Zuora__MRR__c *12).round().intValue();
                }
            }
        }
        return currentMrrCalculated;
    }



    /**
    * @author Itzik Winograd
    * @date 27/09/2021
    * @description Sett additional fields for renewal opps
    * @param Opportunity Opp - The opp to add specific renewal-related fields
    * @return Opportunity Opp - update opportunity
    * --- change---
    * @author Itzik Winograd
    * @date 2022-11-13
    * @description MIS-3103: Round Cycle_Price__c and Original_Renewal_Amount__c
    */
    public Opportunity setRenewalOppValues (Opportunity opp){
        opp.Original_Renewal_Date__c = opp.closeDate;
        //Cycle prices
        //Decimal cycleCalc = opp.Cycle_Price_Local__c * opp.Exchange_Rate__c;
        Integer cycleCalc =  (opp.Cycle_Price_Local__c * opp.Exchange_Rate__c).round().intValue();
        opp.Cycle_Price__c = cycleCalc;
        opp.Original_Renewal_Amount__c = opp.Cycle_Price__c;
        return opp;
    }

    /**
    * @author Itzik Winograd
    * @date 27/09/2021
    * @description Sett additional fields for upsell opps
    * @param Opportunity Opp - The opp to add specific upsell-related fields
    * @return Opportunity Opp - update opportunity
    * --- change---
    * @author Itzik Winograd
    * @date 2022-11-13
    * @description MIS-3103: Round Cycle_Price__c and Original_Renewal_Amount__c
    */
    public Opportunity setUpsellOppValues (Opportunity opp){
        //Cycle prices
        //        opp.Cycle_Price_Local__c = opp.Cycle_Price_Local__c * GeneralUtil.getGeneralConfig('Opportunity_Upsell_Rate').Number_Value__c;
        //        Decimal cycleCalc = opp.Cycle_Price_Local__c * opp.Exchange_Rate__c;
        //        opp.Cycle_Price__c = cycleCalc;
        opp.Cycle_Price_Local__c = (opp.Cycle_Price_Local__c * GeneralUtil.getGeneralConfig('Opportunity_Upsell_Rate').Number_Value__c).round().intValue();
        Decimal cycleCalc = opp.Cycle_Price_Local__c * opp.Exchange_Rate__c;
        opp.Cycle_Price__c = cycleCalc.round().intValue();
        return opp;
    }

    /**
    * @author Itzik Winograd
    * @date 10/05/2021
    * @description insert the opps
    * @param List<Opportunity> List of opps to insert
    * @return none
    * --- change---
    * @author Elnur Alibaev
    * @date 2025-08-01
    * @description MIS-7615: Added pricing products creation to upsell, Products movement to renewal
    */
    public void insertOpps (List<Opportunity> oppsList){
        List<Database.SaveResult> oppsSR = Database.insert(oppsList, false);
        List<String> oppIds = new List<String>();

        for (Integer i = 0; i < oppsSR.size(); i++) {
            Database.SaveResult result = oppsSR[i];
            if (!result.isSuccess()) {
                logEventsList.add(LogEventUtils.createLogEventRecord(new List<Id>{oppsList[i].AccountId}, 'CreateOpportunitiesBatch', 'insertOpps',
                        JSON.serialize(oppsList[i]), result.getErrors().toString(), 'Error',null,null));
            } else {
                oppIds.add(result.getId());
            }
        }

        if (oppIds.size() > 0) {
            setPricebooks(oppIds);
        }
        if (oppType == 'CreateOpps_Renewal' && oppIds.size() > 0) {
            moveProducts(oppIds);
        }
        if (oppType == 'CreateOpps_Upsell' && oppIds.size() > 0) {
            createPricingProducts(oppIds);
        }
    }

    /**
    * @author Elnur Alibaev
    * @date 15/08/2025
    * @description Set default pricebook to opps
    * @param List<String> oppIds - List of opps to set pricebooks to
    * @return none
    */
    public void setPricebooks(List<String> oppIds) {
        List<Opportunity> opps = [
                SELECT Id, Pricebook2Id
                FROM Opportunity
                WHERE Id IN: oppIds
        ];
        String pricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = true and IsActive = true LIMIT 1].Id;

        for (Opportunity opp : opps) {
            if (String.isBlank(opp.Pricebook2Id)) {
                opp.Pricebook2Id = pricebookId;
            }
        }

        List<Database.SaveResult> oppsSR = Database.update(opps, false);

        for (Integer i = 0; i < oppsSR.size(); i++) {
            Database.SaveResult result = oppsSR[i];
            if (!result.isSuccess()) {
                logEventsList.add(LogEventUtils.createLogEventRecord(
                        new List<Id>{opps[i].Id}, 'CreateOpportunitiesBatch', 'setPricebooks',
                        JSON.serialize(opps[i]), result.getErrors().toString(), 'Error',null,null));
            }
        }
    }

    /**
    * @author Elnur Alibaev
    * @date 13/08/2025
    * @description Move products from last closed won opp to renewal
    * @param List<String> oppIds - List of renewal opps to move products to
    * @return none
    */
    public void moveProducts(List<String> oppIds) {
        List<Opportunity> opps = [
                SELECT Id, AccountId
                FROM Opportunity
                WHERE Id IN: oppIds
        ];
        List<String> accIds = new List<String>();
        Map<String, String> accToRenewalOpp = new Map<String, String>();

        for (Opportunity opp: opps) {
            accIds.add(opp.AccountId);
            accToRenewalOpp.put(opp.AccountId, opp.Id);
        }

        List<Opportunity> lastClosedWonOpps = [
                SELECT Id, AccountId, (
                        SELECT Id, Product2Id, OpportunityId, UnitPrice, Purchase_Motion__c, Quantity
                        FROM OpportunityLineItems)
                FROM Opportunity
                WHERE AccountId IN: accIds AND StageName = 'Closed Won' AND Type = 'Renewal'
                ORDER BY CloseDate DESC
        ];
        List<String> processedAccs = new List<String>();
        List<OpportunityLineItem> movedProducts = new List<OpportunityLineItem>();

        for (Opportunity opp : lastClosedWonOpps) {
            if (!processedAccs.contains(opp.AccountId)) {
                for (OpportunityLineItem p : opp.OpportunityLineItems) {
                    OpportunityLineItem clonedP = p.clone();
                    clonedP.Id = null;
                    clonedP.OpportunityId = accToRenewalOpp.get(opp.AccountId);
					clonedP.Purchase_Motion__c = 'Renewal';

                    movedProducts.add(clonedP);
                    processedAccs.add(opp.AccountId);
                }
            }
        }

        List<Database.SaveResult> movedProductsSR = Database.insert(movedProducts, false);

        for (Integer i = 0; i < movedProductsSR.size(); i++) {
            Database.SaveResult result = movedProductsSR[i];
            if (!result.isSuccess()) {
                logEventsList.add(LogEventUtils.createLogEventRecord(
                        new List<Id>{movedProducts[i].OpportunityId}, 'CreateOpportunitiesBatch', 'moveProducts',
                        JSON.serialize(movedProducts[i]), result.getErrors().toString(), 'Error',null,null));
            }
        }

        ProductTrackingController.updateProductTracking(oppIds);
    }

    /**
    * @author Elnur Alibaev
    * @date 13/08/2025
    * @description Create Pricing products to upsell opps
    * @param List<String> oppIds - List of upsell opps to create products to
    * @return none
    */
    public void createPricingProducts(List<String> oppIds) {
        List<PricebookEntry> entries = [
                SELECT Id, Product2Id, UnitPrice
                FROM PricebookEntry
                WHERE Product2.Family = 'Pricing' AND IsActive = true
        ];
        List<OpportunityLineItem> pricingProducts = new List<OpportunityLineItem>();

        if (entries.size() == 0) {
            return;
        }

        for (String oppId : oppIds) {
            for (PricebookEntry e : entries) {
                pricingProducts.add(new OpportunityLineItem(
                        Product2Id = e.Product2Id,
                        OpportunityId = oppId,
                        UnitPrice = e.UnitPrice,
                        Purchase_Motion__c = 'Price Increase',
                        Quantity = 1
                ));
            }
        }

        List<Database.SaveResult> productsSR = Database.insert(pricingProducts, false);

        for (Integer i = 0; i < productsSR.size(); i++) {
            Database.SaveResult result = productsSR[i];
            if (!result.isSuccess()) {
                logEventsList.add(LogEventUtils.createLogEventRecord(
                        new List<Id>{pricingProducts[i].OpportunityId}, 'CreateOpportunitiesBatch', 'createPricingProducts',
                        JSON.serialize(pricingProducts[i]), result.getErrors().toString(), 'Error',null,null));
            }
        }

        ProductTrackingController.updateProductTracking(oppIds);
    }

	public Decimal getTerm(String initialTerm) {
		if (String.isBlank(initialTerm)) {
			return 0;
		}

		List<String> initialTermParts = initialTerm.split(' ');
		if (initialTermParts.size() < 2) {
			return 0;
		}

		String termString = initialTermParts.get(0), termUnit = initialTermParts.get(1);

		try {
			Decimal term = Integer.valueOf(termString);

			if (termUnit == 'Days') {
				term /= 30;
			}
			if (termUnit == 'Weeks') {
				term /= 4.2;
			}

			return term;
		} catch (Exception e) {
			System.debug('Term extract error: ' + e.getMessage());
			return 0;
		}
	}

    /**
    * @author Itzik Winograd
    * @date 05/10/2021
    * @description 	Return the Exchenge Rate for a give currency
    *   If Currency__c <> USD, take daily rate from ‘Netsuite Daily Exchange Rate’ (custom settings) and update Exchange_Rate__c,
        then multiply the Cycle_Price_Local__c and update Cycle_Price__c , Original_Renewal_Amount__c.

        Example:
        Currency__c = ‘EUR’
        Cycle_Price_Local__c = 10,000
        Netsuite Daily Exchange Rate (EUR -> USD) = 1.2

        Cycle_Price__c, Original_Renewal_Amount__c = Cycle_Price_Local__c * Netsuite Daily Exchange Rate = 10,000 * 1.2 = 12,000

    * @param String currency.
    * @return Decimal Exchenge Rate.
    */

    public Decimal getExchngeRateForCurrency (String currencyCode){
        Decimal rate = 0;
        if(currencyCode == 'USD'){
            rate = 1;
        } else {
            rate = exchangeRateMap.get(currencyCode);
        }
        return rate;
    }

    /**
    * @author Itzik Winograd
    * @date 11/10/2021
    * @description Get field mapping new utils. If it doesnt load correctly - throw an exception.
    * @param None.
    * @return Void.
    */

    public FieldMappingNewUtils getFieldMappingNewUtils(){
        FieldMappingNewUtils fmnu = new FieldMappingNewUtils(oppType);
        if(fmnu.destinationVsMapping == null){
            throw new FiledMappingErrorException('Couldnt load the field mapping utils necessary: ' + oppType + '.');
        }
        return fmnu;
    }

    private class FiledMappingErrorException extends Exception {  }


}