@isTest
public class NetsuiteExchangeRatesServiceTest {
    
    @isTest
    static void retreiveExchangeRatesFromNetsuiteEndpointTest(){
        MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
        Test.setMock(HttpCalloutMock.class, mockServiceInstance);
        Test.startTest();
        NetsuiteExchangeRatesService.retreiveExchangeRatesFromNetsuiteEndpoint();
        Test.stopTest();
        System.assertEquals(11, Netsuite_Daily_Exchange_Rate__c.getAll().values().size(), 'Exchange rates not correctly created');
        Netsuite_Daily_Exchange_Rate__c settingGBP = Netsuite_Daily_Exchange_Rate__c.getInstance('GBP');
        Netsuite_Daily_Exchange_Rate__c settingCAD = Netsuite_Daily_Exchange_Rate__c.getInstance('CAD');
        Netsuite_Daily_Exchange_Rate__c settingEUR = Netsuite_Daily_Exchange_Rate__c.getInstance('EUR');
        Netsuite_Daily_Exchange_Rate__c settingCHF = Netsuite_Daily_Exchange_Rate__c.getInstance('CHF');
        Netsuite_Daily_Exchange_Rate__c settingHKD = Netsuite_Daily_Exchange_Rate__c.getInstance('HKD');
        Netsuite_Daily_Exchange_Rate__c settingSEK = Netsuite_Daily_Exchange_Rate__c.getInstance('SEK');
        Netsuite_Daily_Exchange_Rate__c settingJPY = Netsuite_Daily_Exchange_Rate__c.getInstance('JPY');
        Netsuite_Daily_Exchange_Rate__c settingAUD = Netsuite_Daily_Exchange_Rate__c.getInstance('AUD');
        Netsuite_Daily_Exchange_Rate__c settingRUB = Netsuite_Daily_Exchange_Rate__c.getInstance('RUB');
        Netsuite_Daily_Exchange_Rate__c settingNZD = Netsuite_Daily_Exchange_Rate__c.getInstance('NZD');
        Netsuite_Daily_Exchange_Rate__c settingILS = Netsuite_Daily_Exchange_Rate__c.getInstance('ILS');
        System.assertEquals(0.1, settingGBP.USD_Exchange_Rate__c, 'GBP Exchange rate not correctly created');
        System.assertEquals(0.2, settingCAD.USD_Exchange_Rate__c, 'CAD Exchange rate not correctly created');
        System.assertEquals(0.3, settingEUR.USD_Exchange_Rate__c, 'EUR Exchange rate not correctly created');
        System.assertEquals(0.4, settingCHF.USD_Exchange_Rate__c, 'CHF Exchange rate not correctly created');
        System.assertEquals(0.5, settingHKD.USD_Exchange_Rate__c, 'HKD Exchange rate not correctly created');
        System.assertEquals(0.6, settingSEK.USD_Exchange_Rate__c, 'SEK Exchange rate not correctly created');
        System.assertEquals(0.7, settingJPY.USD_Exchange_Rate__c, 'JPY Exchange rate not correctly created');
        System.assertEquals(0.8, settingAUD.USD_Exchange_Rate__c, 'AUD Exchange rate not correctly created');
        System.assertEquals(0.9, settingRUB.USD_Exchange_Rate__c, 'RUB Exchange rate not correctly created');
        System.assertEquals(0.11, settingNZD.USD_Exchange_Rate__c, 'NZD Exchange rate not correctly created');
        System.assertEquals(0.12, settingILS.USD_Exchange_Rate__c, 'ILS Exchange rate not correctly created');
        
    }

    @isTest
    static void retreiveExchangeRatesFromNetsuiteEndpointFailTest(){
        MockUtil.isSuccessfull = false;
        MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
        Test.setMock(HttpCalloutMock.class, mockServiceInstance);
        Test.startTest();
        NetsuiteExchangeRatesService.retreiveExchangeRatesFromNetsuiteEndpoint();
        Test.stopTest();
        System.assertEquals(0, Netsuite_Daily_Exchange_Rate__c.getAll().values().size(), 'Exchange rates should not exist');
    }

    @isTest
    static void retreiveExchangeRatesFromSfByCurrencyTest(){
        String currencyCode = 'JPY';
        Decimal exchangeRate = 0.99;
        Decimal actualExchangeRate = 0;
        Netsuite_Daily_Exchange_Rate__c netsuiteDailyExchangeRateSetting = new Netsuite_Daily_Exchange_Rate__c();
        netsuiteDailyExchangeRateSetting.Name = currencyCode;
        netsuiteDailyExchangeRateSetting.Currency_DDL__c = currencyCode;
        netsuiteDailyExchangeRateSetting.USD_Exchange_Rate__c = exchangeRate;
        insert netsuiteDailyExchangeRateSetting;
        Test.startTest();
        actualExchangeRate = NetsuiteExchangeRatesService.retreiveExchangeRatesFromSfByCurrency('JPY');
        Test.stopTest();
        System.assertEquals(exchangeRate, actualExchangeRate, 'Exchange rate not retrieved from SF correctly');
    }
    
    /**
    * @author Itzik Winograd
    * @date 18/07/2021
    * @Description: mock the service run.
    * @Expected: Daily_Exchange_Rate__c recrods are created 
    */
    @isTest
    public static void testDailyExchangeRateCreation(){
        MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
        Test.setMock(HttpCalloutMock.class, mockServiceInstance);
        Test.startTest();
        NetsuiteExchangeRatesService.retreiveExchangeRatesFromNetsuiteEndpoint();
        Test.stopTest();
        
        List<Daily_Exchange_Rate__c> createdRatesList = [
            SELECT Currency_Code__c, Currency_Name__c, Rate__c
        	FROM Daily_Exchange_Rate__c
        	Where CreatedDate > :Date.today()];
        System.assert(createdRatesList.size() > 0 , 'Error in the number of Daily_Exchange_Rate__c');
    }
    
    /**
    * @author Itzik Winograd
    * @date 18/07/2021
    * @Description: mock the service run when a Daily_Exchange_Rate__c already exists.
    * @Expected: Daily_Exchange_Rate__c recrods are upserted 
    */
    @isTest
    public static void testDailyExchangeRateUpsertion(){
        Daily_Exchange_Rate__c der = new Daily_Exchange_Rate__c(
            Currency_Code__c ='GBP',
        	Rate__c = 0.0,
        	BOI_currency_update_date__c = Date.today());
        insert der;
        MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
        Test.setMock(HttpCalloutMock.class, mockServiceInstance);
        Test.startTest();
        NetsuiteExchangeRatesService.retreiveExchangeRatesFromNetsuiteEndpoint();
        Test.stopTest();
        
        Daily_Exchange_Rate__c updatedDer = [
            SELECT Currency_Code__c, Currency_Name__c, Rate__c
        	FROM Daily_Exchange_Rate__c
        	Where Id = :der.Id
        	LIMIT 1];
        System.debug('@@@ updatedDer: ' + updatedDer);
        System.assertNotEquals(updatedDer.Rate__c, der.Rate__c, 'Rate__c was not updated!');
    }
}