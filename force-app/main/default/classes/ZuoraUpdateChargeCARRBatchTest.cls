/**
 * Created by zohar.sinay on 14/07/2024.
 */
@isTest
public with sharing class ZuoraUpdateChargeCARRBatchTest {
    @isTest
    static void testsBatchBIDataPopulateRecords(){
        Test.startTest();
        ZuoraUpdateChargeCARRBatch zucb = new ZuoraUpdateChargeCARRBatch();
        database.executeBatch(zucb, 1);
        Test.stopTest();
    }
}