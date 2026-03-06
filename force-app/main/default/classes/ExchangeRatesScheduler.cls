/*
 * Made by Dmitry Trufanov from Synebo
 * Created date : 04/10/2019
     * Last update date: 
     * Change made: 07/10/2019
 */
public class ExchangeRatesScheduler implements Schedulable{
    
    private static String REQUEST_URL = 'https://www.boi.org.il/currency.xml?curr=';
    
    public static void scheduleDaily() {
        System.schedule('ExchangeRatesScheduler','0 0 01 * * ?', new ExchangeRatesScheduler());
    }
    
    public void execute(SchedulableContext SC) {  
        retreiveExchangeRates();
    }
    
    @future(callout=true)
    private static void retreiveExchangeRates(){
        List<BOI_Currency_Settings__c> settings = BOI_Currency_Settings__c.getAll().values();
        List<Daily_Exchange_Rate__c> exchangeRateList = new List<Daily_Exchange_Rate__c>();
        //What is the purpose of 'exchangeRateDates'? - This date values used to find is there any duplicate records exists for those dates
        List<Date> exchangeRateDates = new List<Date>();
        for(BOI_Currency_Settings__c setting_i : settings){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(REQUEST_URL + setting_i.Currency_Code__c);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            SYstem.debug('response.getStatusCode() - ' + response.getStatusCode());
            if (response.getStatusCode() == 200) {
				Dom.XMLNode currencies = response.getBodyDocument().getRootElement();
                Dom.XMLNode curency = currencies.getChildElement('CURRENCY',null);
                if(curency!=null){
                    Daily_Exchange_Rate__c der = new Daily_Exchange_Rate__c();
                    der.Change__c = Decimal.valueOf(curency.getChildElement('CHANGE',null).getText());
                    der.Rate__c = Decimal.valueOf(curency.getChildElement('RATE',null).getText());
                    der.Country__c = curency.getChildElement('COUNTRY',null).getText();
                    der.Currency_Name__c = curency.getChildElement('NAME',null).getText();
                    der.Currency_Code__c = curency.getChildElement('CURRENCYCODE',null).getText();
                    der.Unit__c = Decimal.valueOf(curency.getChildElement('UNIT',null).getText());
                    Date boiCurrencyUpdateDate= Date.valueOf(currencies.getChildElement('LAST_UPDATE',null).getText());
                    exchangeRateDates.add(boiCurrencyUpdateDate);
                    der.BOI_currency_update_date__c= boiCurrencyUpdateDate;
                    exchangeRateList.add(der);
                }               
            }            
        }
        //Itzik Winograd, 2021-11-15: Add AND Converted_To__c != 'USD'
        List<Daily_Exchange_Rate__c> oldExchangeRateList = [SELECT ID
                                                              FROM Daily_Exchange_Rate__c
                                                             WHERE BOI_currency_update_date__c IN :exchangeRateDates
                                                               AND Converted_To__c != 'USD' ]; // Check for duplicates, but exclude Netsuite records
        if(!oldExchangeRateList.isEmpty())
            delete oldExchangeRateList;																														// Delete duplicates
        insert exchangeRateList;
        for(Daily_Exchange_Rate__c der_i:exchangeRateList)
            System.debug('der_i.Id ' + der_i.Id);
    }
}