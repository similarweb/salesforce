/**
* @author Itzik Winograd
* @date 18/07/2021
* @description: Utilitis class for the Currency custom meta data that is holding a list
*               of currencies, their state and the currency name.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
public without sharing class CurrencyUtils {
    /**
    * @author Itzik Winograd
    * @date 18/07/2021
    * @description return a map of exiting currencies in the Currency__mdt.
    * @param None.  
    * @return List<Currency__mdt> with all the currencies 
    */
    public static Map<String,Currency__mdt> getCurrenciesByCodeMap (){ 
        Map<String,Currency__mdt> currenciesMap = new Map<String,Currency__mdt>();
        for (Currency__mdt cur : [SELECT DeveloperName, MasterLabel, Country__c
                                    FROM Currency__mdt]){
            currenciesMap.put(cur.DeveloperName, cur);
        }
        return currenciesMap;
    }
}