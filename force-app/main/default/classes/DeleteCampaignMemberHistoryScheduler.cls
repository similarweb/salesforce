/**
 * Created by Alon.Shalev on 4/11/2024.
 */

global with sharing class DeleteCampaignMemberHistoryScheduler implements Schedulable{

    global void execute(SchedulableContext sc){

        Database.executeBatch(new DeleteRecordsBatch('Campaign_Member_History_Tracking__c'), 200);
    }

}