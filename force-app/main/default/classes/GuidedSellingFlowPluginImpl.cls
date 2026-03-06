global class GuidedSellingFlowPluginImpl implements zqu.SelectProductComponentOptions.IGuidedSellingFlowPlugin{
    
    public List<Id> getFlows(Id quoteId){ 
        System.debug('GuidedSellingFlowPluginImpl started');   
        List < Id > flowIds = new List < Id >();
        if(String.isBlank(quoteId))
            return flowIds;
        List <Id> allowedFlowIds = queryGuidedSellingFlowIds(quoteId);
        if (allowedFlowIds.isEmpty()) {
            return flowIds;
        }
        Map<Id, List<String>> guidedSellingFlowToStepNamesMap = getGuidedSellingFlowToStepNamesMap(allowedFlowIds);
        Map<String, List<ZuoraListFilterWrapper>> guidedSellingStepNameToFilterMap = getGuidedSellingStepNameToFilterMap(quoteId, guidedSellingFlowToStepNamesMap);
        List<zqu__ProductRatePlan__c> productRatePlanList = queryProductsForAllFilters(quoteId,guidedSellingStepNameToFilterMap);
        System.debug('productRatePlanList: ' + JSON.serializePretty(productRatePlanList));
        System.debug('limits ' + Limits.getQueryRows());
        Long before = Datetime.now().getTime();
        flowIds = filterFlowsWithProducts(productRatePlanList,guidedSellingStepNameToFilterMap,guidedSellingFlowToStepNamesMap);
        Long after = Datetime.now().getTime();
        Decimal diff = after - before;
        System.debug('Call time (seconds):' + diff.divide(1000,9));
        System.debug('flowIds: ' + flowIds);
        return flowIds;
    }

    private static List <Id> queryGuidedSellingFlowIds(String quoteId){
        List<String> flowNames = getAllowedFlowNamesForQuoteSubscription(quoteId);
        
        List < Id > flowIds = new List < Id >();
        List <zqu__GuidedSellingFlow__c> flows = [SELECT Id
                                                  FROM zqu__GuidedSellingFlow__c 
                                                  WHERE zqu__IncludeInProductSelector__c = true 
                                                  AND Name IN :flowNames
        ]; 
        for(zqu__GuidedSellingFlow__c flow : flows) {
            flowIds.add(flow.Id);
        }
        System.debug('guidedSellingFlowIds flowIds: ' + flowIds);
        return flowIds;
    }

    private static List<String> getAllowedFlowNamesForQuoteSubscription (String quoteId){
        zqu__Quote__c quote = [ SELECT Name
                                     , Guided_Flow__c 
                                FROM zqu__Quote__c 
                                WHERE Id = :quoteId
                                LIMIT 1
        ];
        if (quote == null) {
            throw new GuidedSellingFlowPluginException('Quote is not exist');
        }
        if (Test.isRunningTest()) {
            return new List<String>{'TestGuidedSellingFlow'};
        }
        if (String.isBlank(quote.Guided_Flow__c)) {
            // throw new GuidedSellingFlowPluginException('Quote subscriprion has empty Guided_Flow__c field');
            return new List<String>();
        }
        List<String> flowNames = quote.Guided_Flow__c.split(',');
        for (Integer i = 0; i < flowNames.size(); i++) {
            flowNames[i] = flowNames[i].trim();
        }
        System.debug('flowNames: ' + flowNames);
        return flowNames;
    }

    private static Map<Id, List<String>> getGuidedSellingFlowToStepNamesMap(List <Id> allowedFlowIds){
        Map<Id, List<String>> guidedSellingFlowToStepNamesMap = new Map<Id, List<String>>();
        List<zqu__StepToFlowMap__c> stepToFlowList = [SELECT Id
                                                             , zqu__GuidedSellingStep__c
                                                             , zqu__GuidedSellingStep__r.Name 
                                                             , zqu__GuidedSellingFlow__c
                                                      FROM zqu__StepToFlowMap__c
                                                      WHERE zqu__GuidedSellingFlow__c IN :allowedFlowIds
        ];
        for (zqu__StepToFlowMap__c stfm_i : stepToFlowList) {
            List<String> stepNameList = new List<String>();
            if (guidedSellingFlowToStepNamesMap.containsKey(stfm_i.zqu__GuidedSellingFlow__c)) {
                stepNameList = guidedSellingFlowToStepNamesMap.get(stfm_i.zqu__GuidedSellingFlow__c);
            }
            stepNameList.add(stfm_i.zqu__GuidedSellingStep__r.Name);
            guidedSellingFlowToStepNamesMap.put(stfm_i.zqu__GuidedSellingFlow__c, stepNameList);
        }
        System.debug('guidedSellingFlowToStepNamesMap: ' + guidedSellingFlowToStepNamesMap);
        return guidedSellingFlowToStepNamesMap;
        //returns a map of alloed flows to step names
    }

    private static Map<String, List<ZuoraListFilterWrapper>> getGuidedSellingStepNameToFilterMap(String quoteId, Map<Id, List<String>> guidedSellingFlowToStepNamesMap){
        Map<String, List<ZuoraListFilterWrapper>> guidedSellingStepNameToFilterMap = new Map<String, List<ZuoraListFilterWrapper>>();
        List<String> stepNameList = new List<String>();
        for (List<String> stepNamesList_i : guidedSellingFlowToStepNamesMap.values()) {
            stepNameList.addAll(stepNamesList_i);
        }
        List<zqu__List_Filter_Item__c> filterItemList = [SELECT Id
                                                              , zqu__Field_Name__c
                                                              , zqu__Fixed_Value__c
                                                              , zqu__LeftFieldLabel__c
                                                              , zqu__Left_Field_Type__c
                                                              , zqu__Left_Object_Name__c
                                                              , zqu__Left_Object_Type__c
                                                              , zqu__List_Filter__c
                                                              , zqu__Operator__c
                                                              , zqu__RightFieldLabel__c
                                                              , zqu__Right_Object_Context_Key__c
                                                              , zqu__Right_Object_Name__c
                                                              , zqu__Right_Object_Type__c
                                                              , zqu__Segment_Id__c
                                                              , zqu__SortOrder__c
                                                              , zqu__Value__c
                                                              , zqu__List_Filter__r.Name
                                                         FROM zqu__List_Filter_Item__c 
                                                         WHERE zqu__List_Filter__r.Name IN :stepNameList
        ];
        ZuoraListFilterWrapper.obtainRelatedObjectsForFilters(quoteId,filterItemList);
        for (zqu__List_Filter_Item__c lfi_i : filterItemList) {
            List<ZuoraListFilterWrapper> curfilterItemList = new List<ZuoraListFilterWrapper>();
            if(guidedSellingStepNameToFilterMap.containsKey(lfi_i.zqu__List_Filter__r.Name)){
                curfilterItemList = guidedSellingStepNameToFilterMap.get(lfi_i.zqu__List_Filter__r.Name);
            }
            ZuoraListFilterWrapper listFilterWrapper = new ZuoraListFilterWrapper(lfi_i);
            curfilterItemList.add(listFilterWrapper);
            guidedSellingStepNameToFilterMap.put(listFilterWrapper.filterItem.zqu__List_Filter__r.Name,curfilterItemList);
        }
        System.debug('guidedSellingStepNameToFilterMap: ' + guidedSellingStepNameToFilterMap);
        return guidedSellingStepNameToFilterMap;
    }

    private static List<zqu__ProductRatePlan__c> queryProductsForAllFilters(Id quoteId, Map<String, List<ZuoraListFilterWrapper>> guidedSellingStepNameToFilterMap){
        if (guidedSellingStepNameToFilterMap.isEmpty()) {
            return new List<zqu__ProductRatePlan__c>();
        }
        List<ZuoraListFilterWrapper> allFilterList = new List<ZuoraListFilterWrapper>();
        for (List<ZuoraListFilterWrapper> lfiList_i : guidedSellingStepNameToFilterMap.values()) {
            allFilterList.addAll(lfiList_i);
        }
        String productQuery = 'SELECT Id, ';
        for (ZuoraListFilterWrapper lfi_i : allFilterList) {
            if (!productQuery.contains(lfi_i.getLeftObjectQueryName())) {
                productQuery+= lfi_i.getLeftObjectQueryName()+', ';
            }
        }
        productQuery = productQuery.removeEnd(', ');
        productQuery+= ' FROM zqu__ProductRatePlan__c WHERE ';
        for (List<ZuoraListFilterWrapper> lfiList_i : guidedSellingStepNameToFilterMap.values()) {
            productQuery+='(';
            Map<String, List<String>> segmentToCriteriaMap = new Map<String, List<String>>();
            for (ZuoraListFilterWrapper lfi_i : lfiList_i) {
                List <String> criteriaList = new List <String>();
                if (segmentToCriteriaMap.containsKey(lfi_i.filterItem.zqu__Segment_Id__c)) {
                    criteriaList = segmentToCriteriaMap.get(lfi_i.filterItem.zqu__Segment_Id__c);
                }
                String criteria = lfi_i.getLeftObjectQueryName();
                String operator = lfi_i.getOperator();
                criteria += ' ' + operator + ' ';
                if (operator == 'LIKE') {
                    criteria += '\'%' + lfi_i.getRightObjectValue() + '%\'';
                } else {
                    criteria += '\'' + lfi_i.getRightObjectValue() + '\'';
                }
                criteriaList.add(criteria);
                segmentToCriteriaMap.put(lfi_i.filterItem.zqu__Segment_Id__c, criteriaList);
            }
    
            for (List<String> criteriaList_i : segmentToCriteriaMap.values()) {
                productQuery+='(';
                for (String criteria_i : criteriaList_i) {
                    productQuery+=criteria_i + ' AND ';
                }
                productQuery = productQuery.removeEnd(' AND ');
                productQuery+=') OR ';
            }
            productQuery = productQuery.removeEnd(' OR ');
            productQuery+=') OR ';
        }
        productQuery = productQuery.removeEnd(' OR ');
        System.debug('productQuery ' + productQuery);
        return (List<zqu__ProductRatePlan__c>)Database.query(productQuery);
    }

    private static List<Id> filterFlowsWithProducts(List<zqu__ProductRatePlan__c> productRatePlanList
                                                    , Map<String, List<ZuoraListFilterWrapper>> guidedSellingStepNameToFilterMap
                                                    , Map<Id, List<String>> guidedSellingFlowToStepNamesMap)
    {
        System.debug('productRatePlanList: ' + productRatePlanList);
        System.debug('guidedSellingStepNameToFilterMap: ' + guidedSellingStepNameToFilterMap);
        System.debug('guidedSellingFlowToStepNamesMap: ' + guidedSellingFlowToStepNamesMap);

        Map<String, Integer> guidedSellingStepNameToProductAmountMap = new Map<String, Integer>();
        for (zqu__ProductRatePlan__c product_i : productRatePlanList) {
            for (String stepName_i : guidedSellingStepNameToFilterMap.keySet()) {
                List<ZuoraListFilterWrapper> listFilterList = guidedSellingStepNameToFilterMap.get(stepName_i);
                Integer productAmount = 0;
                if (guidedSellingStepNameToProductAmountMap.containsKey(stepName_i)) {
                    productAmount = guidedSellingStepNameToProductAmountMap.get(stepName_i);
                    if (productAmount > 0) {
                        continue;
                    }
                }
                Boolean isProductMatch = false;
                Map<String, Boolean> segmentToCriteriaMatchMap = new Map<String, Boolean>();
                for (ZuoraListFilterWrapper listFilter_i : listFilterList) {
                    Object productValue;
                    Boolean isCriteriaMatch = true;
                    String segmentName = listFilter_i.filterItem.zqu__Segment_Id__c;
                    if (segmentToCriteriaMatchMap.containsKey(segmentName)) {
                        isCriteriaMatch = segmentToCriteriaMatchMap.get(segmentName);
                    }
                    if (listFilter_i.getLeftObjectName().endsWith('__c')) {
                        productValue = product_i.get(listFilter_i.getLeftObjectFieldName());
                    } else {
                        productValue = product_i.getSObject(listFilter_i.getLeftObjectName()).get(listFilter_i.getLeftObjectFieldName());
                    }
                    Object quoteValue = listFilter_i.getRightObjectValue();
                    if (listFilter_i.filterItem.zqu__Operator__c == 'equals' || listFilter_i.filterItem.zqu__Operator__c == '=') {
                        isCriteriaMatch = isCriteriaMatch && (productValue == quoteValue);
                    } else if(listFilter_i.filterItem.zqu__Operator__c == 'not equals'){
                        isCriteriaMatch = isCriteriaMatch && (productValue != quoteValue);
                    } else if(listFilter_i.filterItem.zqu__Operator__c == 'lower than'){
                        isCriteriaMatch = isCriteriaMatch && ((Decimal)productValue < (Decimal)quoteValue);
                    } else if(listFilter_i.filterItem.zqu__Operator__c == 'lower or equal'){
                        isCriteriaMatch = isCriteriaMatch && ((Decimal)productValue <= (Decimal)quoteValue);
                    } else if(listFilter_i.filterItem.zqu__Operator__c == 'greater than'){
                        isCriteriaMatch = isCriteriaMatch && ((Decimal)productValue > (Decimal)quoteValue);
                    } else if(listFilter_i.filterItem.zqu__Operator__c == 'greater or equal'){
                        isCriteriaMatch = isCriteriaMatch && ((Decimal)productValue >= (Decimal)quoteValue);
                    } else if(listFilter_i.filterItem.zqu__Operator__c == 'contains'){
                        isCriteriaMatch = isCriteriaMatch && (((String)productValue).containsIgnoreCase((String)quoteValue));
                    }
                    segmentToCriteriaMatchMap.put(segmentName,isCriteriaMatch);
                }
                for (Boolean criteriaMatchingResult_i : segmentToCriteriaMatchMap.values()) {
                    isProductMatch = isProductMatch || criteriaMatchingResult_i;
                }
                if (isProductMatch) {
                    productAmount++;
                }
                System.debug('Testing Here');
                guidedSellingStepNameToProductAmountMap.put(stepName_i,productAmount);
            }
        }
        System.debug('guidedSellingStepNameToProductAmountMap: ' + JSON.serializePretty(guidedSellingStepNameToProductAmountMap));
        System.debug('guidedSellingFlowToStepNamesMap: ' + JSON.serializePretty(guidedSellingFlowToStepNamesMap));

        List<Id> flowIds = new List<Id>();
        for (Id flowId_i : guidedSellingFlowToStepNamesMap.keySet()) {
            List<String> stepNameList = guidedSellingFlowToStepNamesMap.get(flowId_i);
            for (String stepName : stepNameList) {
                if (guidedSellingStepNameToProductAmountMap.containsKey(stepName) 
                    && guidedSellingStepNameToProductAmountMap.get(stepName) > 0) 
                {
                    flowIds.add(flowId_i);
                    break;
                }
            }
        }
        System.debug('flowIds: ' + flowIds);
        return flowIds;
    }

    public class GuidedSellingFlowPluginException extends Exception {   }
}