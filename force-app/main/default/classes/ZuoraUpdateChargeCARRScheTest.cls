/**
 * Created by zohar.sinay on 14/07/2024.
 */
@IsTest
public with sharing class ZuoraUpdateChargeCARRScheTest {
    @IsTest
    public static void ZuoraUpdateChargeCARRScheTest(){

        String CRON_EXP = '0 0 0 3 9 ? 2100';
        Test.startTest();
        String jobId = System.schedule('ZuoraUpdateChargeCARRScheduleTest',CRON_EXP, new ZuoraUpdateChargeCARRSchedulable());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                NextFireTime
        FROM CronTrigger WHERE id = :jobId];
        // assert
        System.assertEquals('2100-09-03 00:00:00',
                String.valueOf(ct.NextFireTime));
    }
}